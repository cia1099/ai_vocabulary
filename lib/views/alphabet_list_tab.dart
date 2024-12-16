import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/pages/chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:azlistview/azlistview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../app_route.dart';
import '../model/alphabet.dart';

/// ref. https://www.youtube.com/watch?v=mGgizUoyeYY
/// by Johannes Milke alphabet list

class AlphabetListTab extends StatefulWidget {
  final void Function(List<int> selectedId)? onConfirm;
  const AlphabetListTab({super.key, this.onConfirm});

  @override
  State<AlphabetListTab> createState() => _AlphabetListTabState();
}

class _AlphabetListTabState extends State<AlphabetListTab> {
  final _selectedId = <int>{};

  List<AlphabetModel> azContacts = [];
  late final futureContacts = MyDB().fetchAlphabetModels().then((iter) {
    setState(() {
      azContacts = iter.toList();
    });
    return iter;
  });

  @override
  Widget build(BuildContext context) {
    SuspensionUtil.sortListBySuspensionTag(azContacts);
    SuspensionUtil.setShowSuspensionStatus(azContacts);
    // final maxHeight = MediaQuery.of(context).size.height -
    //     kToolbarHeight -
    //     kBottomNavigationBarHeight -
    //     32;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Container(
        //   height: 50,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       TextButton(
        //           onPressed: () => Navigator.of(context).pop(),
        //           child: const Text(
        //             '取消',
        //             style: TextStyle(color: Colors.black),
        //           )),
        //       ImText(
        //         '邀请新股东',
        //         fontSize: ImFontSize.title,
        //         color: ImColor.black,
        //         fontWeight: FontWeight.bold,
        //       ),
        //       TextButton(
        //           onPressed: () {
        //             widget.onConfirm?.call(_selectedId.toList());
        //             Navigator.of(context).pop(_selectedId.toList());
        //           },
        //           child: const Text(
        //             '完成',
        //             style: TextStyle(color: Colors.black),
        //           )),
        //     ],
        //   ),
        // ),
        Container(
          height: 50,
          color:
              // const Color(0x14121212),
              colorScheme.inverseSurface.withOpacity(20 / 255),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder(
            future: futureContacts,
            builder: (context, snapshot) => PlatformTextFormField(
              enabled: snapshot.data != null,
              hintText: 'Which word',
              material: (_, __) => MaterialTextFormFieldData(
                decoration: const InputDecoration(border: InputBorder.none),
              ),
              onChanged: (name) => filterName(name),
            ),
          ),
        ),
        Expanded(
          // height: maxHeight - 100,
          child: LayoutBuilder(
            builder: (context, constraints) => AzListView(
              data: azContacts,
              itemCount: azContacts.length,
              itemBuilder: (context, index) =>
                  _buildAzListItem(azContacts[index]),
              indexBarItemHeight: (constraints.maxHeight - 32) / 26,
              indexBarData:
                  azContacts.map((e) => e.getSuspensionTag()).toList(),
              // List.generate(26, (index) => String.fromCharCode(index + 65)),
              indexBarOptions: IndexBarOptions(
                  textStyle: TextStyle(
                color: colorScheme.primary,
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAzListItem(AlphabetModel item) {
    final textTheme = Theme.of(context).textTheme;
    final tag = item.getSuspensionTag();
    return Column(
      children: [
        Offstage(
          offstage: !item.isShowSuspension,
          child: Container(
              alignment: Alignment.centerLeft,
              height: 35,
              color: const Color(0x0A121212),
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(tag, style: textTheme.titleLarge!
                    // ..copyWith(fontWeight: FontWeight.bold),
                    ),
              )),
        ),
        PlatformListTile(
          title: Text(
            item.name,
            // style: textTheme.titleMedium,
            textScaler: const TextScaler.linear(1.2),
          ),
          subtitle: Text(item.subtitle),
          leading: SizedBox(
            // color: Colors.red,
            width: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CheckButton(
                    key: ValueKey(item.userId),
                    isCheck: _selectedId.contains(item.userId),
                    onClick: () {
                      if (!_selectedId.add(item.userId)) {
                        _selectedId.remove(item.userId);
                      }
                    }),
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: item.avatarUrl == null
                      ? null
                      : NetworkImage(item.avatarUrl!),
                  child: const Icon(CupertinoIcons.profile_circled, size: 36),
                )
              ],
            ),
          ),
          onTap: () => Navigator.of(context).push(platformPageRoute(
              context: context,
              settings: const RouteSettings(name: AppRoute.chatRoom),
              builder: (context) => ChatRoomPage(word: item.word))),
          trailing: const CupertinoListTileChevron(),
          cupertino: (_, __) => CupertinoListTileData(leadingSize: 68),
        ),
      ],
    );
  }

  void filterName(String query) async {
    final queryContacts = (await futureContacts).where(
        (contact) => contact.name.toLowerCase().contains(query.toLowerCase()));
    setState(() {
      azContacts = queryContacts.toList();
    });
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
              CupertinoIcons.checkmark_alt_circle_fill,
              color: Color(0xFF243BB2),
            )
          : const Icon(CupertinoIcons.circle),
    );
  }
}
