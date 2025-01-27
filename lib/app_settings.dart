import 'package:flutter/material.dart';

import 'provider/word_provider.dart';

class AppSettings extends InheritedNotifier<MySettings> {
  const AppSettings({super.key, required super.notifier, required super.child})
      : assert(notifier != null, 'MySettings is not nullable');

  static MySettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettings>()!.notifier!;
}

class MySettings extends ChangeNotifier {
  int _color = 0;
  Brightness _brightness = Brightness.light;
  WordProvider? _wordProvider;

  int get color => _color;
  set color(int newColor) {
    if (_color == newColor) return;
    _color = newColor;
    notifyListeners();
  }

  Brightness get brightness => _brightness;
  set brightness(Brightness other) {
    if (_brightness == other) return;
    _brightness = other;
    notifyListeners();
  }

  WordProvider? get wordProvider => _wordProvider;
  set wordProvider(WordProvider? other) {
    if (_wordProvider == null && other == null) return;
    if (identical(_wordProvider, other)) return;
    _wordProvider = other;
    notifyListeners();
  }
}
