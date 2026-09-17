import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/certificate_service.dart';
import '../../utils/snackbars.dart';

/// Бір сертификатты көрсету: код, тексеру/бөлісу сілтемелері.
class CertificatePreview extends ConsumerWidget {
  const CertificatePreview({super.key, required this.certificate});

  final CertificateInfo certificate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final siteUrl = ref.watch(certificateSiteUrlProvider).valueOrNull ??
        CertificateService.fallbackSiteUrl;
    final link = CertificateService.verifyUrl(siteUrl, certificate.code);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
        title: Text('my-certificate'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // Certificate card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('🎓',
                    style: TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(
                  'certificate-of-completion'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  certificate.userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'certificate-course-desc'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  certificate.courseName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        certificate.code,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 1.1),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: certificate.code));
                          openSnackbarSuccess(context, 'copied'.tr());
                        },
                        child: const Icon(Icons.copy_rounded,
                            color: Colors.white, size: 17),
                      ),
                    ],
                  ),
                ),
                if (certificate.issuedAt != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${'issued-at'.tr()} ${certificate.issuedAt!.year}.${certificate.issuedAt!.month.toString().padLeft(2, '0')}.${certificate.issuedAt!.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Verify link
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await launchUrl(Uri.parse(link),
                  mode: LaunchMode.externalApplication);
              if (!ok && context.mounted) openSnackbar(context, 'error'.tr());
            },
            icon: const Icon(Icons.verified_rounded),
            label: Text(
              'verify-certificate'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          // Share link
          FilledButton.icon(
            onPressed: () async {
              await Share.share(
                '${'certificate-share-text'.tr()} $link',
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.share_rounded),
            label: Text(
              'share-certificate'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}