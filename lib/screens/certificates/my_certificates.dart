import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/utils/empty_animation.dart';
import 'package:lms_app/configs/app_assets.dart';

import '../../providers/user_data_provider.dart';
import '../../services/certificate_service.dart';
import '../../utils/next_screen.dart';
import 'certificate_preview.dart';

/// «Менің сертификаттарым» тізімі.
class MyCertificates extends ConsumerWidget {
  const MyCertificates({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    if (user == null) {
      return Scaffold(appBar: AppBar(title: Text('certificates'.tr())));
    }

    final certificates = ref.watch(myCertificatesProvider(user.id));

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
        centerTitle: true,
        title: Text('certificates'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: certificates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('error'.tr())),
        data: (list) {
          if (list.isEmpty) {
            return EmptyAnimation(
              animationString: emptyAnimation,
              title: 'no-certificates'.tr(),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final cert = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.25)
                          : primaryColor.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🏆',
                        style: TextStyle(fontSize: 24)),
                  ),
                  title: Text(
                    cert.courseName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    cert.issuedAt == null
                        ? cert.code
                        : '${'issued-at'.tr()} ${cert.issuedAt!.year}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => NextScreen.iOS(context,
                      CertificatePreview(certificate: cert)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}