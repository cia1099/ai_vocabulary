import 'package:ai_vocabulary/model/acquaintance.dart';
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
  bool _hideSliderTitle = false;
  final targetStudy = ValueNotifier(StudyCount(newCount: 5, reviewCount: 5));
  var overTarget = 0;

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

  bool get hideSliderTitle => _hideSliderTitle;
  set hideSliderTitle(bool isHide) {
    if (_hideSliderTitle ^ isHide) {
      _hideSliderTitle = isHide;
      notifyListeners();
    }
  }

  int get reviewCount => targetStudy.value.reviewCount;
  set reviewCount(int count) {
    targetStudy.value = StudyCount(newCount: learnCount, reviewCount: count);
  }

  int get learnCount => targetStudy.value.newCount;
  set learnCount(int count) {
    targetStudy.value = StudyCount(newCount: count, reviewCount: reviewCount);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
