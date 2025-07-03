import 'dart:convert';
import 'dart:io';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/acquaintance.dart';
import 'package:ai_vocabulary/pages/views/matching_word_view.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'provider/word_provider.dart';
import 'utils/enums.dart';

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
  Quiz _quiz = Quiz.cloze;
  final targetStudy = ValueNotifier(StudyCount(newCount: 5, reviewCount: 5));
  var _defaultExplanation = SelectExplanation.explanation;
  var _voicer = AzureVoicer.Ava, _accent = Accent.US;
  var _translator = TranslateLocate.none;
  //cache variables
  final _studyState = ValueNotifier(StudyStatus.underTarget);
  WordProvider? _wordProvider;
  int studyMinute = 0;

  File? _file;
  Future<void> loadSetting() async {
    final isReady = await MyDB().isReady;
    if (isReady != true) return;
    if (_file == null) {
      _file ??= File(p.join(MyDB().appDirectory, 'my_settings.json'));
      addListener(write2Disk);
      targetStudy.addListener(write2Disk);
    }
    await resetCacheOrSignOut();
  }

  Future<void> resetCacheOrSignOut({bool signOut = false}) async {
    _wordProvider = null;
    studyMinute = 0;
    _studyState.value = StudyStatus.underTarget;
    if (!signOut && await _file!.exists()) {
      final settings =
          json.decode(await _file!.readAsString()) as Map<String, dynamic>;
      readFromJson(settings);
      final studyCount = MyDB().fetchStudyCounts();
      _studyState.value = nextStatus(studyCount);
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

  Quiz get quiz => _quiz;
  set quiz(Quiz newQuiz) {
    if (_quiz != newQuiz) {
      _quiz = newQuiz;
      notifyListeners();
    }
  }

  int get reviewCount => targetStudy.value.reviewCount;
  set reviewCount(int count) {
    targetStudy.value = StudyCount(
      newCount: learnCount,
      reviewCount: count.clamp(0, MyDB().fetchReviewWordIDs().length),
    );
  }

  int get learnCount => targetStudy.value.newCount;
  set learnCount(int count) {
    targetStudy.value = StudyCount(newCount: count, reviewCount: reviewCount);
  }

  SelectExplanation get defaultExplanation => _defaultExplanation;
  set defaultExplanation(SelectExplanation newExplanation) {
    _defaultExplanation = newExplanation;
    write2Disk();
  }

  AzureVoicer get voicer => _voicer;
  set voicer(AzureVoicer v) {
    _voicer = v;
    write2Disk();
  }

  Accent get accent => _accent;
  set accent(Accent a) {
    _accent = a;
    write2Disk();
  }

  TranslateLocate get translator => _translator;
  set translator(TranslateLocate tl) {
    _translator = tl;
    write2Disk();
  }

  //StudyState FSM
  ValueNotifier<StudyStatus> get studyStateListener => _studyState;
  StudyStatus get studyState => _studyState.value;
  set studyState(StudyStatus newStatus) {
    if (_canTransition(newStatus)) {
      _studyState.value = newStatus;
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

  void write2Disk() {
    if (_file != null) {
      final encoder = JsonEncoder.withIndent(' ' * 4);
      _file!.writeAsString(encoder.convert(toJson()));
    }
  }

  Map<String, dynamic> toJson() => {
    "color_index": colorIndex,
    "brightness": brightness.index,
    "hide_slider_title": hideSliderTitle,
    "quiz": quiz.index,
    "target_study": targetStudy.value.toJson(),
    "default_explanation": defaultExplanation.index,
    "voicer": voicer.index,
    "accent": accent.index,
    "translator": translator.index,
  };

  void readFromJson(Map<String, dynamic> json) {
    _colorIndex = json["color_index"];
    _brightness = switch (json["brightness"] as int?) {
      0 => Brightness.dark,
      _ => Brightness.light,
    };
    _hideSliderTitle = json["hide_slider_title"];
    targetStudy.value = StudyCount.fromJson(json["target_study"]);
    reviewCount = reviewCount; // clamp maximum by fetchReviewWordIDs
    _defaultExplanation = SelectExplanation.values[json["default_explanation"]];
    _voicer = AzureVoicer.values.elementAt(json["voicer"] ?? 0);
    _accent = Accent.values.elementAt(json["accent"] ?? 0);
    _quiz = Quiz.values.elementAt(json["quiz"] ?? 0);
    _translator = TranslateLocate.values.elementAt(json["translator"] ?? 0);
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
