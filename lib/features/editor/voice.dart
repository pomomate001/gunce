import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../../core/format.dart';
import '../../core/palette.dart';
import '../../core/widgets.dart';
import '../../data/entry.dart';
import '../../data/media_store.dart';
import '../lock/lock_gate.dart';

const _maxRecording = Duration(minutes: 10);

Future<AudioClip?> showVoiceRecorder(BuildContext context) =>
    showAppSheet<AudioClip>(context, (_) => const _RecorderSheet());

class _RecorderSheet extends StatefulWidget {
  const _RecorderSheet();

  @override
  State<_RecorderSheet> createState() => _RecorderSheetState();
}

class _RecorderSheetState extends State<_RecorderSheet> {
  final _rec = AudioRecorder();
  final _clock = Stopwatch();
  final _levels = <double>[];
  StreamSubscription<Amplitude>? _amp;
  Timer? _tick;
  bool _recording = false;
  bool _busy = false;

  @override
  void dispose() {
    _amp?.cancel();
    _tick?.cancel();
    if (_recording) _rec.cancel();
    _rec.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    LockGate.allowBackground(const Duration(minutes: 1));
    if (!await _rec.hasPermission()) {
      if (mounted) {
        setState(() => _busy = false);
        toast(context, context.l.micPermission);
      }
      return;
    }
    final path = await MediaStore.instance.tempAudioPath();
    await _rec.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000, sampleRate: 32000, numChannels: 1),
      path: path,
    );
    HapticFeedback.mediumImpact();
    _amp = _rec.onAmplitudeChanged(const Duration(milliseconds: 90)).listen((a) {
      final v = ((a.current + 50) / 50).clamp(0.04, 1.0);
      setState(() => _levels.add(v.toDouble()));
    });
    _clock
      ..reset()
      ..start();
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_clock.elapsed >= _maxRecording) _stop();
      setState(() {});
    });
    setState(() {
      _recording = true;
      _busy = false;
    });
  }

  Future<void> _stop() async {
    if (!_recording) return;
    _recording = false;
    _tick?.cancel();
    await _amp?.cancel();
    _clock.stop();
    final path = await _rec.stop();
    HapticFeedback.lightImpact();
    if (path == null || !mounted) return;
    final file = await MediaStore.instance.importAudio(path);
    if (!mounted) return;
    Navigator.pop(context, AudioClip(file: file, durationMs: _clock.elapsedMilliseconds, wave: _downsample(_levels, 48)));
  }

  static List<double> _downsample(List<double> src, int n) {
    if (src.isEmpty) return List.filled(n, 0.1);
    return List.generate(n, (i) {
      final a = (i * src.length / n).floor();
      final b = math.max(a + 1, ((i + 1) * src.length / n).floor());
      final slice = src.sublist(a, math.min(b, src.length));
      return slice.isEmpty ? src[math.min(a, src.length - 1)] : slice.reduce(math.max);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final recent = _levels.length > 46 ? _levels.sublist(_levels.length - 46) : _levels;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(title: l.voiceNote),
          const SizedBox(height: 12),
          Text(
            formatDuration(_clock.elapsed),
            style: TextStyle(fontFamily: kDisplayFont, fontSize: 46, fontWeight: FontWeight.w600, color: p.ink, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: CustomPaint(
                size: const Size(double.infinity, 64),
                painter: WavePainter(levels: recent.isEmpty ? List.filled(46, 0.06) : recent, color: p.accent, fixedBars: 46),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Pressable(
            onTap: _busy ? null : (_recording ? _stop : _start),
            scale: 0.92,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: p.accent,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: p.accent.withValues(alpha: _recording ? 0.55 : 0.3), blurRadius: _recording ? 30 : 16, spreadRadius: _recording ? 4 : 0)],
              ),
              child: Icon(_recording ? PhFill.stop : PhFill.microphone, color: p.onAccent, size: 36),
            ),
          ),
          const SizedBox(height: 14),
          Text(_recording ? l.tapToStop : l.tapToRecord, style: context.text.bodyMedium),
          if (kIsWeb) ...[const SizedBox(height: 6), Text(l.webPreviewNote, style: context.text.bodySmall)],
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  WavePainter({required this.levels, required this.color, this.progress = 1, this.dim, this.fixedBars});

  final List<double> levels;
  final Color color;
  final Color? dim;
  final double progress;
  final int? fixedBars;

  @override
  void paint(Canvas canvas, Size size) {
    final n = fixedBars ?? levels.length;
    if (n == 0) return;
    final gap = size.width / n;
    final barW = math.max(2.0, gap * 0.55);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < n; i++) {
      final v = i < levels.length ? levels[i] : 0.06;
      final h = math.max(barW, v * size.height);
      final x = gap * i + gap / 2;
      paint
        ..color = (i / n <= progress) ? color : (dim ?? color.withValues(alpha: 0.3))
        ..strokeWidth = barW;
      canvas.drawLine(Offset(x, size.height / 2 - h / 2 + barW / 2), Offset(x, size.height / 2 + h / 2 - barW / 2), paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter old) => true;
}

/// Inline player for a voice note.
class AudioTile extends StatefulWidget {
  const AudioTile({super.key, required this.clip, this.onDelete, this.dense = false});

  final AudioClip clip;
  final VoidCallback? onDelete;
  final bool dense;

  @override
  State<AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<AudioTile> {
  AudioPlayer? _player;
  StreamSubscription<Duration>? _pos;
  StreamSubscription<PlayerState>? _state;
  Duration _position = Duration.zero;
  bool _playing = false;

  Duration get _total => Duration(milliseconds: widget.clip.durationMs);

  Future<void> _toggle() async {
    var player = _player;
    if (player == null) {
      player = _player = AudioPlayer();
      final src = MediaStore.instance.audioSource(widget.clip.file);
      try {
        if (kIsWeb) {
          await player.setUrl(src);
        } else {
          await player.setFilePath(src);
        }
      } catch (e) {
        debugPrint('audio load failed: $e');
        return;
      }
      _pos = player.positionStream.listen((d) => setState(() => _position = d));
      _state = player.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed) {
          player!.pause();
          player.seek(Duration.zero);
        }
        setState(() => _playing = s.playing && s.processingState != ProcessingState.completed);
      });
    }
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  @override
  void dispose() {
    _pos?.cancel();
    _state?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final h = widget.dense ? 44.0 : 56.0;
    final progress = _total.inMilliseconds == 0 ? 0.0 : _position.inMilliseconds / _total.inMilliseconds;
    final wave = widget.clip.wave.isEmpty ? List.filled(40, 0.3) : widget.clip.wave;
    return Container(
      height: h,
      padding: EdgeInsets.symmetric(horizontal: widget.dense ? 4 : 6),
      decoration: BoxDecoration(color: p.accentSoft, borderRadius: BorderRadius.circular(h / 2)),
      child: Row(
        children: [
          if (widget.onDelete != null)
            Pressable(
              onTap: widget.onDelete,
              child: Container(
                width: h - 12,
                height: h - 12,
                decoration: BoxDecoration(color: p.surface, shape: BoxShape.circle),
                child: const Icon(Ph.trash, size: 20, color: Color(0xFFE5484D)),
              ),
            ),
          SizedBox(width: widget.onDelete != null ? 8 : 4),
          Expanded(
            child: CustomPaint(
              size: Size(double.infinity, h * 0.5),
              painter: WavePainter(levels: wave, color: p.accent, progress: _playing || _position > Duration.zero ? progress : 0),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatDuration(_playing || _position > Duration.zero ? _position : _total),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.inkSoft, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const SizedBox(width: 8),
          Pressable(
            onTap: _toggle,
            scale: 0.9,
            child: Container(
              width: h - 12,
              height: h - 12,
              decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
              child: Icon(_playing ? PhFill.pause : PhFill.play, size: 20, color: p.onAccent),
            ),
          ),
        ],
      ),
    );
  }
}
