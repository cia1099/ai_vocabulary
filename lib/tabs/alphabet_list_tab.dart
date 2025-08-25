import 'dart:math' as math;

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/pages/chat_room_page.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';
import 'package:ai_vocabulary/utils/load_word_route.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/capital_avatar.dart';
import 'package:ai_vocabulary/widgets/filter_input_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../app_route.dart';
import '../model/alphabet.dart';
import '../utils/regex.dart';

class AlphabetListTab extends StatefulWidget {
  const AlphabetListTab({super.key});

  @override
  State<AlphabetListTab> createState() => _AlphabetListTabState();
}

class _AlphabetListTabState extends State<AlphabetListTab> {
  final _selectedId = <int>{};
  final textController = TextEditingController();
  var editable = false;
  late List<GlobalObjectKey> capitalKeys;

  List<AlphabetModel> contacts = [];
  late var futureContacts = fetchContacts();

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    return PlatformScaffold(
      body: FutureBuilder(
        future: futureContacts,
        builder: (context, snapshot) {
          final isWaiting = snapshot.connectionState == ConnectionState.waiting;
          final capitals = contacts.map((e) => e.name[0].toUpperCase()).toSet();
          capitalKeys = capitals.map((e) => GlobalObjectKey(e)).toList();
          return Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  PlatformSliverAppBar(
                    stretch: true,
                    backgroundColor: kCupertinoSheetColor.resolveFrom(context),
                    cupertino: (_, __) => CupertinoSliverAppBarData(
                      title: const Text('Chats'),
                      trailing: buildTrail(),
                      transitionBetweenRoutes: false,
                    ),
                    material: (_, __) => MaterialSliverAppBarData(
                      pinned: true,
                      actions: [buildTrail()],
                      expandedHeight: kExpandedSliverAppBarHeight,
                      flexibleSpace: FlexibleSpaceBar(
                        title: const Text('Chats'),
                        titlePadding: const EdgeInsets.only(
                          left: 16,
                          bottom: 16,
                        ),
                        background: DecoratedBox(
                          decoration: BoxDecoration(color: colorScheme.surface),
                        ),
                      ),
                    ),
                  ),
                  SliverResizingHeader(
                    minExtentPrototype: const SizedBox.shrink(),
                    maxExtentPrototype: SizedBox.fromSize(
                      size: const Size.fromHeight(kTextTabBarHeight + 4),
                    ),
                    child: FilterInputBar(
                      enabled:
                          snapshot.connectionState != ConnectionState.waiting,
                      padding: const EdgeInsets.only(
                        bottom: 4,
                        left: 8,
                        right: 8,
                      ),
                      backgroundColor: colorScheme.surfaceContainerLow,
                      hintText: 'Which word',
                      controller: textController,
                      onChanged: (name) => filterName(name),
                    ),
                  ),
                  if (isWaiting)
                    SliverFillRemaining(
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  else
                    ...takeSections(),
                ],
              ),
              Positioned(
                right: hPadding / 2,
                top: kToolbarHeight * 3.6,
                bottom: 0,
                child: indexBar(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTrail() {
    return PlatformTextButton(
      onPressed: () => setState(() {
        if (editable && _selectedId.isNotEmpty) removeContacts();
        editable ^= true;
      }),
      padding: EdgeInsets.zero,
      material: (_, __) => MaterialTextButtonData(
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      child: Text(editable ? 'Done' : 'Edit'),
    );
  }

  Iterable<Widget> takeSections() {
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return Iterable.generate(capitalKeys.length, (i) {
      final capital = capitalKeys[i].value;
      final sectionContacts = contacts
          .where((w) => w.name[0].toUpperCase() == capital)
          .toList();
      return MultiSliver(
        pushPinnedChildren: true,
        children: [
          SliverPinnedHeader(
            key: capitalKeys[i],
            child: Container(
              height: kTextTabBarHeight * math.sqrt1_2,
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    strokeAlign: -1,
                    color: colorScheme.outlineVariant,
                  ),
                ),
                color: colorScheme.surfaceContainerHigh,
              ),
              alignment: const Alignment(-1, 1),
              child: Text(
                capital.toString(),
                textScaler: TextScaler.linear((1 + math.sqrt(5)) / 2),
              ),
            ),
          ),
          SliverList.builder(
            itemBuilder: (context, index) =>
                _buildAzListItem(sectionContacts[index]),
            itemCount: sectionContacts.length,
          ),
        ],
      );
    });
  }

  Widget _buildAzListItem(AlphabetModel item) {
    return PlatformListTile(
      title: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
        child: matchFilterText(item.name),
      ),
      subtitle: Text(item.subtitle),
      leading: Container(
        // color: Colors.red,
        constraints: const BoxConstraints(maxWidth: 68),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          // mainAxisSize: MainAxisSize.min,
          spacing: 4,
          // alignment: WrapAlignment.spaceBetween,
          // crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (editable || _selectedId.isNotEmpty)
              _CheckButton(
                key: ValueKey(item.id),
                isCheck: _selectedId.contains(item.id),
                onClick: () {
                  if (!_selectedId.add(item.id)) {
                    _selectedId.remove(item.id);
                  }
                },
              ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                WordRoute(
                  wordID: item.id,
                  settings: const RouteSettings(name: AppRoute.vocabulary),
                  builder: (context, word) => VocabularyPage(word: word),
                ),
              ),
              child: CapitalAvatar(
                id: item.id,
                name: item.name,
                url: item.avatarUrl,
              ),
            ),
          ],
        ),
      ),
      onTap: () => Navigator.push(
        context,
        WordRoute(
          wordID: item.id,
          builder: (context, word) => ChatRoomPage(word: word),
        ),
      ),
      trailing: const CupertinoListTileChevron(),
      cupertino: (_, __) => CupertinoListTileData(
        leadingSize: 68,
        padding: const EdgeInsets.only(left: 8, right: 25),
      ),
    );
  }

  Widget indexBar() {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      spacing: textTheme.bodyMedium!.fontSize! / 4,
      children: capitalKeys
          .map(
            (key) => PlatformTextButton(
              onPressed: () {
                Scrollable.ensureVisible(key.currentContext!);
              },
              padding: EdgeInsets.zero,
              material: (_, __) => MaterialTextButtonData(
                style: TextButton.styleFrom(
                  minimumSize: Size.square(textTheme.bodyMedium!.fontSize!),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              cupertino: (_, __) => CupertinoTextButtonData(
                minSize: textTheme.bodyMedium?.fontSize,
              ),
              child: Text(key.value.toString()),
            ),
          )
          .toList(),
    );
  }

  void removeContacts() {
    showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: const Text('Are you sure to delete these chats permanently?'),
        actions: [
          PlatformDialogAction(
            onPressed: () {
              for (final wordID in _selectedId) {
                MyDB.instance.removeMessagesByWordID(wordID);
              }
              futureContacts = fetchContacts();
              Navigator.of(context).pop();
            },
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Delete'),
                Builder(
                  builder: (context) {
                    return Icon(
                      CupertinoIcons.minus_circle,
                      color: DefaultTextStyle.of(context).style.color,
                    );
                  },
                ),
              ],
            ),
            cupertino: (_, __) =>
                CupertinoDialogActionData(isDestructiveAction: true),
          ),
          PlatformDialogAction(
            onPressed: Navigator.of(context).pop,
            child: const Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Retain'),
                Icon(CupertinoIcons.chevron_left_circle),
              ],
            ),
          ),
        ],
      ),
    ).then(
      (_) => setState(() {
        _selectedId.clear();
      }),
    );
  }

  void filterName(String query) async {
    final queryContacts = (await futureContacts).where(
      (contact) => contact.name.toLowerCase().contains(query.toLowerCase()),
    );
    setState(() {
      contacts = queryContacts.toList();
    });
  }

  Future<Iterable<AlphabetModel>> fetchContacts() {
    return MyDB().fetchAlphabetModels().then((iter) {
      contacts = iter.toList();
      return iter;
    });
  }

  void updateFutureContacts() {
    SchedulerBinding.instance.scheduleTask(
      () => setState(() {
        futureContacts = fetchContacts();
      }),
      Priority.idle,
    );
  }

  @override
  void initState() {
    super.initState();
    MyDB.instance.addListener(updateFutureContacts);
  }

  @override
  void dispose() {
    MyDB.instance.removeListener(updateFutureContacts);
    super.dispose();
  }

  Text matchFilterText(String text) {
    final pattern = textController.text;
    final matches = text.matchIndexes(pattern);
    if (matches.isEmpty) return Text(text);
    return Text.rich(
      TextSpan(
        children: List.generate(
          text.length,
          (i) => TextSpan(
            text: text[i],
            style: !matches.contains(i)
                ? null
                : TextStyle(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CheckButton extends StatefulWidget {
  const _CheckButton({required super.key, required this.isCheck, this.onClick});

  final bool isCheck;
  final VoidCallback? onClick;

  @override
  State<_CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<_CheckButton> {
  late bool _isCheck = widget.isCheck;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onClick?.call();
        setState(() {
          _isCheck ^= true;
        });
      },
      child: _isCheck
          ? Icon(
              CupertinoIcons.minus_circle_fill,
              color: CupertinoColors.destructiveRed.resolveFrom(context),
            )
          : const Icon(CupertinoIcons.circle),
    );
  }
}
