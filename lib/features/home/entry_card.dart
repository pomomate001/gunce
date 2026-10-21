import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/fonts.dart';
import '../../core/format.dart';
import '../../core/palette.dart';
import '../../core/widgets.dart';
import '../../data/entries_controller.dart';
import '../../data/entry.dart';
import '../../data/media_store.dart';
import '../../data/stickers.dart';
import '../editor/editor_page.dart';
import '../editor/voice.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry, this.highlight});

  final Entry entry;

  /// Search term to emphasise (already folded).
  final String? highlight;

  Future<void> _actions(BuildContext context) async {
    final l = context.l;
    final entries = context.read<EntriesController>();
    final action = await showAppSheet<String>(
      context,
      (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(title: entry.title.isEmpty ? Dates(ctx.lang).full(entry.date) : entry.title),
            ListTile(
              leading: Icon(entry.favorite ? PhFill.star : Ph.star, color: const Color(0xFFFFB020)),
              title: Text(entry.favorite ? l.removeFavorite : l.addFavorite, style: ctx.text.titleSmall),
              onTap: () => Navigator.pop(ctx, 'fav'),
            ),
            ListTile(
              leading: Icon(Ph.pencilSimple, color: ctx.pal.ink),
              title: Text(l.edit, style: ctx.text.titleSmall),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Ph.trash, color: Color(0xFFE5484D)),
              title: Text(l.delete, style: ctx.text.titleSmall?.copyWith(color: const Color(0xFFE5484D))),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'fav':
        await entries.toggleFavorite(entry);
      case 'edit':
        await openEditor(context, entry: entry);
      case 'delete':
        final ok = await confirm(context, title: l.deleteEntryTitle, message: l.deleteEntryMessage, confirmLabel: l.delete, destructive: true);
        if (ok) await entries.delete(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final dates = Dates(context.lang);
    final font = EditorFonts.byId(entry.fontId);
    final ink = entry.inkColor != null && entry.inkColor != 0xFFFFFFFF ? Color(entry.inkColor!) : p.ink;
    final title = entry.title.isNotEmpty ? entry.title : (entry.mood?.label(context.l) ?? dates.weekday(entry.date));

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 18, 16),
      onTap: () => openEditor(context, entry: entry),
      onLongPress: () => _actions(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: (entry.mood?.color ?? p.surface2).withValues(alpha: 0.25)),
                  child: MoodIcon(entry.mood, size: 46),
                ),
                const SizedBox(height: 8),
                Text('${entry.date.day}', style: TextStyle(fontFamily: kDisplayFont, fontSize: 26, fontWeight: FontWeight.w600, color: p.ink, height: 1)),
                const SizedBox(height: 2),
                Text(dates.monthShort(entry.date), style: context.text.labelSmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: font.style(size: 18, weight: FontWeight.w700, color: ink, height: 1.25),
                      ),
                    ),
                    if (entry.favorite) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(PhFill.star, size: 18, color: Color(0xFFFFB020))),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${dates.weekday(entry.date)} · ${dates.time(entry.date)}',
                  style: TextStyle(fontFamily: kDisplayFont, fontStyle: FontStyle.italic, fontSize: 13.5, color: p.inkFaint),
                ),
                if (entry.body.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Body(text: entry.body, style: font.style(size: 15, height: 1.45, color: ink.withValues(alpha: 0.78)), highlight: highlight, accent: p.accent),
                ],
                if (entry.photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _Photos(photos: entry.photos),
                ],
                if (entry.audios.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  AudioTile(clip: entry.audios.first, dense: true),
                ],
                if (entry.stickers.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    for (final s in entry.stickers.take(5))
                      Padding(padding: const EdgeInsets.only(right: 2), child: Image.asset(stickerAsset(s.sticker), width: 30, height: 30)),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.text, required this.style, required this.accent, this.highlight});
  final String text;
  final TextStyle style;
  final String? highlight;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final h = highlight;
    if (h == null || h.isEmpty) return Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: style);
    // foldText keeps string length, so indexes map back onto the original text.
    final folded = foldText(text);
    final at = folded.indexOf(h);
    if (at < 0 || folded.length != text.length) return Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: style);
    final start = (at - 40).clamp(0, text.length);
    final prefix = start > 0 ? '…' : '';
    return Text.rich(
      TextSpan(style: style, children: [
        TextSpan(text: prefix + text.substring(start, at)),
        TextSpan(text: text.substring(at, at + h.length), style: TextStyle(backgroundColor: accent.withValues(alpha: 0.22), fontWeight: FontWeight.w800)),
        TextSpan(text: text.substring(at + h.length)),
      ]),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Photos extends StatelessWidget {
  const _Photos({required this.photos});
  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    final media = MediaStore.instance;
    final first = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image(image: ResizeImage(media.photo(photos.first), width: 720, allowUpscaling: false), fit: BoxFit.cover, gaplessPlayback: true),
      ),
    );
    if (photos.length == 1) return first;
    return Stack(
      children: [
        first,
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Ph.images, size: 15, color: Colors.white),
              const SizedBox(width: 4),
              Text('+${photos.length - 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
          ),
        ),
      ],
    );
  }
}
