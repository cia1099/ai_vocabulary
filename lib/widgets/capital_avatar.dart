import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CapitalAvatar extends StatelessWidget {
  final int id;
  final String name;
  final String? url;
  final TextStyle? style;

  /// CircleAvatar default size is 40.0, because default radius is 20.0
  final double size;

  const CapitalAvatar(
      {super.key,
      required this.id,
      required this.name,
      this.style,
      this.size = 40,
      this.url});

  @override
  Widget build(BuildContext context) {
    var themeIndex = _colorThemeFromNickName(name);
    final colorScheme = Theme.of(context).colorScheme;
    final localTheme = [
      [colorScheme.primaryContainer, colorScheme.onPrimaryContainer],
      [colorScheme.secondaryContainer, colorScheme.onSecondaryContainer],
      [colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer],
      [colorScheme.primary, colorScheme.onPrimary],
      [colorScheme.secondary, colorScheme.onSecondary],
      [colorScheme.tertiary, colorScheme.onTertiary],
    ];
    final avatarColors = List<List<Color>>.from(
        (Theme.of(context).brightness == Brightness.light
                ? localTheme.sublist(0, 3)
                : localTheme.sublist(3)) +
            _avatarThemes);
    themeIndex = id % avatarColors.length;
    final colors = avatarColors[themeIndex];
    final capitalizedName = name.substring(0, 1).toUpperCase();

    return Container(
      constraints: BoxConstraints(maxWidth: size, maxHeight: size),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        shape: BoxShape.circle,
      ),
      foregroundDecoration: url != null
          ? BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: NetworkImage(url!)),
            )
          : null,
      alignment: Alignment.center,
      child: Text(
        capitalizedName,
        style: TextStyle(
          color: CupertinoColors.white,
          fontWeight: FontWeight.w500,
          fontSize: size * 1 / 3,
        ).merge(style),
      ),
    );
  }
}

const _avatarThemes = [
  [Color(0xffFE9D7F), Color(0xffF44545)],
  [Color(0xffFFAE7B), Color(0xffF07F38)],
  [Color(0xffFBC87B), Color(0xffFFA800)],
  [Color(0xffAAF490), Color(0xff52D05E)],
  [Color(0xff85A3F9), Color(0xff5D60F6)],
  [Color(0xff7EC2F4), Color(0xff3B90E1)],
  [Color(0xff6BF0F9), Color(0xff1EAECD)],
  [Color(0xffD784FC), Color(0xffB35AD1)],
];

int _colorThemeFromNickName(String nickName) {
  String md5 = _generateMD5(nickName);
  int index = md5.codeUnitAt(0) % 7;
  return index;
}

String _generateMD5(String data) {
  Uint8List content = const Utf8Encoder().convert(data);
  Digest digest = md5.convert(content);
  return digest.toString();
}
