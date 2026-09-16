import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/constants/custom_colors.dart';
import 'package:lms_app/theme/theme_provider.dart';

import '../services/app_service.dart';
import '../utils/image_preview.dart';
import '../utils/next_screen.dart';
import 'video_player_widget.dart';

class HtmlBody extends ConsumerWidget {
  const HtmlBody({
    super.key,
    required this.description,
    this.fontSize,
    this.compact = false,
  });

  final String description;
  final double? fontSize;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    return Html(
      data: description,
      shrinkWrap: true,
      onLinkTap: (url, _, __) {
        AppService().openLinkWithCustomTab(url!);
      },
      style: {
        "body": Style(
          padding: compact ? HtmlPaddings.zero : HtmlPaddings.only(bottom: 20),
          margin: Margins.zero,
          lineHeight: LineHeight(compact ? 1.55 : 1.8),
          whiteSpace: WhiteSpace.normal,
          fontSize: FontSize(fontSize ?? 17),
          color: isDarkMode
              ? CustomColor.paragraphColorDark
              : CustomColor.paragraphColor,
          fontWeight: FontWeight.w400,
        ),
        "figure, video, div, img":
            Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        "p": Style(
          padding: compact || AppService.isHTML(description)
              ? HtmlPaddings.zero
              : HtmlPaddings.only(left: 20, right: 20, top: 5, bottom: 5),
          margin: compact ? Margins.only(bottom: 10) : null,
        ),
        "h1,h2,h3,h4,h5,h6": Style(
          padding: compact
              ? HtmlPaddings.zero
              : HtmlPaddings.only(left: 20, right: 20),
          margin: compact ? Margins.only(top: 4, bottom: 10) : null,
          fontSize: compact ? FontSize(18) : null,
          fontWeight: compact ? FontWeight.w600 : null,
          lineHeight: compact ? const LineHeight(1.35) : null,
        ),
        if (compact) "strong,b": Style(fontWeight: FontWeight.w600),
      },
      extensions: [
        if (compact)
          TagExtension(
            tagsToExtend: {'pre'},
            builder: (extension) => Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF141824)
                    : const Color(0xFFF4F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(extension.element?.text ?? '',
                    style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.5,
                        color: isDarkMode
                            ? Colors.grey.shade200
                            : const Color(0xFF334155))),
              ),
            ),
          ),
        TagExtension(
          tagsToExtend: {"iframe"},
          builder: (ExtensionContext eContext) {
            final String videoSource = eContext.attributes['src'].toString();
            if (videoSource.contains('youtu') ||
                videoSource.contains('vimeo')) {
              return VideoPlayerWidget(videoUrl: videoSource);
            }
            return Container();
          },
        ),
        TagExtension(
          tagsToExtend: {"video"},
          builder: (ExtensionContext eContext) {
            final String videoSource = eContext.attributes['src'].toString();
            return VideoPlayerWidget(videoUrl: videoSource);
          },
        ),
        TagExtension(
          tagsToExtend: {"img"},
          builder: (ExtensionContext eContext) {
            String imageUrl = eContext.attributes['src'].toString();
            return InkWell(
              onTap: () =>
                  NextScreen.iOS(context, FullImagePreview(imageUrl: imageUrl)),
              child: CachedNetworkImage(imageUrl: imageUrl),
            );
          },
        ),
      ],
    );
  }
}
