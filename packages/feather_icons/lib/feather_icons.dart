/// The Flutter Feather Icons Widget.
///
/// To use, import `package:feather_icons/feather_icons.dart`.
///
/// See also:
///
///  * [flutter.dev/widgets](https://flutter.dev/widgets/)
///    for a catalog of commonly-used Flutter widgets.

library feather_icons;

import "package:flutter/widgets.dart";

// icon_data.dart removed - using IconData directly

/// Export [IconData] via map key.
///
/// {@tool snippet}
///
/// ```dart
///
/// FeatherIconsMap['airplay']
///
/// ```
/// {@end-tool}
const Map<String, IconData> FeatherIconsMap = {
  'activity': const IconData(0xe900, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'airplay': const IconData(0xe901, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'alert-circle': const IconData(0xe902, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'alert-octagon': const IconData(0xe903, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'alert-triangle': const IconData(0xe904, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'align-center': const IconData(0xe905, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'align-justify': const IconData(0xe906, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'align-left': const IconData(0xe907, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'align-right': const IconData(0xe908, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'anchor': const IconData(0xe909, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'aperture': const IconData(0xe90a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'archive': const IconData(0xe90b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-down': const IconData(0xe90c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-down-circle': const IconData(0xe90d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-down-left': const IconData(0xe90e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-down-right': const IconData(0xe90f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-left': const IconData(0xe910, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-left-circle': const IconData(0xe911, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-right': const IconData(0xe912, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-right-circle': const IconData(0xe913, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-up': const IconData(0xe914, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-up-circle': const IconData(0xe915, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-up-left': const IconData(0xe916, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'arrow-up-right': const IconData(0xe917, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'at-sign': const IconData(0xe918, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'award': const IconData(0xe919, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'bar-chart': const IconData(0xe91a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'bar-chart-2': const IconData(0xe91b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'battery': const IconData(0xe91c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'battery-charging': const IconData(0xe91d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'bell': const IconData(0xe91e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'bell-off': const IconData(0xe91f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'bluetooth': const IconData(0xe920, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'bold': const IconData(0xe921, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'book': const IconData(0xe922, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'book-open': const IconData(0xe923, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'bookmark': const IconData(0xe924, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'box': const IconData(0xe925, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'briefcase': const IconData(0xe926, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'calendar': const IconData(0xe927, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'camera': const IconData(0xe928, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'camera-off': const IconData(0xe929, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'cast': const IconData(0xe92a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'check': const IconData(0xe92b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'check-circle': const IconData(0xe92c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'check-square': const IconData(0xe92d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chevron-down': const IconData(0xe92e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chevron-left': const IconData(0xe92f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chevron-right': const IconData(0xe930, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chevron-up': const IconData(0xe931, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chevrons-down': const IconData(0xe932, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chevrons-left': const IconData(0xe933, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chevrons-right': const IconData(0xe934, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chevrons-up': const IconData(0xe935, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'chrome': const IconData(0xe936, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'circle': const IconData(0xe937, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'clipboard': const IconData(0xe938, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'clock': const IconData(0xe939, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'cloud': const IconData(0xe93a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'cloud-drizzle': const IconData(0xe93b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'cloud-lightning': const IconData(0xe93c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'cloud-off': const IconData(0xe93d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'cloud-rain': const IconData(0xe93e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'cloud-snow': const IconData(0xe93f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'code': const IconData(0xe940, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'codepen': const IconData(0xe941, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'codesandbox': const IconData(0xe942, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'coffee': const IconData(0xe943, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'columns': const IconData(0xe944, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'command': const IconData(0xe945, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'compass': const IconData(0xe946, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'copy': const IconData(0xe947, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'corner-down-left': const IconData(0xe948, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'corner-down-right': const IconData(0xe949, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'corner-left-down': const IconData(0xe94a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'corner-left-up': const IconData(0xe94b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'corner-right-down': const IconData(0xe94c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'corner-right-up': const IconData(0xe94d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'corner-up-left': const IconData(0xe94e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'corner-up-right': const IconData(0xe94f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'cpu': const IconData(0xe950, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'credit-card': const IconData(0xe951, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'crop': const IconData(0xe952, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'crosshair': const IconData(0xe953, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'database': const IconData(0xe954, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'delete': const IconData(0xe955, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'disc': const IconData(0xe956, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'dollar-sign': const IconData(0xe957, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'download': const IconData(0xe958, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'download-cloud': const IconData(0xe959, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'droplet': const IconData(0xe95a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'edit': const IconData(0xe95b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'edit-2': const IconData(0xe95c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'edit-3': const IconData(0xe95d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'external-link': const IconData(0xe95e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'eye': const IconData(0xe95f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'eye-off': const IconData(0xe960, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'facebook': const IconData(0xe961, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'fast-forward': const IconData(0xe962, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'feather': const IconData(0xe963, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'figma': const IconData(0xe964, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'file': const IconData(0xe965, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'file-minus': const IconData(0xe966, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'file-plus': const IconData(0xe967, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'file-text': const IconData(0xe968, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'film': const IconData(0xe969, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'filter': const IconData(0xe96a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'flag': const IconData(0xe96b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'folder': const IconData(0xe96c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'folder-minus': const IconData(0xe96d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'folder-plus': const IconData(0xe96e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'framer': const IconData(0xe96f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'frown': const IconData(0xe970, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'gift': const IconData(0xe971, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'git-branch': const IconData(0xe972, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'git-commit': const IconData(0xe973, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'git-merge': const IconData(0xe974, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'git-pull-request': const IconData(0xe975, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'github': const IconData(0xe976, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'gitlab': const IconData(0xe977, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'globe': const IconData(0xe978, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'grid': const IconData(0xe979, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'hard-drive': const IconData(0xe97a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'hash': const IconData(0xe97b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'headphones': const IconData(0xe97c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'heart': const IconData(0xe97d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'help-circle': const IconData(0xe97e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'hexagon': const IconData(0xe97f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'home': const IconData(0xe980, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'image': const IconData(0xe981, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'inbox': const IconData(0xe982, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'info': const IconData(0xe983, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'instagram': const IconData(0xe984, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'italic': const IconData(0xe985, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'key': const IconData(0xe986, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'layers': const IconData(0xe987, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'layout': const IconData(0xe988, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'life-buoy': const IconData(0xe989, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'link': const IconData(0xe98a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'link-2': const IconData(0xe98b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'linkedin': const IconData(0xe98c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'list': const IconData(0xe98d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'loader': const IconData(0xe98e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'lock': const IconData(0xe98f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'log-in': const IconData(0xe990, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'log-out': const IconData(0xe991, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'mail': const IconData(0xe992, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'map': const IconData(0xe993, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'map-pin': const IconData(0xe994, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'maximize': const IconData(0xe995, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'maximize-2': const IconData(0xe996, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'meh': const IconData(0xe997, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'menu': const IconData(0xe998, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'message-circle': const IconData(0xe999, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'message-square': const IconData(0xe99a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'mic': const IconData(0xe99b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'mic-off': const IconData(0xe99c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'minimize': const IconData(0xe99d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'minimize-2': const IconData(0xe99e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'minus': const IconData(0xe99f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'minus-circle': const IconData(0xe9a0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'minus-square': const IconData(0xe9a1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'monitor': const IconData(0xe9a2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'moon': const IconData(0xe9a3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'more-horizontal': const IconData(0xe9a4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'more-vertical': const IconData(0xe9a5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'mouse-pointer': const IconData(0xe9a6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'move': const IconData(0xe9a7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'music': const IconData(0xe9a8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'navigation': const IconData(0xe9a9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'navigation-2': const IconData(0xe9aa, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'octagon': const IconData(0xe9ab, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'package': const IconData(0xe9ac, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'paperclip': const IconData(0xe9ad, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'pause': const IconData(0xe9ae, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'pause-circle': const IconData(0xe9af, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'pen-tool': const IconData(0xe9b0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'percent': const IconData(0xe9b1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'phone': const IconData(0xe9b2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'phone-call': const IconData(0xe9b3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'phone-forwarded': const IconData(0xe9b4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'phone-incoming': const IconData(0xe9b5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'phone-missed': const IconData(0xe9b6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'phone-off': const IconData(0xe9b7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'phone-outgoing': const IconData(0xe9b8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'pie-chart': const IconData(0xe9b9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'play': const IconData(0xe9ba, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'play-circle': const IconData(0xe9bb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'plus': const IconData(0xe9bc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'plus-circle': const IconData(0xe9bd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'plus-square': const IconData(0xe9be, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'pocket': const IconData(0xe9bf, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'power': const IconData(0xe9c0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'printer': const IconData(0xe9c1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'radio': const IconData(0xe9c2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'refresh-ccw': const IconData(0xe9c3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'refresh-cw': const IconData(0xe9c4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'repeat': const IconData(0xe9c5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'rewind': const IconData(0xe9c6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'rotate-ccw': const IconData(0xe9c7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'rotate-cw': const IconData(0xe9c8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'rss': const IconData(0xe9c9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'save': const IconData(0xe9ca, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'scissors': const IconData(0xe9cb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'search': const IconData(0xe9cc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'send': const IconData(0xe9cd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'server': const IconData(0xe9ce, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'settings': const IconData(0xe9cf, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'share': const IconData(0xe9d0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'share-2': const IconData(0xe9d1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'shield': const IconData(0xe9d2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'shield-off': const IconData(0xe9d3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'shopping-bag': const IconData(0xe9d4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'shopping-cart': const IconData(0xe9d5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'shuffle': const IconData(0xe9d6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'sidebar': const IconData(0xe9d7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'skip-back': const IconData(0xe9d8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'skip-forward': const IconData(0xe9d9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'slack': const IconData(0xe9da, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'slash': const IconData(0xe9db, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'sliders': const IconData(0xe9dc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'smartphone': const IconData(0xe9dd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'smile': const IconData(0xe9de, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'speaker': const IconData(0xe9df, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'square': const IconData(0xe9e0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'star': const IconData(0xe9e1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'stop-circle': const IconData(0xe9e2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'sun': const IconData(0xe9e3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'sunrise': const IconData(0xe9e4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'sunset': const IconData(0xe9e5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'tablet': const IconData(0xe9e6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'tag': const IconData(0xe9e7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'target': const IconData(0xe9e8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'terminal': const IconData(0xe9e9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'thermometer': const IconData(0xe9ea, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'thumbs-down': const IconData(0xe9eb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'thumbs-up': const IconData(0xe9ec, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'toggle-left': const IconData(0xe9ed, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'toggle-right': const IconData(0xe9ee, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'tool': const IconData(0xe9ef, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'trash': const IconData(0xe9f0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'trash-2': const IconData(0xe9f1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'trello': const IconData(0xe9f2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'trending-down': const IconData(0xe9f3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'trending-up': const IconData(0xe9f4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'triangle': const IconData(0xe9f5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'truck': const IconData(0xe9f6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'tv': const IconData(0xe9f7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'twitch': const IconData(0xe9f8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'twitter': const IconData(0xe9f9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'type': const IconData(0xe9fa, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'umbrella': const IconData(0xe9fb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'underline': const IconData(0xe9fc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'unlock': const IconData(0xe9fd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'upload': const IconData(0xe9fe, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'upload-cloud': const IconData(0xe9ff, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'user': const IconData(0xea00, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'user-check': const IconData(0xea01, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'user-minus': const IconData(0xea02, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'user-plus': const IconData(0xea03, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'user-x': const IconData(0xea04, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'users': const IconData(0xea05, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'video': const IconData(0xea06, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'video-off': const IconData(0xea07, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'voicemail': const IconData(0xea08, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'volume': const IconData(0xea09, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'volume-1': const IconData(0xea0a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'volume-2': const IconData(0xea0b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'volume-x': const IconData(0xea0c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'watch': const IconData(0xea0d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'wifi': const IconData(0xea0e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'wifi-off': const IconData(0xea0f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'wind': const IconData(0xea10, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'x': const IconData(0xea11, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'x-circle': const IconData(0xea12, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'x-octagon': const IconData(0xea13, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'x-square': const IconData(0xea14, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'youtube': const IconData(0xea15, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'zap': const IconData(0xea16, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'zap-off': const IconData(0xea17, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'zoom-in': const IconData(0xea18, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
  'zoom-out': const IconData(0xea19, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true),
};

/// Export [IconData] via Camel Case property
///
/// {@tool snippet}
///
/// ```dart
///
/// FeatherIcons.alignCenter
///
/// ```
/// {@end-tool}
class FeatherIcons {
  static const IconData activity = const IconData(0xe900, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData airplay = const IconData(0xe901, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alertCircle = const IconData(0xe902, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alertOctagon = const IconData(0xe903, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alertTriangle = const IconData(0xe904, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alignCenter = const IconData(0xe905, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alignJustify = const IconData(0xe906, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alignLeft = const IconData(0xe907, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alignRight = const IconData(0xe908, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData anchor = const IconData(0xe909, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData aperture = const IconData(0xe90a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData archive = const IconData(0xe90b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowDown = const IconData(0xe90c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowDownCircle = const IconData(0xe90d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowDownLeft = const IconData(0xe90e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowDownRight = const IconData(0xe90f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowLeft = const IconData(0xe910, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowLeftCircle = const IconData(0xe911, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowRight = const IconData(0xe912, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowRightCircle = const IconData(0xe913, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowUp = const IconData(0xe914, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowUpCircle = const IconData(0xe915, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowUpLeft = const IconData(0xe916, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrowUpRight = const IconData(0xe917, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData atSign = const IconData(0xe918, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData award = const IconData(0xe919, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData barChart = const IconData(0xe91a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData barChart2 = const IconData(0xe91b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData battery = const IconData(0xe91c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData batteryCharging = const IconData(0xe91d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bell = const IconData(0xe91e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bellOff = const IconData(0xe91f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bluetooth = const IconData(0xe920, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bold = const IconData(0xe921, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData book = const IconData(0xe922, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bookOpen = const IconData(0xe923, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bookmark = const IconData(0xe924, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData box = const IconData(0xe925, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData briefcase = const IconData(0xe926, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData calendar = const IconData(0xe927, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData camera = const IconData(0xe928, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cameraOff = const IconData(0xe929, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cast = const IconData(0xe92a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData check = const IconData(0xe92b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData checkCircle = const IconData(0xe92c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData checkSquare = const IconData(0xe92d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevronDown = const IconData(0xe92e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevronLeft = const IconData(0xe92f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevronRight = const IconData(0xe930, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevronUp = const IconData(0xe931, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevronsDown = const IconData(0xe932, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevronsLeft = const IconData(0xe933, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevronsRight = const IconData(0xe934, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevronsUp = const IconData(0xe935, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chrome = const IconData(0xe936, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData circle = const IconData(0xe937, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData clipboard = const IconData(0xe938, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData clock = const IconData(0xe939, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloud = const IconData(0xe93a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloudDrizzle = const IconData(0xe93b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloudLightning = const IconData(0xe93c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloudOff = const IconData(0xe93d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloudRain = const IconData(0xe93e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloudSnow = const IconData(0xe93f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData code = const IconData(0xe940, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData codepen = const IconData(0xe941, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData codesandbox = const IconData(0xe942, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData coffee = const IconData(0xe943, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData columns = const IconData(0xe944, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData command = const IconData(0xe945, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData compass = const IconData(0xe946, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData copy = const IconData(0xe947, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cornerDownLeft = const IconData(0xe948, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cornerDownRight = const IconData(0xe949, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cornerLeftDown = const IconData(0xe94a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cornerLeftUp = const IconData(0xe94b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cornerRightDown = const IconData(0xe94c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cornerRightUp = const IconData(0xe94d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cornerUpLeft = const IconData(0xe94e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cornerUpRight = const IconData(0xe94f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cpu = const IconData(0xe950, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData creditCard = const IconData(0xe951, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData crop = const IconData(0xe952, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData crosshair = const IconData(0xe953, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData database = const IconData(0xe954, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData delete = const IconData(0xe955, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData disc = const IconData(0xe956, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData dollarSign = const IconData(0xe957, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData download = const IconData(0xe958, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData downloadCloud = const IconData(0xe959, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData droplet = const IconData(0xe95a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData edit = const IconData(0xe95b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData edit2 = const IconData(0xe95c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData edit3 = const IconData(0xe95d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData externalLink = const IconData(0xe95e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData eye = const IconData(0xe95f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData eyeOff = const IconData(0xe960, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData facebook = const IconData(0xe961, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData fastForward = const IconData(0xe962, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData feather = const IconData(0xe963, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData figma = const IconData(0xe964, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData file = const IconData(0xe965, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData fileMinus = const IconData(0xe966, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData filePlus = const IconData(0xe967, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData fileText = const IconData(0xe968, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData film = const IconData(0xe969, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData filter = const IconData(0xe96a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData flag = const IconData(0xe96b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData folder = const IconData(0xe96c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData folderMinus = const IconData(0xe96d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData folderPlus = const IconData(0xe96e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData framer = const IconData(0xe96f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData frown = const IconData(0xe970, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData gift = const IconData(0xe971, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData gitBranch = const IconData(0xe972, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData gitCommit = const IconData(0xe973, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData gitMerge = const IconData(0xe974, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData gitPullRequest = const IconData(0xe975, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData github = const IconData(0xe976, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData gitlab = const IconData(0xe977, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData globe = const IconData(0xe978, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData grid = const IconData(0xe979, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData hardDrive = const IconData(0xe97a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData hash = const IconData(0xe97b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData headphones = const IconData(0xe97c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData heart = const IconData(0xe97d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData helpCircle = const IconData(0xe97e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData hexagon = const IconData(0xe97f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData home = const IconData(0xe980, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData image = const IconData(0xe981, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData inbox = const IconData(0xe982, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData info = const IconData(0xe983, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData instagram = const IconData(0xe984, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData italic = const IconData(0xe985, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData key = const IconData(0xe986, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData layers = const IconData(0xe987, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData layout = const IconData(0xe988, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData lifeBuoy = const IconData(0xe989, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData link = const IconData(0xe98a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData link2 = const IconData(0xe98b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData linkedin = const IconData(0xe98c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData list = const IconData(0xe98d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData loader = const IconData(0xe98e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData lock = const IconData(0xe98f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData logIn = const IconData(0xe990, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData logOut = const IconData(0xe991, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData mail = const IconData(0xe992, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData map = const IconData(0xe993, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData mapPin = const IconData(0xe994, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData maximize = const IconData(0xe995, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData maximize2 = const IconData(0xe996, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData meh = const IconData(0xe997, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData menu = const IconData(0xe998, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData messageCircle = const IconData(0xe999, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData messageSquare = const IconData(0xe99a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData mic = const IconData(0xe99b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData micOff = const IconData(0xe99c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minimize = const IconData(0xe99d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minimize2 = const IconData(0xe99e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minus = const IconData(0xe99f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minusCircle = const IconData(0xe9a0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minusSquare = const IconData(0xe9a1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData monitor = const IconData(0xe9a2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData moon = const IconData(0xe9a3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData moreHorizontal = const IconData(0xe9a4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData moreVertical = const IconData(0xe9a5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData mousePointer = const IconData(0xe9a6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData move = const IconData(0xe9a7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData music = const IconData(0xe9a8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData navigation = const IconData(0xe9a9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData navigation2 = const IconData(0xe9aa, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData octagon = const IconData(0xe9ab, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData package = const IconData(0xe9ac, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData paperclip = const IconData(0xe9ad, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pause = const IconData(0xe9ae, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pauseCircle = const IconData(0xe9af, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData penTool = const IconData(0xe9b0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData percent = const IconData(0xe9b1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phone = const IconData(0xe9b2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phoneCall = const IconData(0xe9b3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phoneForwarded = const IconData(0xe9b4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phoneIncoming = const IconData(0xe9b5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phoneMissed = const IconData(0xe9b6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phoneOff = const IconData(0xe9b7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phoneOutgoing = const IconData(0xe9b8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pieChart = const IconData(0xe9b9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData play = const IconData(0xe9ba, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData playCircle = const IconData(0xe9bb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData plus = const IconData(0xe9bc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData plusCircle = const IconData(0xe9bd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData plusSquare = const IconData(0xe9be, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pocket = const IconData(0xe9bf, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData power = const IconData(0xe9c0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData printer = const IconData(0xe9c1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData radio = const IconData(0xe9c2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData refreshCcw = const IconData(0xe9c3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData refreshCw = const IconData(0xe9c4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData repeat = const IconData(0xe9c5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData rewind = const IconData(0xe9c6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData rotateCcw = const IconData(0xe9c7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData rotateCw = const IconData(0xe9c8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData rss = const IconData(0xe9c9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData save = const IconData(0xe9ca, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData scissors = const IconData(0xe9cb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData search = const IconData(0xe9cc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData send = const IconData(0xe9cd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData server = const IconData(0xe9ce, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData settings = const IconData(0xe9cf, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData share = const IconData(0xe9d0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData share2 = const IconData(0xe9d1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shield = const IconData(0xe9d2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shieldOff = const IconData(0xe9d3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shoppingBag = const IconData(0xe9d4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shoppingCart = const IconData(0xe9d5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shuffle = const IconData(0xe9d6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sidebar = const IconData(0xe9d7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData skipBack = const IconData(0xe9d8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData skipForward = const IconData(0xe9d9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData slack = const IconData(0xe9da, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData slash = const IconData(0xe9db, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sliders = const IconData(0xe9dc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData smartphone = const IconData(0xe9dd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData smile = const IconData(0xe9de, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData speaker = const IconData(0xe9df, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData square = const IconData(0xe9e0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData star = const IconData(0xe9e1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData stopCircle = const IconData(0xe9e2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sun = const IconData(0xe9e3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sunrise = const IconData(0xe9e4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sunset = const IconData(0xe9e5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData tablet = const IconData(0xe9e6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData tag = const IconData(0xe9e7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData target = const IconData(0xe9e8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData terminal = const IconData(0xe9e9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData thermometer = const IconData(0xe9ea, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData thumbsDown = const IconData(0xe9eb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData thumbsUp = const IconData(0xe9ec, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData toggleLeft = const IconData(0xe9ed, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData toggleRight = const IconData(0xe9ee, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData tool = const IconData(0xe9ef, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trash = const IconData(0xe9f0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trash2 = const IconData(0xe9f1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trello = const IconData(0xe9f2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trendingDown = const IconData(0xe9f3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trendingUp = const IconData(0xe9f4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData triangle = const IconData(0xe9f5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData truck = const IconData(0xe9f6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData tv = const IconData(0xe9f7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData twitch = const IconData(0xe9f8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData twitter = const IconData(0xe9f9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData type = const IconData(0xe9fa, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData umbrella = const IconData(0xe9fb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData underline = const IconData(0xe9fc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData unlock = const IconData(0xe9fd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData upload = const IconData(0xe9fe, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData uploadCloud = const IconData(0xe9ff, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData user = const IconData(0xea00, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData userCheck = const IconData(0xea01, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData userMinus = const IconData(0xea02, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData userPlus = const IconData(0xea03, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData userX = const IconData(0xea04, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData users = const IconData(0xea05, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData video = const IconData(0xea06, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData videoOff = const IconData(0xea07, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData voicemail = const IconData(0xea08, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData volume = const IconData(0xea09, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData volume1 = const IconData(0xea0a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData volume2 = const IconData(0xea0b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData volumeX = const IconData(0xea0c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData watch = const IconData(0xea0d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData wifi = const IconData(0xea0e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData wifiOff = const IconData(0xea0f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData wind = const IconData(0xea10, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData x = const IconData(0xea11, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData xCircle = const IconData(0xea12, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData xOctagon = const IconData(0xea13, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData xSquare = const IconData(0xea14, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData youtube = const IconData(0xea15, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData zap = const IconData(0xea16, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData zapOff = const IconData(0xea17, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData zoomIn = const IconData(0xea18, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData zoomOut = const IconData(0xea19, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
}

/// Export [IconData] via Snake Case property
///
/// {@tool snippet}
///
/// ```dart
///
/// FeatherIcons.align_right
///
/// ```
/// {@end-tool}
class FeatherIconsSnakeCase {
  static const IconData activity = const IconData(0xe900, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData airplay = const IconData(0xe901, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alert_circle = const IconData(0xe902, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alert_octagon = const IconData(0xe903, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData alert_triangle = const IconData(0xe904, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData align_center = const IconData(0xe905, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData align_justify = const IconData(0xe906, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData align_left = const IconData(0xe907, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData align_right = const IconData(0xe908, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData anchor = const IconData(0xe909, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData aperture = const IconData(0xe90a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData archive = const IconData(0xe90b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_down = const IconData(0xe90c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_down_circle = const IconData(0xe90d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_down_left = const IconData(0xe90e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_down_right = const IconData(0xe90f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_left = const IconData(0xe910, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_left_circle = const IconData(0xe911, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_right = const IconData(0xe912, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_right_circle = const IconData(0xe913, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_up = const IconData(0xe914, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_up_circle = const IconData(0xe915, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_up_left = const IconData(0xe916, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData arrow_up_right = const IconData(0xe917, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData at_sign = const IconData(0xe918, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData award = const IconData(0xe919, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bar_chart = const IconData(0xe91a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bar_chart_2 = const IconData(0xe91b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData battery = const IconData(0xe91c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData battery_charging = const IconData(0xe91d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bell = const IconData(0xe91e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bell_off = const IconData(0xe91f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bluetooth = const IconData(0xe920, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bold = const IconData(0xe921, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData book = const IconData(0xe922, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData book_open = const IconData(0xe923, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData bookmark = const IconData(0xe924, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData box = const IconData(0xe925, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData briefcase = const IconData(0xe926, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData calendar = const IconData(0xe927, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData camera = const IconData(0xe928, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData camera_off = const IconData(0xe929, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cast = const IconData(0xe92a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData check = const IconData(0xe92b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData check_circle = const IconData(0xe92c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData check_square = const IconData(0xe92d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevron_down = const IconData(0xe92e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevron_left = const IconData(0xe92f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevron_right = const IconData(0xe930, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevron_up = const IconData(0xe931, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevrons_down = const IconData(0xe932, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevrons_left = const IconData(0xe933, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevrons_right = const IconData(0xe934, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chevrons_up = const IconData(0xe935, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData chrome = const IconData(0xe936, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData circle = const IconData(0xe937, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData clipboard = const IconData(0xe938, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData clock = const IconData(0xe939, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloud = const IconData(0xe93a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloud_drizzle = const IconData(0xe93b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloud_lightning = const IconData(0xe93c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloud_off = const IconData(0xe93d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloud_rain = const IconData(0xe93e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cloud_snow = const IconData(0xe93f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData code = const IconData(0xe940, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData codepen = const IconData(0xe941, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData codesandbox = const IconData(0xe942, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData coffee = const IconData(0xe943, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData columns = const IconData(0xe944, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData command = const IconData(0xe945, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData compass = const IconData(0xe946, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData copy = const IconData(0xe947, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData corner_down_left = const IconData(0xe948, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData corner_down_right = const IconData(0xe949, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData corner_left_down = const IconData(0xe94a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData corner_left_up = const IconData(0xe94b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData corner_right_down = const IconData(0xe94c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData corner_right_up = const IconData(0xe94d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData corner_up_left = const IconData(0xe94e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData corner_up_right = const IconData(0xe94f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData cpu = const IconData(0xe950, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData credit_card = const IconData(0xe951, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData crop = const IconData(0xe952, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData crosshair = const IconData(0xe953, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData database = const IconData(0xe954, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData delete = const IconData(0xe955, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData disc = const IconData(0xe956, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData dollar_sign = const IconData(0xe957, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData download = const IconData(0xe958, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData download_cloud = const IconData(0xe959, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData droplet = const IconData(0xe95a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData edit = const IconData(0xe95b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData edit_2 = const IconData(0xe95c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData edit_3 = const IconData(0xe95d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData external_link = const IconData(0xe95e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData eye = const IconData(0xe95f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData eye_off = const IconData(0xe960, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData facebook = const IconData(0xe961, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData fast_forward = const IconData(0xe962, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData feather = const IconData(0xe963, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData figma = const IconData(0xe964, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData file = const IconData(0xe965, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData file_minus = const IconData(0xe966, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData file_plus = const IconData(0xe967, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData file_text = const IconData(0xe968, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData film = const IconData(0xe969, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData filter = const IconData(0xe96a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData flag = const IconData(0xe96b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData folder = const IconData(0xe96c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData folder_minus = const IconData(0xe96d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData folder_plus = const IconData(0xe96e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData framer = const IconData(0xe96f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData frown = const IconData(0xe970, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData gift = const IconData(0xe971, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData git_branch = const IconData(0xe972, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData git_commit = const IconData(0xe973, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData git_merge = const IconData(0xe974, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData git_pull_request = const IconData(0xe975, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData github = const IconData(0xe976, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData gitlab = const IconData(0xe977, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData globe = const IconData(0xe978, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData grid = const IconData(0xe979, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData hard_drive = const IconData(0xe97a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData hash = const IconData(0xe97b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData headphones = const IconData(0xe97c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData heart = const IconData(0xe97d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData help_circle = const IconData(0xe97e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData hexagon = const IconData(0xe97f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData home = const IconData(0xe980, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData image = const IconData(0xe981, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData inbox = const IconData(0xe982, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData info = const IconData(0xe983, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData instagram = const IconData(0xe984, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData italic = const IconData(0xe985, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData key = const IconData(0xe986, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData layers = const IconData(0xe987, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData layout = const IconData(0xe988, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData life_buoy = const IconData(0xe989, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData link = const IconData(0xe98a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData link_2 = const IconData(0xe98b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData linkedin = const IconData(0xe98c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData list = const IconData(0xe98d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData loader = const IconData(0xe98e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData lock = const IconData(0xe98f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData log_in = const IconData(0xe990, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData log_out = const IconData(0xe991, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData mail = const IconData(0xe992, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData map = const IconData(0xe993, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData map_pin = const IconData(0xe994, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData maximize = const IconData(0xe995, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData maximize_2 = const IconData(0xe996, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData meh = const IconData(0xe997, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData menu = const IconData(0xe998, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData message_circle = const IconData(0xe999, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData message_square = const IconData(0xe99a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData mic = const IconData(0xe99b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData mic_off = const IconData(0xe99c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minimize = const IconData(0xe99d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minimize_2 = const IconData(0xe99e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minus = const IconData(0xe99f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minus_circle = const IconData(0xe9a0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData minus_square = const IconData(0xe9a1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData monitor = const IconData(0xe9a2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData moon = const IconData(0xe9a3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData more_horizontal = const IconData(0xe9a4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData more_vertical = const IconData(0xe9a5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData mouse_pointer = const IconData(0xe9a6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData move = const IconData(0xe9a7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData music = const IconData(0xe9a8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData navigation = const IconData(0xe9a9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData navigation_2 = const IconData(0xe9aa, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData octagon = const IconData(0xe9ab, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData package = const IconData(0xe9ac, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData paperclip = const IconData(0xe9ad, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pause = const IconData(0xe9ae, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pause_circle = const IconData(0xe9af, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pen_tool = const IconData(0xe9b0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData percent = const IconData(0xe9b1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phone = const IconData(0xe9b2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phone_call = const IconData(0xe9b3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phone_forwarded = const IconData(0xe9b4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phone_incoming = const IconData(0xe9b5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phone_missed = const IconData(0xe9b6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phone_off = const IconData(0xe9b7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData phone_outgoing = const IconData(0xe9b8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pie_chart = const IconData(0xe9b9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData play = const IconData(0xe9ba, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData play_circle = const IconData(0xe9bb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData plus = const IconData(0xe9bc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData plus_circle = const IconData(0xe9bd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData plus_square = const IconData(0xe9be, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData pocket = const IconData(0xe9bf, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData power = const IconData(0xe9c0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData printer = const IconData(0xe9c1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData radio = const IconData(0xe9c2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData refresh_ccw = const IconData(0xe9c3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData refresh_cw = const IconData(0xe9c4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData repeat = const IconData(0xe9c5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData rewind = const IconData(0xe9c6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData rotate_ccw = const IconData(0xe9c7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData rotate_cw = const IconData(0xe9c8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData rss = const IconData(0xe9c9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData save = const IconData(0xe9ca, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData scissors = const IconData(0xe9cb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData search = const IconData(0xe9cc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData send = const IconData(0xe9cd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData server = const IconData(0xe9ce, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData settings = const IconData(0xe9cf, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData share = const IconData(0xe9d0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData share_2 = const IconData(0xe9d1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shield = const IconData(0xe9d2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shield_off = const IconData(0xe9d3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shopping_bag = const IconData(0xe9d4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shopping_cart = const IconData(0xe9d5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData shuffle = const IconData(0xe9d6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sidebar = const IconData(0xe9d7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData skip_back = const IconData(0xe9d8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData skip_forward = const IconData(0xe9d9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData slack = const IconData(0xe9da, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData slash = const IconData(0xe9db, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sliders = const IconData(0xe9dc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData smartphone = const IconData(0xe9dd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData smile = const IconData(0xe9de, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData speaker = const IconData(0xe9df, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData square = const IconData(0xe9e0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData star = const IconData(0xe9e1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData stop_circle = const IconData(0xe9e2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sun = const IconData(0xe9e3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sunrise = const IconData(0xe9e4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData sunset = const IconData(0xe9e5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData tablet = const IconData(0xe9e6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData tag = const IconData(0xe9e7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData target = const IconData(0xe9e8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData terminal = const IconData(0xe9e9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData thermometer = const IconData(0xe9ea, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData thumbs_down = const IconData(0xe9eb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData thumbs_up = const IconData(0xe9ec, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData toggle_left = const IconData(0xe9ed, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData toggle_right = const IconData(0xe9ee, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData tool = const IconData(0xe9ef, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trash = const IconData(0xe9f0, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trash_2 = const IconData(0xe9f1, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trello = const IconData(0xe9f2, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trending_down = const IconData(0xe9f3, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData trending_up = const IconData(0xe9f4, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData triangle = const IconData(0xe9f5, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData truck = const IconData(0xe9f6, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData tv = const IconData(0xe9f7, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData twitch = const IconData(0xe9f8, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData twitter = const IconData(0xe9f9, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData type = const IconData(0xe9fa, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData umbrella = const IconData(0xe9fb, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData underline = const IconData(0xe9fc, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData unlock = const IconData(0xe9fd, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData upload = const IconData(0xe9fe, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData upload_cloud = const IconData(0xe9ff, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData user = const IconData(0xea00, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData user_check = const IconData(0xea01, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData user_minus = const IconData(0xea02, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData user_plus = const IconData(0xea03, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData user_x = const IconData(0xea04, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData users = const IconData(0xea05, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData video = const IconData(0xea06, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData video_off = const IconData(0xea07, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData voicemail = const IconData(0xea08, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData volume = const IconData(0xea09, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData volume_1 = const IconData(0xea0a, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData volume_2 = const IconData(0xea0b, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData volume_x = const IconData(0xea0c, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData watch = const IconData(0xea0d, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData wifi = const IconData(0xea0e, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData wifi_off = const IconData(0xea0f, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData wind = const IconData(0xea10, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData x = const IconData(0xea11, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData x_circle = const IconData(0xea12, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData x_octagon = const IconData(0xea13, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData x_square = const IconData(0xea14, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData youtube = const IconData(0xea15, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData zap = const IconData(0xea16, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData zap_off = const IconData(0xea17, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData zoom_in = const IconData(0xea18, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
  static const IconData zoom_out = const IconData(0xea19, fontFamily: 'Feather', fontPackage: 'feather_icons', matchTextDirection: true);
}
