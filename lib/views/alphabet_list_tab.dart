import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/pages/chat_room_page.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';
import 'package:ai_vocabulary/widgets/capital_avatar.dart';
import 'package:ai_vocabulary/widgets/filter_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../app_route.dart';
import '../model/alphabet.dart';
import '../utils/regex.dart';

class AlphabetListTab extends StatefulWidget {
  final bool editable;
  const AlphabetListTab({super.key, this.editable = false});

  @override
  State<AlphabetListTab> createState() => _AlphabetListTabState();
}

class _AlphabetListTabState extends State<AlphabetListTab> {
  final _selectedId = <int>{};
  final textController = TextEditingController();

  List<AlphabetModel> azContacts = [];
  late var futureContacts = fetchContacts();

  @override
  Widget build(BuildContext context) {
    SuspensionUtil.sortListBySuspensionTag(azContacts);
    SuspensionUtil.setShowSuspensionStatus(azContacts);
    if (!widget.editable && _selectedId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showPlatformDialog(
            context: context,
            builder: (context) => PlatformAlertDialog(
                  title: const Text(
                      'Are you sure to delete these chats permanently?'),
                  actions: [
                    PlatformDialogAction(
                      onPressed: () {
                        for (final wordID in _selectedId) {
                          MyDB.instance.removeMessagesByWordID(wordID);
                        }
                        azContacts.clear();
                        futureContacts = fetchContacts();
                        Navigator.of(context).pop();
                      },
                      child: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Delete'),
                          Builder(builder: (context) {
                            return Icon(CupertinoIcons.minus_circle,
                                color:
                                    DefaultTextStyle.of(context).style.color);
                          }),
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
                          Icon(CupertinoIcons.chevron_left_circle)
                        ],
                      ),
                    ),
                  ],
                )).then((_) => setState(() {
              _selectedId.clear();
            }));
      });
    }
    final colorScheme = Theme.of(context).colorScheme;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        FutureBuilder(
          future: futureContacts,
          builder: (context, snapshot) => SliverResizingHeader(
            minExtentPrototype: const SizedBox.shrink(),
            maxExtentPrototype: SizedBox.fromSize(
                size: const Size.fromHeight(kTextTabBarHeight + 4)),
            child: FilterInputBar(
              enabled: snapshot.connectionState != ConnectionState.waiting,
              padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
              backgroundColor: colorScheme.primaryContainer,
              hintText: 'Which word',
              controller: textController,
              onChanged: (name) => filterName(name),
            ),
          ),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) => AzListView(
          // physics: const BouncingScrollPhysics(),
          data: azContacts,
          itemCount: azContacts.length,
          itemBuilder: (context, index) => _buildAzListItem(azContacts[index]),
          susItemHeight: 35,
          susItemBuilder: (context, index) {
            final textTheme = Theme.of(context).textTheme;
            final tag = azContacts[index].getSuspensionTag();
            return Container(
                alignment: Alignment.centerLeft,
                height: 35,
                color: colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(tag, style: textTheme.titleLarge!
                      // ..copyWith(fontWeight: FontWeight.bold),
                      ),
                ));
          },
          indexBarItemHeight:
              (constraints.maxHeight - kBottomNavigationBarHeight) / 26,
          indexBarData:
              azContacts.map((e) => e.getSuspensionTag()).toSet().toList(),
          // List.generate(26, (index) => String.fromCharCode(index + 65)),
          indexBarOptions: IndexBarOptions(
              textStyle: TextStyle(
            color: colorScheme.primary,
          )),
        ),
      ),
    );
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
          // alignment: WrapAlignment.spaceBetween,
          // crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (widget.editable || _selectedId.isNotEmpty)
              _CheckButton(
                  key: ValueKey(item.id),
                  isCheck: _selectedId.contains(item.id),
                  onClick: () {
                    if (!_selectedId.add(item.id)) {
                      _selectedId.remove(item.id);
                    }
                  }),
            GestureDetector(
              onTap: () {
                final word = MyDB().fetchWords([item.id]).firstOrNull;
                if (word != null) {
                  Navigator.of(context).push(platformPageRoute(
                      context: context,
                      settings: const RouteSettings(name: AppRoute.vocabulary),
                      builder: (context) => VocabularyPage(word: word)));
                }
              },
              child: CapitalAvatar(
                id: item.id,
                name: item.name,
                url: item.avatarUrl,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        final word = MyDB().fetchWords([item.id]).firstOrNull;
        if (word != null) {
          Navigator.of(context).push(platformPageRoute(
              context: context,
              // settings: const RouteSettings(name: AppRoute.chatRoom),
              builder: (context) => ChatRoomPage(word: word)));
        }
      },
      trailing: const CupertinoListTileChevron(),
      cupertino: (_, __) => CupertinoListTileData(
          leadingSize: 68, padding: const EdgeInsets.only(left: 8, right: 25)),
    );
  }

  void filterName(String query) async {
    final queryContacts = (await futureContacts).where(
        (contact) => contact.name.toLowerCase().contains(query.toLowerCase()));
    setState(() {
      azContacts = queryContacts.toList();
    });
  }

  Future<Iterable<AlphabetModel>> fetchContacts() {
    return MyDB().fetchAlphabetModels().then((iter) {
      setState(() {
        azContacts = iter.toList();
      });
      return iter;
    });
  }

  void updateFutureContacts() {
    setState(() {
      azContacts.clear();
      futureContacts = fetchContacts();
    });
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
    return Text.rich(TextSpan(
        children: List.generate(
      text.length,
      (i) => TextSpan(
        text: text[i],
        style: !matches.contains(i)
            ? null
            : TextStyle(
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
                color: Theme.of(context).colorScheme.onTertiaryContainer),
      ),
    )));
  }
}

class _CheckButton extends StatefulWidget {
  const _CheckButton({
    required super.key,
    required this.isCheck,
    this.onClick,
  });

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
          ? const Icon(
              CupertinoIcons.minus_circle_fill,
              color: CupertinoColors.destructiveRed,
            )
          : const Icon(CupertinoIcons.circle),
    );
  }
}
