import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';

//cmd flutter -t lib/debug/provider_slider.dart

class Provider {
  void Function() rebuild;
  Provider({required this.rebuild}) {
    fetchStudyWords(0).whenComplete(rebuild);
  }

  static const kMaxLength = 16;
  final _stepCount = kMaxLength ~/ 4;
  var _fetchTime = 0, _periodicTime = 0;
  final _studyWords = <String>[];
  Future<void> fetchStudyWords(int index, {bool isReset = false}) async {
    final initCount = 2 * _stepCount; //must lead double step
    if (index ~/ kMaxLength > 0) _periodicTime++;
    if (index % kMaxLength ~/ _stepCount != _fetchTime) return;
    final fetchTime = (_fetchTime + 1) % (kMaxLength ~/ _stepCount);
    final count = _studyWords.isEmpty || isReset
        ? initCount
        : _studyWords.length < kMaxLength
        ? (kMaxLength - _studyWords.length).clamp(0, _stepCount)
        : _stepCount;

    final word = lorem(paragraphs: 1, words: 1);
    final words = List.generate(count, (i) => "($fetchTime: $word)");
    if (isReset) _studyWords.clear();
    if (_studyWords.length < kMaxLength) {
      _studyWords.addAll(words);
      rebuild();
    } else {
      final insertIndex = fetchTime * _stepCount;
      _studyWords.replaceRange(insertIndex, insertIndex + count, words);
    }
    //when request successfully, update _fetchTime
    _fetchTime = fetchTime;
  }
}

class Slider extends StatefulWidget {
  const Slider({super.key});

  @override
  State<Slider> createState() => _SliderState();
}

class _SliderState extends State<Slider> {
  late final provider = Provider(rebuild: () => setState(() {}));
  final pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: PageView.builder(
        itemCount: provider._studyWords.length + 1,
        controller: pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          provider.fetchStudyWords(index).then((_) {
            if (index == Provider.kMaxLength) {
              Future.delayed(Durations.long2, () {
                pageController.jumpToPage(0);
              });
            } else if (index == provider._studyWords.length) {
              print('at max page');
            }
            print("current fetchTime = ${provider._fetchTime} at page $index");
          });
        },
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemBuilder: (context, index) {
          final idx = index % provider._studyWords.length;
          final text =
              "The ${provider._studyWords[idx]} fetch in period ${provider._periodicTime}";
          final words = [
            for (var i = 0; i < provider._studyWords.length; i++)
              provider._studyWords[i].replaceAllMapped(
                RegExp(r"\((\d+):\s*([^\d)]+)\)"),
                (match) {
                  String text = match.group(2)!; // 取出非数字字符串
                  return "($i: $text)";
                },
              ),
          ].join(", ");
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Page: $index", textScaler: TextScaler.linear(3)),
                SizedBox(height: 20),
                Text(text),
                Divider(),
                Text(words),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(CupertinoApp(home: Slider()));
}
