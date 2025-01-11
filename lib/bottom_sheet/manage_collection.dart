import 'package:ai_vocabulary/model/collections.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../database/my_db.dart';

class ManageCollectionSheet extends StatefulWidget {
  final int wordID;
  const ManageCollectionSheet({
    super.key,
    required this.wordID,
  });

  @override
  State<ManageCollectionSheet> createState() => _ManageCollectionSheetState();
}

class _ManageCollectionSheetState extends State<ManageCollectionSheet> {
  late final marks = MyDB().fetchMarksIncludeWord(widget.wordID).toList();

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.symmetric(horizontal: hPadding / 2),
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if (notification.extent - notification.minExtent < 1e-3) {
              Navigator.maybePop(context);
            }
            return true;
          },
          child: DraggableScrollableSheet(
            expand: false,
            snap: true,
            maxChildSize: .9,
            snapSizes: const [.45, .9],
            initialChildSize: .45,
            builder: (context, scrollController) => PlatformWidgetBuilder(
              material: (_, child, __) => child,
              cupertino: (_, child, __) => CupertinoPopupSurface(child: child),
              child: Column(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      constraints: BoxConstraints.loose(
                          const Size.fromHeight(kToolbarHeight)),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: colorScheme.outlineVariant))),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Add to favorite',
                                  style: textTheme.titleMedium),
                              PlatformIconButton(
                                onPressed: Navigator.of(context).pop,
                                padding: EdgeInsets.zero,
                                material: (_, __) => MaterialIconButtonData(
                                  style: IconButton.styleFrom(
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                cupertino: (_, __) => CupertinoIconButtonData(
                                  padding: EdgeInsets.zero,
                                  minSize: 24,
                                ),
                                icon: const Icon(
                                    CupertinoIcons.xmark_circle_fill),
                              )
                            ],
                          ),
                          Align(
                            alignment: const Alignment(0, -.8),
                            child: Container(
                              width: hPadding * 4,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: colorScheme.outline,
                                  borderRadius: BorderRadius.circular(2)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemBuilder: (context, index) => itemBuilder(marks[index]),
                    footer: PlatformListTile(
                        leading: const Icon(
                          CupertinoIcons.add_circled_solid,
                          size: 20,
                        ),
                        onTap: createNewMark,
                        title: Container(
                            alignment: const Alignment(-1, 0),
                            constraints: const BoxConstraints.tightForFinite(
                                height: kToolbarHeight),
                            child: Text(
                              'New mark',
                              style: textTheme.bodyLarge
                                  ?.apply(color: colorScheme.primary),
                            ))),
                    itemCount: marks.length,
                    onReorder: onReorder,
                  )),
                  Container(
                    height: kToolbarHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        // color: Colors.red,
                        border: Border(
                            top:
                                BorderSide(color: colorScheme.outlineVariant))),
                    child: PlatformTextButton(
                      onPressed: onSave,
                      padding: EdgeInsets.zero,
                      material: (_, __) => MaterialTextButtonData(
                          style: TextButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                      child: const Text('Save'),
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

  Widget itemBuilder(IncludeWordMark mark) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return PlatformListTile(
      key: Key(mark.name),
      onTap: () => setState(() {
        mark.included ^= true;
      }),
      title: Container(
          // color: Colors.red,
          constraints: const BoxConstraints(minHeight: kToolbarHeight),
          alignment: const Alignment(-1, 0),
          child: Text(mark.name,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge)),
      leading: PlatformWidget(
        cupertino: (_, __) => CupertinoCheckbox(
          value: mark.included,
          onChanged: (value) => setState(() {
            mark.included = value ?? false;
          }),
          checkColor: colorScheme.onPrimary,
          fillColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colorScheme.primary
                : const Color(0x00000000),
          ),
        ),
        material: (_, __) => Checkbox(
          value: mark.included,
          onChanged: (value) => setState(() {
            mark.included = value ?? false;
          }),
          checkColor: colorScheme.onPrimary,
          fillColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colorScheme.primary
                : const Color(0x00000000),
          ),
        ),
      ),
      trailing: ReorderableDragStartListener(
          index: marks.indexOf(mark),
          enabled: mark.name != kUncategorizedName,
          child: Icon(mark.name != kUncategorizedName
              ? CupertinoIcons.line_horizontal_3
              : CupertinoIcons.text_badge_xmark)),
    );
  }

  void onSave() {
    Navigator.pop(context);
    // remove unchecked CollectWords
    MyDB().removeCollectWord(widget.wordID,
        marks: marks.where((e) => !e.included).map((e) => e.name));
    // insert new CollectionMarks and exclude kUncategorizedName
    marks.removeWhere((m) => m.name == kUncategorizedName);
    final oldMarks = MyDB().fetchMarksIncludeWord(widget.wordID);
    marks
        .asMap()
        .entries
        .where((m) => !oldMarks.contains(m.value))
        .forEach((m) {
      MyDB().insertCollection(m.value.name, m.key);
    });
    // insert new CollectWords
    final newIncludeMarks = marks.where((m) => m.included).expand((m) sync* {
      final oldMark = oldMarks.where((om) => om == m).firstOrNull;
      if (oldMark == null || !oldMark.included) {
        yield m;
      }
    });
    MyDB().addCollectWord(widget.wordID,
        marks: newIncludeMarks.map((e) => e.name));
    // update indexes
    MyDB().updateIndexes(marks.asMap().entries.map(
        (entry) => IncludeWordMark(name: entry.value.name, index: entry.key)));
    MyDB().notifyListeners();
  }

  void onReorder(oldIndex, newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (marks.any((m) => m.name == kUncategorizedName) && newIndex < 1) return;
    setState(() {
      final mark = marks.removeAt(oldIndex);
      marks.insert(newIndex, mark);
    });
  }

  void createNewMark() {
    final colorScheme = Theme.of(context).colorScheme;
    String? newName;
    final availiable = ValueNotifier(false);
    showPlatformDialog<String?>(
      context: context,
      builder: (context) => MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
          child: PlatformAlertDialog(
            title: const Text('Create a new mark'),
            content: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: () {
                  availiable.value = Form.of(primaryFocus!.context!).validate();
                },
                child: CupertinoTextFormFieldRow(
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Mark cannot be anonymous';
                    if (marks.map((m) => m.name).contains(value))
                      return 'There is already name $value';
                    return null;
                  },
                  onChanged: (value) => newName = value,
                  autofocus: true,
                  minLines: 1,
                  maxLines: 3,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceDim,
                    borderRadius:
                        BorderRadius.circular(kRadialReactionRadius / 2),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                )),
            actions: [
              PlatformDialogAction(
                onPressed: Navigator.of(context).pop,
                child: const Text('Dismiss'),
              ),
              ListenableBuilder(
                listenable: availiable,
                builder: (context, child) => PlatformDialogAction(
                  onPressed: !availiable.value
                      ? null
                      : () => Navigator.of(context).pop(newName),
                  child: child,
                ),
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    ).then((newName) {
      if (newName != null && mounted)
        setState(() {
          marks.add(IncludeWordMark(name: newName, index: marks.length));
        });
    });
  }
}
