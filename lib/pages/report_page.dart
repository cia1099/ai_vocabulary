import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.word});
  final Vocabulary word;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final selectIndex = <int>{};
  final enableSubmit = ValueNotifier(false);
  final textEditController = TextEditingController();
  var issue = '';

  void toggleSelection([int? value]) {
    if (value != null && !selectIndex.add(value)) selectIndex.remove(value);
    final txtList = [textEditController.text.trim()];
    txtList.addAll(selectIndex.map((i) => Issue.values[i].issue));
    issue = txtList.where((t) => t.isNotEmpty).join(', ');
    enableSubmit.value = issue.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
    return PlatformScaffold(
      appBar: PlatformAppBar(title: const Text('Report Issue')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(hPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.word.word,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'select which issue case',
                style: textTheme.titleLarge?.apply(color: colorScheme.error),
              ),
              CupertinoListSection(
                header: Text("Definition issue", style: textTheme.titleMedium),
                children: [
                  for (var i = 0; i < 5; i++)
                    PlatformListTile(
                      title: Text(Issue.values[i].issue),
                      leading: RadioButton(value: i, onTap: toggleSelection),
                    ),
                ],
              ),
              CupertinoListSection(
                header: Text("Example issue", style: textTheme.titleMedium),
                children: [
                  for (var i = 5; i < Issue.values.length; i++)
                    PlatformListTile(
                      title: Text(Issue.values[i].issue),
                      leading: RadioButton(value: i, onTap: toggleSelection),
                    ),
                ],
              ),
              Container(
                color: CupertinoColors.systemGroupedBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text("Other", style: textTheme.titleMedium),
                    ),
                    Container(
                      constraints: BoxConstraints(minHeight: 64),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: PlatformTextField(
                        maxLines: null,
                        textAlignVertical: TextAlignVertical(y: -1),
                        hintText: "What else is wrong?",
                        textInputAction: TextInputAction.done,
                        controller: textEditController,
                        onChanged: (_) => toggleSelection(),
                        cupertino:
                            (_, _) => CupertinoTextFieldData(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBackground
                                    .resolveFrom(context),
                                border: Border.all(color: colorScheme.primary),
                                borderRadius: BorderRadius.circular(
                                  kRadialReactionRadius / 2,
                                ),
                              ),
                            ),
                        material:
                            (_, _) => MaterialTextFieldData(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                fillColor: CupertinoColors.systemBackground
                                    .resolveFrom(context),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    kRadialReactionRadius / 2,
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: hPadding / 2),
              Center(
                child: ValueListenableBuilder(
                  valueListenable: enableSubmit,
                  builder:
                      (context, value, child) => PlatformElevatedButton(
                        onPressed: value ? () => submit(issue) : null,
                        child: const Text("Submit"),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit(String issue) {
    final res = reportIssue(
      word: widget.word,
      issue: issue,
    ).onError((e, _) => messageExceptions(e));
    res.then(
      (msg) =>
          mounted
              ? showToast(
                context: context,
                child: Text(msg),
                alignment: Alignment(0, .5),
              )
              : null,
    );
  }
}

enum Issue {
  partOfSpeech('Wrong part of speech'),
  phonetic('Wrong phonetic'),
  inflection('Wrong inflection'),
  definition('Wrong definition'),
  translation('Wrong translation'),
  asset('Wrong asset'),
  example('Wrong example'),
  cloze('Issue in cloze quiz');

  final String issue;
  const Issue(this.issue);
}

class RadioButton extends StatefulWidget {
  const RadioButton({super.key, required this.value, this.onTap});
  final int value;
  final void Function(int value)? onTap;

  @override
  State<RadioButton> createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton> {
  var selected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => setState(() {
            selected ^= true;
            widget.onTap?.call(widget.value);
          }),
      child:
          selected
              ? const Icon(
                CupertinoIcons.smallcircle_fill_circle_fill,
                size: kRadialReactionRadius,
              )
              : const Icon(CupertinoIcons.circle, size: kRadialReactionRadius),
    );
  }
}
