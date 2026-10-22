import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/fonts.dart';
import '../../core/format.dart';
import '../../core/palette.dart';
import '../../core/paper.dart';
import '../../core/widgets.dart';
import '../../data/entries_controller.dart';
import '../../data/entry.dart';
import '../../data/media_store.dart';
import '../../data/mood.dart';
import '../../services/ads_service.dart';
import '../lock/lock_gate.dart';
import 'editor_sheets.dart';
import 'photo_frame.dart';
import 'photo_view.dart';
import 'sticker_layer.dart';
import 'voice.dart';

/// Opens the editor; shows the save interstitial when the user saved.
Future<void> openEditor(BuildContext context, {Entry? entry, DateTime? date, Mood? mood, String? prompt}) async {
  final saved = await Navigator.of(context).push<bool>(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => EditorPage(entry: entry, date: date, mood: mood, prompt: prompt),
    transitionsBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved), child: child),
      );
    },
  ));
  if (saved == true && context.mounted) {
    toast(context, context.l.saved, icon: PhFill.checkCircle);
    await AdsService.instance.onEntrySaved();
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key, this.entry, this.date, this.mood, this.prompt});

  final Entry? entry;
  final DateTime? date;
  final Mood? mood;
  final String? prompt;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late Entry _draft;
  late final TextEditingController _title;
  late final TextEditingController _body;
  late String _originalJson;
  final _scroll = ScrollController();
  final _added = <String>{};
  final _removed = <String>{};
  /// Key of the selected sticker, or file name of the selected photo / voice note.
  String? _selected;
  bool _itemHit = false;
  double _pageWidth = 0;
  bool _saving = false;

  bool get _isNew => widget.entry == null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final d = widget.date;
    _draft = widget.entry ??
        Entry.create(
          d == null || isSameDay(d, now) ? now : DateTime(d.year, d.month, d.day, 12),
          mood: widget.mood,
        );
    _title = TextEditingController(text: _draft.title);
    _body = TextEditingController(text: _draft.body);
    _originalJson = jsonEncode(_draft.toJson());
    WidgetsBinding.instance.addPostFrameCallback((_) => _placeUnplacedMedia());
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Entry get _current => _draft.copyWith(title: _title.text.trim(), body: _body.text.trimRight());

  bool get _dirty => _isNew ? !_current.isEmpty : jsonEncode(_current.toJson()) != _originalJson;

  void _update(Entry Function(Entry) f) => setState(() => _draft = f(_draft));

  // ------------------------------------------------------------- actions

  Future<void> _save() async {
    final e = _current;
    if (e.isEmpty) {
      toast(context, context.l.emptyEntry);
      return;
    }
    setState(() => _saving = true);
    await context.read<EntriesController>().save(e);
    await MediaStore.instance.deleteAll(_removed);
    HapticFeedback.mediumImpact();
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _close() async {
    if (_dirty) {
      final l = context.l;
      final leave = await confirm(context, title: l.discardTitle, message: l.discardMessage, confirmLabel: l.discard, destructive: true);
      if (!leave) return;
    }
    await MediaStore.instance.deleteAll(_added);
    if (mounted) Navigator.pop(context, false);
  }

  Future<void> _delete() async {
    final l = context.l;
    final ok = await confirm(context, title: l.deleteEntryTitle, message: l.deleteEntryMessage, confirmLabel: l.delete, destructive: true);
    if (!ok || !mounted) return;
    await MediaStore.instance.deleteAll(_added);
    if (!mounted) return;
    await context.read<EntriesController>().delete(widget.entry!);
    if (mounted) Navigator.pop(context, false);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.date.isAfter(now) ? now : _draft.date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked == null) return;
    final d = _draft.date;
    _update((e) => e.copyWith(date: DateTime(picked.year, picked.month, picked.day, d.hour, d.minute)));
  }

  Future<void> _pickMood() async {
    final m = await showMoodPicker(context, current: _draft.mood);
    if (m != null) _update((e) => e.copyWith(mood: m));
  }

  Future<void> _addPhoto() async {
    FocusScope.of(context).unfocus();
    final source = await showPhotoSourcePicker(context);
    if (source == null) return;
    LockGate.allowBackground(const Duration(minutes: 5));
    final picker = ImagePicker();
    final files = source == ImageSource.camera
        ? [?await picker.pickImage(source: source, maxWidth: 2200, maxHeight: 2200, imageQuality: 88)]
        : await picker.pickMultiImage(maxWidth: 2200, maxHeight: 2200, imageQuality: 88, limit: 10);
    final names = <String>[];
    for (final f in files) {
      names.add(await MediaStore.instance.importPhoto(f));
    }
    if (names.isEmpty) return;
    _added.addAll(names);
    final layout = {..._draft.layout};
    var top = _nextTop;
    for (final n in names) {
      final aspect = await MediaStore.instance.photoAspect(n);
      final h = _pageWidth * aspect;
      layout[n] = MediaLayout(x: 0.5, y: (top + h / 2) / _pageWidth, aspect: aspect);
      top += h + 16;
    }
    if (!mounted) return;
    _update((e) => e.copyWith(photos: [...e.photos, ...names], layout: layout));
  }

  void _removePhoto(String name) {
    _removed.add(name);
    _selected = null;
    _update((e) => e.copyWith(photos: e.photos.where((p) => p != name).toList(), layout: {...e.layout}..remove(name)));
  }

  Future<void> _addVoice() async {
    FocusScope.of(context).unfocus();
    final clip = await showVoiceRecorder(context);
    if (clip == null) return;
    _added.add(clip.file);
    final y = (_nextTop + _voiceHeight / 2) / _pageWidth;
    _update((e) => e.copyWith(audios: [...e.audios, clip], layout: {...e.layout, clip.file: MediaLayout(x: 0.5, y: y)}));
  }

  void _removeVoice(AudioClip clip) {
    _removed.add(clip.file);
    _selected = null;
    _update((e) => e.copyWith(audios: e.audios.where((a) => a.file != clip.file).toList(), layout: {...e.layout}..remove(clip.file)));
  }

  // ------------------------------------------------------------- photo & voice placement

  static const _voiceHeight = 56.0;

  double _mediaHeight(String name, double width) {
    final l = _draft.layout[name]!;
    return _draft.photos.contains(name) ? PhotoFrame.byId(l.frame).height(width, l.aspect) : _voiceHeight;
  }

  /// Bottom of the lowest photo / voice note, in pixels from the top of the media area.
  double get _mediaBottom {
    var bottom = 0.0;
    for (final e in _draft.layout.entries) {
      bottom = math.max(bottom, e.value.y * _pageWidth + _mediaHeight(e.key, e.value.size * _pageWidth) / 2);
    }
    return bottom;
  }

  /// Where the next added photo / voice note starts: under everything already placed.
  double get _nextTop => _draft.layout.isEmpty ? 0 : _mediaBottom + 16;

  /// Pages saved before photos and voice notes could be moved: put them under the text
  /// in the old order (voice notes, then photos) without marking the page as edited.
  Future<void> _placeUnplacedMedia() async {
    final audios = [for (final a in _draft.audios) if (!_draft.layout.containsKey(a.file)) a.file];
    final photos = [for (final p in _draft.photos) if (!_draft.layout.containsKey(p)) p];
    if (audios.isEmpty && photos.isEmpty) return;
    final aspects = [for (final p in photos) await MediaStore.instance.photoAspect(p)];
    if (!mounted) return;
    final wasClean = !_dirty;
    final layout = {..._draft.layout};
    var top = _nextTop;
    for (final a in audios) {
      layout[a] = MediaLayout(x: 0.5, y: (top + _voiceHeight / 2) / _pageWidth);
      top += _voiceHeight + 14;
    }
    for (var i = 0; i < photos.length; i++) {
      final h = _pageWidth * aspects[i];
      layout[photos[i]] = MediaLayout(x: 0.5, y: (top + h / 2) / _pageWidth, aspect: aspects[i]);
      top += h + 16;
    }
    setState(() => _draft = _draft.copyWith(layout: layout));
    if (wasClean) _originalJson = jsonEncode(_current.toJson());
  }

  void _changeLayout(String name, MediaLayout l) => _update((e) => e.copyWith(layout: {...e.layout, name: l}));

  void _openFrames(String name) {
    final l = _draft.layout[name]!;
    showPhotoFrameSheet(
      context,
      image: MediaStore.instance.photo(name),
      aspect: l.aspect,
      current: PhotoFrame.byId(l.frame),
      onPick: (f) {
        final next = _draft.layout[name]!.copyWith(frame: f.name, clearFrame: f == PhotoFrame.none);
        // A taller frame must not push the photo up into the text.
        final half = f.height(next.size * _pageWidth, next.aspect) / 2 / _pageWidth;
        _changeLayout(name, next.copyWith(y: math.max(next.y, half)));
      },
      onFullScreen: () => openPhotoViewer(context, _draft.photos, _draft.photos.indexOf(name)),
    );
  }

  Future<void> _addSticker(double pageWidth) async {
    FocusScope.of(context).unfocus();
    final id = await showStickerPicker(context);
    if (id == null || !mounted) return;
    // Drop it in the middle of what is currently visible.
    final viewport = _scroll.hasClients ? _scroll.position.viewportDimension : 500.0;
    final offset = _scroll.hasClients ? _scroll.offset : 0.0;
    final rnd = math.Random();
    final item = StickerItem(
      key: Entry.newId(),
      sticker: id,
      x: 0.5 + (rnd.nextDouble() - 0.5) * 0.3,
      y: (offset + viewport * 0.42) / pageWidth,
      rotation: (rnd.nextDouble() - 0.5) * 0.4,
    );
    setState(() {
      _draft = _draft.copyWith(stickers: [..._draft.stickers, item]);
      _selected = item.key;
    });
  }

  void _changeSticker(StickerItem s) =>
      _update((e) => e.copyWith(stickers: [for (final x in e.stickers) x.key == s.key ? s : x]));

  void _deleteSticker(String key) {
    setState(() {
      _draft = _draft.copyWith(stickers: _draft.stickers.where((s) => s.key != key).toList());
      _selected = null;
    });
  }

  void _bringToFront(String key) {
    final s = _draft.stickers.firstWhere((x) => x.key == key);
    if (_draft.stickers.last.key == key) return;
    _draft = _draft.copyWith(stickers: [..._draft.stickers.where((x) => x.key != key), s]);
  }

  Future<void> _pickPaper() async {
    FocusScope.of(context).unfocus();
    await showPaperPicker(context, current: _draft.paperId ?? 'plain', onPick: (id) => _update((e) => e.copyWith(paperId: id)));
  }

  Future<void> _pickFont() async {
    FocusScope.of(context).unfocus();
    await showFontPicker(
      context,
      fontId: _draft.fontId ?? EditorFonts.defaultId,
      ink: _draft.inkColor,
      onChange: (font, ink) => _update((e) => e.copyWith(fontId: font, inkColor: ink, clearInk: ink == null)),
    );
  }

  // ------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final paper = Papers.byId(_draft.paperId);
    final darkPage = paper.isDarkOn(p);
    final font = EditorFonts.byId(_draft.fontId);
    final ink = _draft.inkColor != null ? Color(_draft.inkColor!) : (darkPage ? const Color(0xFFF4F1FF) : p.ink);
    final hint = (darkPage ? Colors.white : p.ink).withValues(alpha: 0.38);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: AnnotatedRegion(
        value: darkPage ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: paper.base ?? p.bg,
          body: Stack(
            children: [
              Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: PaperPainter(paper, p.bg)))),
              SafeArea(
                child: Column(
                  children: [
                    _TopBar(
                      ink: ink,
                      favorite: _draft.favorite,
                      saving: _saving,
                      canDelete: !_isNew,
                      onClose: _close,
                      onFavorite: () => _update((e) => e.copyWith(favorite: !e.favorite)),
                      onSave: _save,
                      onDelete: _delete,
                    ),
                    Expanded(
                      child: LayoutBuilder(builder: (context, box) {
                        const hPad = 22.0;
                        final pageWidth = box.maxWidth - hPad * 2;
                        _pageWidth = pageWidth;
                        return Listener(
                          onPointerDown: (_) {
                            if (!_itemHit && _selected != null) setState(() => _selected = null);
                            _itemHit = false;
                          },
                          child: SingleChildScrollView(
                            controller: _scroll,
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(hPad, 6, hPad, 130),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: box.maxHeight - 140),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _content(context, font, ink, hint, darkPage),
                                  for (final s in _draft.stickers)
                                    Positioned(
                                      left: s.x * pageWidth - (s.size * pageWidth + 40) / 2,
                                      top: s.y * pageWidth - (s.size * pageWidth + 40) / 2,
                                      child: Listener(
                                        onPointerDown: (_) => _itemHit = true,
                                        child: StickerView(
                                          key: ValueKey(s.key),
                                          item: s,
                                          pageWidth: pageWidth,
                                          selected: _selected == s.key,
                                          onSelect: () => setState(() {
                                            _selected = s.key;
                                            _bringToFront(s.key);
                                          }),
                                          onChanged: _changeSticker,
                                          onDelete: () => _deleteSticker(s.key),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12 + MediaQuery.paddingOf(context).bottom,
                child: LayoutBuilder(
                  builder: (context, box) => _Toolbar(
                    onPhoto: _addPhoto,
                    onSticker: () => _addSticker(MediaQuery.sizeOf(context).width - 44),
                    onVoice: _addVoice,
                    onPaper: _pickPaper,
                    onFont: _pickFont,
                    labels: [l.toolPhoto, l.toolStickers, l.toolVoice, l.toolBackground, l.toolFont],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, EditorFont font, Color ink, Color hint, bool darkPage) {
    final p = context.pal;
    final l = context.l;
    final dates = Dates(context.lang);
    final d = _draft.date;
    final chipBg = darkPage ? Colors.white.withValues(alpha: 0.12) : p.surface.withValues(alpha: 0.85);
    TextStyle style(double size, {FontWeight w = FontWeight.w400, double h = 1.55}) => font.style(size: size, weight: w, color: ink, height: h);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Pressable(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(22), boxShadow: darkPage ? null : p.softShadow),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${d.day}', style: TextStyle(fontFamily: kDisplayFont, fontSize: 34, fontWeight: FontWeight.w600, color: ink, height: 1)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dates.month(d), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: ink, height: 1.2)),
                        Text('${dates.weekday(d)} · ${d.year}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: ink.withValues(alpha: 0.6))),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(Ph.caretDown, size: 18, color: ink.withValues(alpha: 0.6)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Pressable(
              onTap: _pickMood,
              scale: 0.9,
              semanticLabel: l.howAreYou,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
                child: Container(
                  key: ValueKey(_draft.mood),
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_draft.mood?.color ?? p.surface2).withValues(alpha: _draft.mood == null ? 1 : 0.32),
                  ),
                  child: MoodIcon(_draft.mood, size: 60),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _title,
          style: style(25, w: FontWeight.w700, h: 1.25),
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: l.titleHint,
            hintStyle: style(25, w: FontWeight.w700, h: 1.25).copyWith(color: hint),
            isCollapsed: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _body,
          style: style(17.5),
          maxLines: null,
          minLines: 5,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: widget.prompt ?? l.bodyHint,
            hintStyle: style(17.5).copyWith(color: hint),
            hintMaxLines: 3,
            isCollapsed: true,
          ),
        ),
        if (_draft.layout.isNotEmpty) ...[const SizedBox(height: 16), _mediaArea()],
      ],
    );
  }

  /// Photos and voice notes, placed freely in the area under the text (so they move
  /// down with it as the user writes more). The selected one is drawn on top.
  Widget _mediaArea() {
    final names = [
      for (final a in _draft.audios) if (_draft.layout.containsKey(a.file)) a.file,
      for (final p in _draft.photos) if (_draft.layout.containsKey(p)) p,
    ];
    final ordered = [...names.where((n) => n != _selected), ...names.where((n) => n == _selected)];
    return SizedBox(
      width: _pageWidth,
      height: _mediaBottom + 4,
      child: Stack(clipBehavior: Clip.none, children: [for (final name in ordered) _mediaItem(name)]),
    );
  }

  Widget _mediaItem(String name) {
    final w = _pageWidth;
    final l = _draft.layout[name]!;
    final isPhoto = _draft.photos.contains(name);
    final width = l.size * w;
    final height = _mediaHeight(name, width);
    final clip = isPhoto ? null : _draft.audios.firstWhere((a) => a.file == name);
    return Positioned(
      key: ValueKey(name),
      left: l.x * w - width / 2,
      top: l.y * w - height / 2,
      child: Listener(
        onPointerDown: (_) => _itemHit = true,
        child: MediaView(
          layout: l,
          pageWidth: w,
          heightFor: (width) => _mediaHeight(name, width),
          minSize: isPhoto ? 0.3 : 0.5,
          selected: _selected == name,
          onSelect: () => setState(() => _selected = name),
          onChanged: (v) => _changeLayout(name, v),
          onTap: isPhoto ? () => _openFrames(name) : () => setState(() => _selected = null),
          onDelete: isPhoto ? () => _removePhoto(name) : null,
          onFrame: isPhoto ? () => _openFrames(name) : null,
          child: isPhoto
              ? Hero(
                  tag: 'photo-$name',
                  child: FramedPhoto(image: MediaStore.instance.photo(name), frame: PhotoFrame.byId(l.frame), width: width, aspect: l.aspect),
                )
              : AudioTile(clip: clip!, onDelete: () => _removeVoice(clip)),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.ink,
    required this.favorite,
    required this.saving,
    required this.canDelete,
    required this.onClose,
    required this.onFavorite,
    required this.onSave,
    required this.onDelete,
  });

  final Color ink;
  final bool favorite, saving, canDelete;
  final VoidCallback onClose, onFavorite, onSave, onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
      child: Row(
        children: [
          CircleButton(icon: Ph.x, onTap: onClose, background: Colors.transparent, color: ink, tooltip: l.close),
          const Spacer(),
          if (canDelete) CircleButton(icon: Ph.trash, onTap: onDelete, background: Colors.transparent, color: ink, tooltip: l.delete),
          CircleButton(
            icon: favorite ? PhFill.star : Ph.star,
            onTap: onFavorite,
            background: Colors.transparent,
            color: favorite ? const Color(0xFFFFB020) : ink,
            tooltip: l.favorite,
          ),
          const SizedBox(width: 6),
          AppButton(label: l.save, onTap: saving ? null : onSave, loading: saving, expand: false, height: 42, icon: PhBold.check),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.onPhoto,
    required this.onSticker,
    required this.onVoice,
    required this.onPaper,
    required this.onFont,
    required this.labels,
  });

  final VoidCallback onPhoto, onSticker, onVoice, onPaper, onFont;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final items = [
      (Ph.image, onPhoto),
      (Ph.sticker, onSticker),
      (Ph.microphone, onVoice),
      (Ph.stack, onPaper),
      (Ph.textAa, onFont),
    ];
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: p.shadow.withValues(alpha: p.shadow.a * 1.6), blurRadius: 30, offset: const Offset(0, 10))],
        border: p.isDark ? Border.all(color: p.line) : null,
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: Pressable(
                onTap: items[i].$2,
                scale: 0.88,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[i].$1, size: 25, color: p.ink),
                    const SizedBox(height: 3),
                    Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.inkSoft)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
