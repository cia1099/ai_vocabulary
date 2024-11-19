import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SearchPopUpPage extends StatefulWidget {
  const SearchPopUpPage({
    super.key,
  });

  @override
  State<SearchPopUpPage> createState() => _SearchPopUpPageState();
}

class _SearchPopUpPageState extends State<SearchPopUpPage> {
  final textController = TextEditingController();
  late final suffixIcon = Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: textController.clear,
      child: const Icon(CupertinoIcons.xmark_circle_fill),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Stack(children: [
        const Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: .6,
            widthFactor: 1.0,
            child: Card(
              margin: EdgeInsets.only(top: kToolbarHeight),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(kRadialReactionRadius))),
              color: Colors.green,
              // width: double.maxFinite,
              child: Text("Shit"),
            ),
          ),
        ),
        Align(
            alignment: Alignment.topLeft,
            child: Container(
              color: colorScheme.surface,
              width: double.maxFinite,
              height: kToolbarHeight,
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: PlatformTextField(
                    autofocus: true,
                    hintText: 'find it',
                    controller: textController,
                    cupertino: (_, __) => CupertinoTextFieldData(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: colorScheme.primary, width: 2),
                          borderRadius:
                              BorderRadius.circular(kRadialReactionRadius)),
                      suffix: suffixIcon,
                    ),
                    material: (_, __) => MaterialTextFieldData(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(kRadialReactionRadius),
                            borderSide: BorderSide(
                                color: colorScheme.primary, width: 2)),
                        suffixIcon: suffixIcon,
                      ),
                    ),
                  )),
                  PlatformTextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'))
                ],
              ),
            )),
      ]),
    );
  }
}
