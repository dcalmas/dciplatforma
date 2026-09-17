import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lms_app/configs/app_config.dart';
import 'package:lms_app/models/review.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/toasts.dart';

class AppService {
  Future openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: "Can't launch the url");
    }
  }

  Future openEmailSupport(String supportEmail) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=About ${AppConfig.appName}&body=',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      openToast1("Can't open the email app");
    }
  }

  Future openReviewReportEmail(context, Review review, UserModel? user, String supportEmail) async {
    final String userName = user != null ? user.name : 'An user';
    final Uri uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query:
          'subject=${AppConfig.appName} - Review Report&body=$userName has reported on a Review on ${review.courseTitle}.\n\nReported Review: ${review.review}\nUser Id: ${user?.id}\nUser Email: ${user?.email}\n',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      openToast1("Can't open the email app");
    }
  }

  Future openLinkWithCustomTab(String url) async {
    try {
      await FlutterWebBrowser.openWebPage(
        url: url,
        customTabsOptions: const CustomTabsOptions(
          colorScheme: CustomTabsColorScheme.system,
          //addDefaultShareMenuItem: true,
          instantAppsEnabled: true,
          showTitle: true,
          urlBarHidingEnabled: true,
        ),
        safariVCOptions: const SafariViewControllerOptions(
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
          modalPresentationCapturesStatusBarAppearance: true,
        ),
      );
    } catch (e) {
      openToast1('Cant launch the url');
      debugPrint(e.toString());
    }
  }

  Future launchAppReview(context) async {
    await StoreRedirect.redirect(androidAppId: AppConfig.androidPackageName, iOSAppId: AppConfig.iosAppID);
    if (Platform.isIOS) {
      if (AppConfig.iosAppID == '000000') {
        openToast("The iOS version is not available on the AppStore yet");
      }
    }
  }

  static String cleanVideoUrl(String input) {
    if (input.isEmpty) return '';

    // If it's not an iframe, return as is
    if (!input.contains('src=')) return input;

    try {
      // Manual extraction to avoid RegExp syntax errors during compilation
      int srcIndex = input.indexOf('src=');
      if (srcIndex == -1) return input;

      // Find the first quote after 'src='
      int quoteStart = -1;
      for (int i = srcIndex + 4; i < input.length; i++) {
        if (input[i] == '"' || input[i] == '\'') {
          quoteStart = i;
          break;
        }
      }

      if (quoteStart == -1) return input;

      final String quoteChar = input[quoteStart];
      int quoteEnd = input.indexOf(quoteChar, quoteStart + 1);

      if (quoteEnd == -1) return input;

      return input.substring(quoteStart + 1, quoteEnd);
    } catch (e) {
      return input;
    }
  }

  static String getVideoType(String videoSource) {
    final cleanUrl = cleanVideoUrl(videoSource);
    if (cleanUrl.contains('youtu')) {
      return 'youtube';
    } else if (cleanUrl.contains('vimeo')) {
      return 'vimeo';
    } else {
      return 'network';
    }
  }

  static void confiugureStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  static String getDateTime(DateTime dateTime) {
    var format = DateFormat('dd MMMM, yyyy hh:mm a');
    return format.format(dateTime.toLocal());
  }

  static String getDate(DateTime date) {
    var format = DateFormat('dd MMMM yyyy');
    return format.format(date.toLocal());
  }

  static bool isDarkMode(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return true;
    } else {
      return false;
    }
  }

  static bool isHTML(String str) {
    final RegExp htmlRegExp = RegExp('<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlRegExp.hasMatch(str);
  }

  static String getTodaysID() {
    return DateTime.now().toUtc().toString().split(' ')[0].replaceAll('-', '');
  }

  static void svgPrecacheImage() {
    // Intro суреттері PNG — SVG парсермен precache жасалмайды
    // (бұрын XmlParserException беріп, unhandled exception шығатын).
    // Image.asset өз кэшін қолданады, қосымша precache қажет емес.
  }
}
