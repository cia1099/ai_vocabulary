import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class FilterInputBar extends StatefulWidget {
  const FilterInputBar({
    super.key,
    this.focusNode,
    this.controller,
    this.hintText,
    this.onChanged,
    this.padding,
    this.backgroundColor,
    this.enabled = true,
  });

  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? hintText;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool enabled;
  final void Function(String)? onChanged;

  @override
  State<FilterInputBar> createState() => _FilterInputBarState();
}

class _FilterInputBarState extends State<FilterInputBar> {
  late final focus = widget.focusNode ?? FocusNode();
  late final textController = widget.controller ?? TextEditingController();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final hPadding = widget.padding == null
            ? .0
            : (widget.padding!.left + widget.padding!.right);
        final vPadding = widget.padding == null
            ? .0
            : (widget.padding!.top + widget.padding!.bottom);
        return Container(
          color: widget.backgroundColor,
          padding: widget.padding,
          width: constraints.maxWidth,
          child: ListenableBuilder(
            listenable: focus,
            builder: (context, child) => Wrap(
              children: [
                AnimatedContainer(
                  duration: Durations.short4,
                  width: constraints.maxWidth -
                      hPadding -
                      (focus.hasFocus ? 64 : 0),
                  height: (constraints.maxHeight - vPadding)
                      .clamp(.0, double.infinity),
                  decoration: BoxDecoration(
                      color: colorScheme.onInverseSurface,
                      borderRadius:
                          BorderRadius.circular(kRadialReactionRadius / 2)),
                  child: PlatformTextField(
                    enabled: widget.enabled,
                    hintText: widget.hintText,
                    controller: textController,
                    focusNode: focus,
                    onChanged: widget.onChanged,
                    textInputAction: TextInputAction.search,
                    cupertino: (_, __) => CupertinoTextFieldData(
                      decoration:
                          const BoxDecoration(color: Colors.transparent),
                      prefix: const Icon(CupertinoIcons.equal_square,
                          color: CupertinoColors.systemGrey4),
                    ),
                    material: (_, __) => MaterialTextFieldData(
                      decoration: const InputDecoration(
                        fillColor: Colors.transparent,
                        prefix: Icon(Icons.filter_alt_outlined,
                            color: CupertinoColors.systemGrey4),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: Durations.short4,
                  child: SizedBox(
                    width: focus.hasFocus ? 64 : 0,
                    height: (constraints.maxHeight - vPadding)
                        .clamp(.0, double.maxFinite),
                    child: PlatformTextButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          textController.clear();
                          focus.unfocus();
                          widget.onChanged?.call('');
                        },
                        material: (_, __) => MaterialTextButtonData(
                                style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )),
                        child: const Text('Cancel')),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
