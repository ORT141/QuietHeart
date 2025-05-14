import 'package:flutter/cupertino.dart';

String getLanguageSpecificAssetPath(
    BuildContext context, String baseAssetPath) {
  final locale = Localizations.localeOf(context).languageCode;
  String suffix = '';
  if (locale == 'en') {
    suffix = '_en';
  } else if (locale == 'he') {
    suffix = '_he';
  }

  if (suffix.isEmpty) {
    return baseAssetPath;
  }

  int dotIndex = baseAssetPath.lastIndexOf('.');
  if (dotIndex == -1) {
    return baseAssetPath;
  }
  String name = baseAssetPath.substring(0, dotIndex);
  String extension = baseAssetPath.substring(dotIndex);
  return '$name$suffix$extension';
}
