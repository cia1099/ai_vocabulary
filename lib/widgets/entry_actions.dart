import 'package:ai_vocabulary/database/my_db.dart';
import 'package:flutter/cupertino.dart';

class EntryActions extends StatefulWidget {
  const EntryActions({
    super.key,
    required this.wordID,
  });
  final int wordID;

  @override
  State<EntryActions> createState() => _EntryActionsState();
}

class _EntryActionsState extends State<EntryActions> {
  late final collectWord = MyDB.instance.getCollectWord(widget.wordID);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        const Icon(CupertinoIcons.search),
        GestureDetector(
            onTap: toggleCollection,
            child: collectWord.collect
                ? const Icon(CupertinoIcons.star_fill,
                    color: CupertinoColors.systemYellow)
                : const Icon(CupertinoIcons.star)),
        const Icon(CupertinoIcons.ellipsis_vertical),
      ],
    );
  }

  void toggleCollection() {
    collectWord.collect ^= true;
    MyDB.instance
        .updateCollectWord(wordId: widget.wordID, collect: collectWord.collect);
    setState(() {});
  }
}
