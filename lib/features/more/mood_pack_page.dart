import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets.dart';
import '../../data/mood.dart';
import '../../data/settings.dart';
import '../../services/pro_service.dart';
import '../paywall/paywall_page.dart';

class MoodPackPage extends StatelessWidget {
  const MoodPackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final settings = context.watch<SettingsController>();
    final isPro = context.watch<ProController>().isPro;
    return Scaffold(
      appBar: AppBar(
        leading: CircleButton(icon: Ph.arrowLeft, onTap: () => Navigator.pop(context), background: Colors.transparent),
        title: Text(context.l.emojiPack),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: MoodPacks.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final pack = MoodPacks.all[i];
          final selected = settings.moodPackId == pack.id;
          final locked = pack.isPro && !isPro;
          return EnterAnimation(
            index: i,
            child: Pressable(
              onTap: () async {
                if (locked && !await ensurePro(context)) return;
                await settings.setMoodPackId(pack.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: selected ? p.accent : Colors.transparent, width: 2.4),
                  boxShadow: p.softShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(pack.name(context.l), style: context.text.titleMedium),
                        const Spacer(),
                        if (locked) const ProBadge(size: 26),
                        if (selected) Icon(PhFill.checkCircle, color: p.accent, size: 26),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.15,
                      children: [for (final m in Mood.values) Center(child: MoodIcon(m, pack: pack, size: 50))],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
