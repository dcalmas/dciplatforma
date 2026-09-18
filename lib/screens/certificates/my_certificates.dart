import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_data_provider.dart';
import '../../services/certificate_service.dart';
import '../../utils/next_screen.dart';
import 'certificate_preview.dart';

const _pink = Color(0xFFF50078);
const _lightBg = Color(0xFFFFF8FC);
const _navy = Color(0xFF1B1E2E);
const _darkBg = Color(0xFF0F111A);
const _darkCard = Color(0xFF1E202C);

/// «Менің сертификаттарым» тізімі.
class MyCertificates extends ConsumerWidget {
  const MyCertificates({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final appBarIconColor = isDarkMode ? Colors.white : _navy;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDarkMode ? _darkBg : _lightBg,
          iconTheme: IconThemeData(color: appBarIconColor),
          title: Text(
            'certificates'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: appBarIconColor,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'login-required'.tr(),
            style: TextStyle(color: isDarkMode ? Colors.white70 : _navy),
          ),
        ),
      );
    }

    final certificates = ref.watch(myCertificatesProvider(user.id));

    return Scaffold(
      backgroundColor: isDarkMode ? _darkBg : _lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? _darkBg : _lightBg,
        centerTitle: true,
        iconTheme: IconThemeData(color: appBarIconColor),
        title: Text(
          'certificates'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: appBarIconColor,
          ),
        ),
      ),
      body: certificates.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _pink),
        ),
        error: (e, s) => Center(
          child: Text(
            'error'.tr(),
            style: TextStyle(color: isDarkMode ? Colors.white70 : _navy),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Сертификат иконкасы (фотосыз)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: _pink.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _pink.withValues(alpha: 0.12),
                            blurRadius: 36,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        size: 84,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'no-certificates'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: isDarkMode ? Colors.white : _navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'complete-courses-to-get-certificates'.tr().isEmpty
                          ? 'Пройдите курсы и получите ваш персональный сертификат!'
                          : 'complete-courses-to-get-certificates'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final cert = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isDarkMode ? _darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDarkMode
                        ? _pink.withValues(alpha: 0.25)
                        : _pink.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.25)
                          : _pink.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => NextScreen.iOS(
                        context, CertificatePreview(certificate: cert)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.3)),
                            ),
                            child: const Text('🏆',
                                style: TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert.courseName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? Colors.white
                                        : _navy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cert.issuedAt == null
                                      ? cert.code
                                      : '${'issued-at'.tr()} ${cert.issuedAt!.year}',
                                  style: const TextStyle(
                                      fontSize: 12.5, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: _pink,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}