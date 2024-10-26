import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:azlistview/azlistview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/**
 * ref. https://www.youtube.com/watch?v=mGgizUoyeYY
 * by Johannes Milke alphabet list
 */

class AlphabetListTab extends StatefulWidget {
  final List<ClientModel> contacts;
  final void Function(List<int> selectedId)? onConfirm;
  const AlphabetListTab({super.key, required this.contacts, this.onConfirm});

  @override
  State<AlphabetListTab> createState() => _AlphabetListTabState();
}

class _AlphabetListTabState extends State<AlphabetListTab> {
  final _selectedId = <int>{};

  late List<ClientModel> azContacts = widget.contacts;

  @override
  Widget build(BuildContext context) {
    SuspensionUtil.sortListBySuspensionTag(azContacts);
    SuspensionUtil.setShowSuspensionStatus(azContacts);
    final maxHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        kBottomNavigationBarHeight -
        32;
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
          color: Color(0x14121212),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'Which word'),
            onChanged: (name) => filterName(name),
          ),
        ),
        Container(
          // color: CupertinoColors.systemGreen,
          height: maxHeight - 100,
          child: LayoutBuilder(
            builder: (context, constraints) => AzListView(
              data: azContacts,
              itemCount: azContacts.length,
              itemBuilder: (context, index) =>
                  _buildAzListItem(azContacts[index]),
              indexBarItemHeight: (constraints.maxHeight - 32) / 26,
              indexBarData:
                  List.generate(26, (index) => String.fromCharCode(index + 65)),
              indexBarOptions: IndexBarOptions(
                  textStyle: TextStyle(
                color:
                    Theme.of(context).colorScheme.primary, //Color(0xFF243BB2),
                // backgroundColor: CupertinoColors.inactiveGray,
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAzListItem(ClientModel item) {
    final textTheme = Theme.of(context).textTheme;
    final tag = item.getSuspensionTag();
    return Column(
      children: [
        Offstage(
          offstage: !item.isShowSuspension,
          child: Container(
              alignment: Alignment.centerLeft,
              height: 35,
              color: Color(0x0A121212),
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
            style: textTheme.titleMedium,
          ),
          subtitle: Text(item.subtitle ?? '近期上过线'),
          leading: Container(
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
                  child: Icon(CupertinoIcons.textformat, size: 36),
                )
              ],
            ),
          ),
          cupertino: (_, __) => CupertinoListTileData(leadingSize: 68),
        ),
      ],
    );
  }

  void filterName(String query) {
    final queryContacts = widget.contacts.where(
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

class ClientModel extends ISuspensionBean {
  final String name;
  final int userId;
  final String? avatarUrl;
  final String? subtitle;
  late final String capital = name[0].toUpperCase();

  ClientModel(
      {this.subtitle,
      this.avatarUrl,
      required this.name,
      required this.userId});
  @override
  String getSuspensionTag() => capital;
}

// for test
String createName() {
  final rng = math.Random();
  final lowerChars = String.fromCharCodes(
      Iterable.generate(5 + rng.nextInt(6), (_) => rng.nextInt(26) + 97));
  return lowerChars[0].toUpperCase() + lowerChars.substring(1);
}
