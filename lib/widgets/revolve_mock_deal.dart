import 'dart:io';
import 'dart:math' show Random;
import 'dart:convert';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RevolveMockDeal extends StatelessWidget {
  const RevolveMockDeal({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRect(
      child: Container(
        height: kMinInteractiveDimensionCupertino,
        alignment: Alignment(0, 0),
        child: StreamBuilder(
          stream: mockBuyerName(),
          builder: (context, snapshot) {
            return AnimatedSwitcher(
              duration: Durations.extralong4,
              transitionBuilder: (child, animation) {
                final start = Offset(
                  0,
                  animation.status == AnimationStatus.dismissed ? 1 : -1,
                );
                final opacity =
                    animation.status == AnimationStatus.dismissed ? 1.0 : .0;
                final curve =
                    animation.status == AnimationStatus.dismissed
                        ? Curves.easeIn
                        : Curves.easeOut;
                return SlideTransition(
                  position: Tween(
                    begin: start,
                    end: Offset.zero,
                  ).animate(animation.drive(CurveTween(curve: curve))),
                  child: FadeTransition(
                    opacity: animation.drive(Tween(begin: opacity, end: 1)),
                    child: child,
                  ),
                );
              },
              child:
                  !snapshot.hasData
                      ? SizedBox.shrink()
                      : Container(
                        key: Key(snapshot.data!),
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        margin: EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: CupertinoDynamicColor.withBrightness(
                            darkColor: Color(0xCCF2F2F2),
                            color: Color(0xBF1E1E1E),
                          ).resolveFrom(context),
                          borderRadius: BorderRadius.circular(
                            (kMinInteractiveDimension - 8) / 2,
                          ),
                        ),
                        child: Text(
                          '${snapshot.data} has joined premium members',
                          style: textTheme.textStyle.apply(
                            color: colorScheme.onInverseSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                      ),
            );
          },
        ),
      ),
    );
  }

  Stream<String?> mockBuyerName() async* {
    final rng = Random();
    for (int i = 0; i < 100; i++) {
      // final delayMilliSecond = rng.nextDouble() * 2e3;
      await Future.delayed(Durations.extralong4 * 1.5);
      // yield null;
      if (rng.nextInt(4) == 0) {
        yield null;
      } else {
        // await Future.delayed(Duration(milliseconds: delayMilliSecond.round()));
        yield await mockName();
      }
    }
    yield null;
  }

  Future<String> mockName() async {
    const locales = [
      'zh_CN',
      'zh_TW',
      'ja_JP',
      'ko_KR',
      'en_US',
      'vi_VN',
      'ar_SA',
    ];
    final rng = Random();
    final locale = locales[rng.nextInt(locales.length)];
    final url = Uri.parse(
      'https://fakerapi.it/api/v2/users?_quantity=1&_locale=$locale',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) throw HttpException(res.body, uri: url);
    final faker = _FakerApi.fromRawJson(res.body);
    if (faker.code != 200) throw ApiException(faker.status);
    final index = locales.indexOf(faker.locale);
    final gap = index > 3 ? ' ' : '';
    return faker.firstName +
        gap +
        faker.lastName.replaceRange(
          0,
          null,
          '*' *
              (rng.nextInt(faker.lastName.length) + 1).clamp(
                1,
                faker.lastName.length,
              ),
        );
  }
}

class _FakerApi {
  String firstName;
  String lastName;
  String status;
  int code;
  String locale;

  _FakerApi({
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.code,
    required this.locale,
  });

  factory _FakerApi.fromRawJson(String str) =>
      _FakerApi.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory _FakerApi.fromJson(Map<String, dynamic> json) => _FakerApi(
    firstName: json["data"][0]["firstname"],
    lastName: json["data"][0]["lastname"],
    status: json["status"],
    code: json["code"],
    locale: json["locale"],
  );

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "status": status,
    "code": code,
    "locale": locale,
  };
}
