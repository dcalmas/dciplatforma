import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_settings_provider.dart';
import '../services/app_service.dart';

class PrivacyInfo extends ConsumerWidget {
  const PrivacyInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final String privacyUrl = settings?.privacyUrl ?? 'https://google.com';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Text(
            'Входя или регистрируясь, вы соглашаетесь с',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            runSpacing: 4,
            children: [
              InkWell(
                  onTap: () => AppService().openLinkWithCustomTab(privacyUrl),
                  child: const Text(
                    'Условиями использования',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  )),
              const SizedBox(
                width: 5,
              ),
              const Text('и'),
              const SizedBox(
                width: 5,
              ),
              InkWell(
                  onTap: () => AppService().openLinkWithCustomTab(privacyUrl),
                  child: const Text(
                    'Политикой конфиденциальности',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
