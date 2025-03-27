import 'dart:convert';
import 'dart:io';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/acquaintance.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'provider/word_provider.dart';

class AppSettings extends InheritedNotifier<MySettings> {
  const AppSettings({super.key, required super.notifier, required super.child})
    : assert(notifier != null, 'MySettings is not nullable');

  static MySettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettings>()!.notifier!;
}

class MySettings extends ChangeNotifier {
  //disk variables, will load from setting
  int _colorIndex = 0;
  Brightness _brightness = Brightness.light;
  bool _hideSliderTitle = false;
  final targetStudy = ValueNotifier(StudyCount(newCount: 5, reviewCount: 5));
  //cache variables
  WordProvider? _wordProvider;
  var _studyState = StudyStatus.underTarget;
  int studyMinute = 0;

  File? _file;
  Future<void> loadSetting() async {
    final isReady = await MyDB().isReady;
    if (isReady != true) return;
    if (_file == null) {
      _file ??= File(p.join(MyDB().appDirectory, 'my_settings.json'));
      addListener(() {
        final encoder = JsonEncoder.withIndent(' ' * 4);
        _file!.writeAsString(encoder.convert(toJson()));
      });
      targetStudy.addListener(() {
        final encoder = JsonEncoder.withIndent(' ' * 4);
        _file!.writeAsString(encoder.convert(toJson()));
      });
    }
    await resetCacheOrSignOut();
  }

  Future<void> resetCacheOrSignOut({bool signOut = false}) async {
    _wordProvider = null;
    studyMinute = 0;
    _studyState = StudyStatus.underTarget;
    if (await _file!.exists() && !signOut) {
      final settings =
          json.decode(await _file!.readAsString()) as Map<String, dynamic>;
      readFromJson(settings);
      final studyCount = MyDB().fetchStudyCounts();
      _studyState = nextStatus(studyCount);
      notifyListeners(); //wordProvider will notify but it has latency
    }
  }

  int get colorIndex => _colorIndex;
  set colorIndex(int newColor) {
    if (_colorIndex == newColor) return;
    _colorIndex = newColor;
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

  //StudyState FSM
  StudyStatus get studyState => _studyState;
  set studyState(StudyStatus newStatus) {
    if (_canTransition(newStatus)) {
      _studyState = newStatus;
    } else if (studyState != newStatus) {
      debugPrint("Invaild transition: $_studyState → $newStatus");
    }
  }

  bool _canTransition(StudyStatus newStatus) => switch (studyState) {
    StudyStatus.underTarget =>
      newStatus == StudyStatus.onTarget ||
          newStatus == StudyStatus.completedReview ||
          newStatus == StudyStatus.completedLearn,
    StudyStatus.completedLearn =>
      newStatus == StudyStatus.onTarget || newStatus == StudyStatus.underTarget,
    StudyStatus.completedReview =>
      newStatus == StudyStatus.onTarget || newStatus == StudyStatus.underTarget,
    StudyStatus.onTarget =>
      newStatus == StudyStatus.overTarget ||
          newStatus == StudyStatus.underTarget,
    StudyStatus.overTarget => newStatus == StudyStatus.underTarget,
  };
  StudyStatus nextStatus(StudyCount count) {
    final target = targetStudy.value;
    if (count.reviewCount >= target.reviewCount &&
        count.newCount >= target.newCount) {
      return studyState.index < StudyStatus.onTarget.index
          ? StudyStatus.onTarget
          : StudyStatus.overTarget;
    } else if (count.reviewCount >= target.reviewCount) {
      return StudyStatus.completedReview;
    } else if (count.newCount >= target.newCount) {
      return StudyStatus.completedLearn;
    } else {
      return StudyStatus.underTarget;
    }
  }

  Map<String, dynamic> toJson() => {
    "color_index": colorIndex,
    "brightness": brightness.index,
    "hide_slider_title": hideSliderTitle,
    "target_study": targetStudy.value.toJson(),
  };

  void readFromJson(Map<String, dynamic> json) {
    _colorIndex = json["color_index"];
    _brightness = switch (json["brightness"] as int?) {
      0 => Brightness.dark,
      _ => Brightness.light,
    };
    _hideSliderTitle = json["hide_slider_title"];
    targetStudy.value = StudyCount.fromJson(json["target_study"]);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

enum StudyStatus {
  underTarget,
  completedReview,
  completedLearn,
  onTarget,
  overTarget,
}
