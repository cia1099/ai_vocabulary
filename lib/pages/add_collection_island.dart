import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AddCollectionIsland extends StatelessWidget {
  final VoidCallback? onPressed;
  const AddCollectionIsland({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    return Stack(
      children: [
        Positioned(
          top: 8,
          left: hPadding,
          right: hPadding,
          child: Container(
            padding: EdgeInsets.all(hPadding * 1.5),
            constraints: const BoxConstraints.tightForFinite(height: 100),
            decoration: BoxDecoration(
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Added to collection!',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
                PlatformTextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onPressed?.call();
                  },
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemFill, context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Hero(
                          tag: 'favorite',
                          child: Icon(CupertinoIcons.star_fill,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.systemYellow, context)),
                          placeholderBuilder: (context, heroSize, child) =>
                              const Icon(CupertinoIcons.star),
                        ),
                        const Text('Manage'),
                      ],
                    ),
                  ),
                  material: (_, __) => MaterialTextButtonData(
                      style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
