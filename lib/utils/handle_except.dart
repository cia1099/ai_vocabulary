import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:http/http.dart' as http;

import '../api/dict_api.dart';
import 'shortcut.dart';

String messageExceptions(Object? error) {
  return switch (error) {
    HttpException e => convertFastAPIDetail(e.message),
    ApiException e => 'API error: ${e.message}',
    TimeoutException e =>
      '${e.runtimeType}: ${e.message ?? 'Network request is timeout'}',
    HandshakeException e => '${e.runtimeType}: ${e.message}',
    http.ClientException e => '${e.runtimeType}: ${e.message}',
    SocketException e => '${e.runtimeType}: ${e.message}',
    PlatformException e => '${e.runtimeType}: ${e.message}',
    UnsupportedError e => '${e.runtimeType}: ${e.message}',
    StateError e => '${e.runtimeType}: ${e.message}',
    ArgumentError e => '${e.runtimeType}: ${e.message}',
    FormatException e => '${e.runtimeType}: ${e.message}',
    AssertionError e => '${e.runtimeType}: ${e.message}',
    SqliteException e => 'SQL error(${e.resultCode}): ${e.message}',
    _ => error.toString(),
  };
}

String convertFastAPIDetail(String body) {
  final decode = json.decode(body);
  return decode["detail"] ?? body;
}

class DummyDialog extends StatelessWidget {
  const DummyDialog({super.key, this.msg});
  final String? msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: .3333,
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kCupertinoSheetColor.resolveFrom(context),
              borderRadius: BorderRadius.circular(kRadialReactionRadius / 2),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  const Center(child: CircularProgressIndicator.adaptive()),
                  Align(
                    alignment: const Alignment(0, 1),
                    child: Text(
                      '$msg',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
