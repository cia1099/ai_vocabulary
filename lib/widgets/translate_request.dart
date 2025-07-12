import 'package:ai_vocabulary/utils/enums.dart';
import 'package:ai_vocabulary/utils/shortcut.dart' show kIndicatorRadius;
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart'
    show PlatformIcons;

import '../app_settings.dart' show AppSettings;
import '../utils/handle_except.dart';

class TranslateRequest extends StatefulWidget {
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final String? initialData;
  final Future<String> Function(TranslateLocate locate) request;
  final Widget? Function(Object? error)? errorHandler;
  const TranslateRequest({
    super.key,
    this.maxLines,
    this.overflow,
    this.style,
    this.initialData,
    this.errorHandler,
    required this.request,
  });

  @override
  State<TranslateRequest> createState() => _TranslateRequestState();
}

class _TranslateRequestState extends State<TranslateRequest> {
  Future<String>? fTranslate;

  @override
  Widget build(BuildContext context) {
    final locate = AppSettings.of(context).translator;
    final colorScheme = Theme.of(context).colorScheme;
    fTranslate ??= widget.request(locate);
    return FutureBuilder(
      future: fTranslate,
      initialData: widget.initialData,
      builder: (context, snapshot) {
        final isWaiting = snapshot.connectionState == ConnectionState.waiting;
        final errorWidget = widget.errorHandler?.call(snapshot.error);
        if (errorWidget != null) return errorWidget;
        return Text.rich(
          TextSpan(
            children: [
              if (isWaiting)
                WidgetSpan(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.loose(
                      Size.fromRadius(kIndicatorRadius),
                    ),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              if (snapshot.hasError && !isWaiting)
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        fTranslate = widget.request(locate);
                      }),
                      child: Icon(PlatformIcons(context).refresh),
                    ),
                  ),
                ),
              if (snapshot.hasError)
                TextSpan(
                  text: messageExceptions(snapshot.error),
                  style: TextStyle(
                    color: colorScheme.error,
                  ).merge(widget.style),
                )
              else if (snapshot.hasData && snapshot.data!.isNotEmpty)
                TextSpan(text: snapshot.data),
            ],
          ),
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          style: widget.style,
        );
      },
    );
  }
}
