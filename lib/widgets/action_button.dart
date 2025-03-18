import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.isDestructiveAction = false,
    this.topBorder = false,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final bool isDestructiveAction;
  final bool topBorder;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape:
          topBorder
              ? Border(
                top: BorderSide(
                  color: CupertinoColors.systemGrey4.resolveFrom(context),
                ),
              )
              : null,
      child: InkWell(
        onTap: onPressed,
        child: IgnorePointer(
          child: PlatformDialogAction(
            onPressed: onPressed,
            child: child,
            material:
                (_, __) => MaterialDialogActionData(
                  child: Align(alignment: Alignment(0, 0), child: child),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDestructiveAction
                            ? CupertinoColors.destructiveRed.resolveFrom(
                              context,
                            )
                            : null,
                  ),
                ),
            cupertino:
                (_, __) => CupertinoDialogActionData(
                  isDestructiveAction: isDestructiveAction,
                ),
          ),
        ),
      ),
    );
  }
}
