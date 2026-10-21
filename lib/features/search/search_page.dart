import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/widgets.dart';
import '../../data/entries_controller.dart';
import '../../data/mood.dart';
import '../home/entry_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _query = TextEditingController();
  bool _favorites = false;
  Mood? _mood;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final entries = context.watch<EntriesController>();
    final active = _query.text.trim().isNotEmpty || _favorites || _mood != null;
    final results = active ? entries.search(_query.text, favoritesOnly: _favorites, mood: _mood) : entries.entries;
    final folded = foldText(_query.text.trim());

    Widget chip({required bool selected, required VoidCallback onTap, required Widget child}) => Pressable(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? p.accentSoft : p.surface,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: selected ? p.accent : p.line, width: selected ? 1.8 : 1),
            ),
            child: child,
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  CircleButton(icon: Ph.arrowLeft, onTap: () => Navigator.pop(context), background: Colors.transparent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(25), boxShadow: p.softShadow),
                      child: Row(
                        children: [
                          Icon(Ph.magnifyingGlass, color: p.inkFaint, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _query,
                              autofocus: true,
                              onChanged: (_) => setState(() {}),
                              textInputAction: TextInputAction.search,
                              style: context.text.bodyLarge,
                              decoration: InputDecoration(hintText: l.searchHint, isCollapsed: true),
                            ),
                          ),
                          if (_query.text.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(_query.clear),
                              child: Icon(PhFill.xCircle, color: p.inkFaint, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  chip(
                    selected: _favorites,
                    onTap: () => setState(() => _favorites = !_favorites),
                    child: Row(children: [
                      Icon(_favorites ? PhFill.star : Ph.star, size: 18, color: const Color(0xFFFFB020)),
                      const SizedBox(width: 6),
                      Text(l.favorites, style: context.text.labelMedium),
                    ]),
                  ),
                  for (final m in Mood.values) ...[
                    const SizedBox(width: 8),
                    chip(
                      selected: _mood == m,
                      onTap: () => setState(() => _mood = _mood == m ? null : m),
                      child: MoodIcon(m, size: 28),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? Center(child: EmptyState(title: l.noResults, message: l.noResultsHint, mood: Mood.meh))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: results.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
                            child: Text(l.resultCount(results.length), style: context.text.bodySmall),
                          );
                        }
                        final e = results[i - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EntryCard(key: ValueKey(e.id), entry: e, highlight: folded.isEmpty ? null : folded),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
