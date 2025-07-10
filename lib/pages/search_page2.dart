part of 'search_page.dart';

class _SearchNotFound extends StatelessWidget {
  const _SearchNotFound({
    // super.key,
    this.typing = '',
  });
  final String typing;

  @override
  Widget build(BuildContext context) {
    final cupertinoTextTheme = CupertinoTheme.of(context).textTheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      // color: Colors.red,
      margin: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: hPadding * 2,
      ),
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(sqrt2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sorry no related results found',
              style: cupertinoTextTheme.navTitleTextStyle,
            ),
            Text(
              typing,
              style: cupertinoTextTheme.dateTimePickerTextStyle.apply(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
            AlignParagraph(
              mark: Icon(CupertinoIcons.circle_fill, size: hPadding / 2),
              paragraph: Text(
                'Please verify the input text for any errors.',
                style: cupertinoTextTheme.textStyle,
              ),
              xInterval: hPadding / 2,
              paragraphStyle: textTheme.bodyMedium?.apply(heightFactor: sqrt2),
            ),
            AlignParagraph(
              mark: Icon(CupertinoIcons.circle_fill, size: hPadding / 2),
              paragraph: Text(
                'Please attempt a different search term.',
                style: cupertinoTextTheme.textStyle,
              ),
              xInterval: hPadding / 2,
              paragraphStyle: textTheme.bodyMedium?.apply(heightFactor: sqrt2),
            ),
            AlignParagraph(
              mark: Icon(CupertinoIcons.circle_fill, size: hPadding / 2),
              paragraph: Text(
                'Please consider a more common text.',
                style: cupertinoTextTheme.textStyle,
              ),
              xInterval: hPadding / 2,
              paragraphStyle: textTheme.bodyMedium?.apply(heightFactor: sqrt2),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingCurtain extends StatelessWidget {
  final bool isWaiting;
  final Duration duration;
  const _WaitingCurtain({required this.isWaiting, required this.duration});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: isWaiting
          ? ColoredBox(
              color: (kCupertinoModalBarrierColor as CupertinoDynamicColor)
                  .resolveFrom(context),
              child: SpinKitFadingCircle(color: colorScheme.secondary),
            )
          : SizedBox.shrink(),
    );
  }
}
