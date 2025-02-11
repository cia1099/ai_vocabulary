import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:http/http.dart' as http;

import '../api/dict_api.dart';

String messageExceptions(Object? error) {
  return switch (error) {
    HttpException e => '${e.runtimeType}: ${e.message}',
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
    _ => error.toString()
  };
}
