import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../models/user_model.dart';
import '../../../providers/user_data_provider.dart';
import '../../../screens/certificates/my_certificates.dart';
import '../../../services/gamification_service.dart';
import '../../../utils/next_screen.dart';

/// Профильдегі геймификация картасы: деңгей, XP прогресс, streak, бейдждер,
/// сертификаттарға өту. settings/gamification өшірілсе көрсетілмейді.
class GamificationCard extends ConsumerWidget {
  const GamificationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    if (user == null) return const SizedBox.shrink();

    final settingsAsync = ref.watch(gamificationSettingsProvider);
    final settings = settingsAsync.valueOrNull ??
        GamificationService.defaults;
    if (settings['enabled'] == false) return const SizedBox.shrink();

    final service = GamificationService()..setCachedSettings(settings);
    if (!service.enabled) return const SizedBox.shrink();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    final xp = user.xp ?? 0;
    final level = service.getLevel(xp);
    final nextLevel = service.getNextLevel(xp);
    final currentThreshold = (level['xpRequired'] as num?)?.toInt() ?? 0;
    final nextThreshold = nextLevel?['xpRequired'] as num?;
    final double progress = nextThreshold == null
        ? 1.0
        : ((xp - currentThreshold) / (nextThreshold.toInt() - currentThreshold))
            .clamp(0.0, 1.0);
    final levelName = service.levelName(context.locale.languageCode, level);
    final nextLevelName = nextLevel == null
        ? null
        : service.levelName(context.locale.languageCode, nextLevel);

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : primaryColor.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level + streak
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${level['level']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          levelName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          nextLevelName == null
                              ? 'max-level'.tr()
                              : 'level-progress'
                                  .tr(namedArgs: {'level': nextLevelName}),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Streak
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            color: Colors.deepOrange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${user.dailyStreak ?? 0}',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // XP progress
              LinearPercentIndicator(
                lineHeight: 10,
                percent: progress,
                backgroundColor:
                    isDarkMode ? Colors.grey[800] : const Color(0xFFE5E7EB),
                progressColor: primaryColor,
                barRadius: const Radius.circular(8),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'xp-total'.tr(namedArgs: {'xp': '$xp'}),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  if (nextThreshold != null)
                    Text(
                      '${nextThreshold.toInt()} XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                ],
              ),
              if (_badges(user, service).isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _badges(user, service)
                      .map((b) => _badgeChip(context, b))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        // Certificates entry
        Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => NextScreen.iOS(context, const MyCertificates()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🏆', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'certificates'.tr(),
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _badges(
      UserModel user, GamificationService service) {
    final earned = user.badges ?? [];
    if (earned.isEmpty) return [];
    final badgeIds = earned.map((e) => e.toString()).toSet();
    return service.badges
        .where((b) => badgeIds.contains(b['id']?.toString()))
        .toList();
  }

  Widget _badgeChip(BuildContext context, Map<String, dynamic> badge) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;
    final name = lang == 'kk'
        ? badge['nameKk']?.toString()
        : lang == 'ru'
            ? badge['nameRu']?.toString()
            : badge['nameEn']?.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isDarkMode ? Colors.grey[800] : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge['icon']?.toString() ?? '🏅', style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 5),
          Text(
            name ?? '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}