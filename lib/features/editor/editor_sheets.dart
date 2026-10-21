import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/fonts.dart';
import '../../core/paper.dart';
import '../../core/widgets.dart';
import '../../data/mood.dart';
import '../../data/stickers.dart';
import '../../services/pro_service.dart';
import '../more/mood_pack_page.dart';
import '../paywall/paywall_page.dart';

// ---------------------------------------------------------------- mood

Future<Mood?> showMoodPicker(BuildContext context, {Mood? current}) =>
    showAppSheet<Mood>(context, (_) => _MoodSheet(current: current));

class _MoodSheet extends StatelessWidget {
  const _MoodSheet({this.current});
  final Mood? current;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(title: context.l.howAreYou),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.82,
              children: [
                for (final m in Mood.values)
                  Pressable(
                    onTap: () => Navigator.pop(context, m),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: m == current ? m.color.withValues(alpha: 0.28) : Colors.transparent,
                          ),
                          child: MoodIcon(m, size: 58),
                        ),
                        const SizedBox(height: 6),
                        Text(m.label(context.l), style: context.text.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoodPackPage()));
            },
            icon: Icon(Ph.smiley, color: p.accent, size: 20),
            label: Text(context.l.changeEmojiPack, style: TextStyle(color: p.accent, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- photo source

Future<ImageSource?> showPhotoSourcePicker(BuildContext context) => showAppSheet<ImageSource>(
      context,
      (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(title: ctx.l.addPhoto),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  Expanded(child: _SourceTile(icon: PhFill.camera, label: ctx.l.takePhoto, source: ImageSource.camera)),
                  const SizedBox(width: 14),
                  Expanded(child: _SourceTile(icon: PhFill.images, label: ctx.l.openGallery, source: ImageSource.gallery)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.source});
  final IconData icon;
  final String label;
  final ImageSource source;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Pressable(
      onTap: () => Navigator.pop(context, source),
      child: Container(
        height: 118,
        decoration: BoxDecoration(color: p.accentSoft, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: p.accent),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: p.accent, fontWeight: FontWeight.w800, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- stickers

Future<String?> showStickerPicker(BuildContext context) =>
    showAppSheet<String>(context, (_) => const _StickerSheet(), maxHeightFactor: 0.72);

class _StickerSheet extends StatefulWidget {
  const _StickerSheet();

  @override
  State<_StickerSheet> createState() => _StickerSheetState();
}

class _StickerSheetState extends State<_StickerSheet> {
  int _cat = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final isPro = context.watch<ProController>().isPro;
    final cat = Stickers.categories[_cat];
    return Column(
      children: [
        SheetHeader(title: context.l.stickers, action: context.l.done),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: Stickers.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = Stickers.categories[i];
              final sel = i == _cat;
              return Pressable(
                onTap: () => setState(() => _cat = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.only(left: 6, right: 14),
                  decoration: BoxDecoration(
                    color: sel ? p.accentSoft : p.surface2,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: sel ? p.accent.withValues(alpha: 0.5) : Colors.transparent, width: 1.4),
                  ),
                  child: Row(children: [
                    Image.asset(stickerAsset(c.items.first), width: 34, height: 34),
                    const SizedBox(width: 4),
                    Text(c.name(context.l), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: sel ? p.accent : p.inkSoft)),
                  ]),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            key: ValueKey(cat.id),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: cat.items.length,
            itemBuilder: (_, i) {
              final id = cat.items[i];
              final locked = i >= kFreeStickersPerCategory && !isPro;
              return EnterAnimation(
                index: i,
                child: Pressable(
                  scale: 0.88,
                  onTap: () async {
                    if (locked && !await ensurePro(context)) return;
                    if (context.mounted) Navigator.pop(context, id);
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(child: Padding(padding: const EdgeInsets.all(4), child: Image.asset(stickerAsset(id)))),
                      if (locked) const Positioned(right: 2, top: 2, child: ProBadge(size: 20)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- paper

Future<void> showPaperPicker(BuildContext context, {required String current, required ValueChanged<String> onPick}) =>
    showAppSheet<void>(context, (_) => _PaperSheet(current: current, onPick: onPick), maxHeightFactor: 0.66);

class _PaperSheet extends StatefulWidget {
  const _PaperSheet({required this.current, required this.onPick});
  final String current;
  final ValueChanged<String> onPick;

  @override
  State<_PaperSheet> createState() => _PaperSheetState();
}

class _PaperSheetState extends State<_PaperSheet> {
  late String _sel = widget.current;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final isPro = context.watch<ProController>().isPro;
    return Column(
      children: [
        SheetHeader(title: context.l.background, action: context.l.done),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.6, mainAxisSpacing: 14, crossAxisSpacing: 12),
            itemCount: Papers.all.length,
            itemBuilder: (_, i) {
              final paper = Papers.all[i];
              final sel = paper.id == _sel;
              final locked = paper.isPro && !isPro;
              return Pressable(
                onTap: () async {
                  if (locked && !await ensurePro(context)) return;
                  setState(() => _sel = paper.id);
                  widget.onPick(paper.id);
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: sel ? p.accent : p.line, width: sel ? 2.6 : 1.2),
                                boxShadow: sel ? [BoxShadow(color: p.accent.withValues(alpha: 0.25), blurRadius: 12)] : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CustomPaint(painter: PaperPainter(paper, p.bg, scale: 0.55)),
                              ),
                            ),
                          ),
                          if (locked) const Positioned(right: 6, top: 6, child: ProBadge(size: 20)),
                          if (sel) Positioned(left: 6, bottom: 6, child: Icon(PhFill.checkCircle, color: p.accent, size: 22)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(paper.name(context.l), maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelSmall),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- font & ink

Future<void> showFontPicker(
  BuildContext context, {
  required String fontId,
  required int? ink,
  required void Function(String fontId, int? ink) onChange,
}) =>
    showAppSheet<void>(context, (_) => _FontSheet(fontId: fontId, ink: ink, onChange: onChange), maxHeightFactor: 0.7);

class _FontSheet extends StatefulWidget {
  const _FontSheet({required this.fontId, required this.ink, required this.onChange});
  final String fontId;
  final int? ink;
  final void Function(String fontId, int? ink) onChange;

  @override
  State<_FontSheet> createState() => _FontSheetState();
}

class _FontSheetState extends State<_FontSheet> {
  late String _font = widget.fontId;
  late int? _ink = widget.ink;

  void _emit() => widget.onChange(_font, _ink);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final isPro = context.watch<ProController>().isPro;
    return Column(
      children: [
        SheetHeader(title: context.l.font, action: context.l.done),
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: kInkColors.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final c = kInkColors[i];
              final sel = c?.toARGB32() == _ink;
              return Pressable(
                onTap: () {
                  setState(() => _ink = c?.toARGB32());
                  _emit();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: sel ? p.accent : Colors.transparent, width: 2.4),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c ?? p.ink,
                      border: Border.all(color: p.line, width: c == const Color(0xFFFFFFFF) ? 1.5 : 0),
                    ),
                    child: c == null ? Icon(Ph.textAa, size: 16, color: p.bg) : null,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.55, mainAxisSpacing: 12, crossAxisSpacing: 12),
            itemCount: EditorFonts.all.length,
            itemBuilder: (_, i) {
              final f = EditorFonts.all[i];
              final sel = f.id == _font;
              final locked = f.isPro && !isPro;
              return Pressable(
                onTap: () async {
                  if (locked && !await ensurePro(context)) return;
                  setState(() => _font = f.id);
                  _emit();
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? p.accentSoft : p.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: sel ? p.accent : p.line, width: sel ? 2 : 1.2),
                        ),
                        child: Text(
                          f.label,
                          maxLines: 1,
                          style: f.style(size: 18, color: _ink != null ? Color(_ink!) : p.ink),
                        ),
                      ),
                    ),
                    if (locked) const Positioned(right: 6, top: 6, child: ProBadge(size: 18)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
