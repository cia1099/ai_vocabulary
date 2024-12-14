part of '../vocabulary_page.dart';

class DefinitionTab extends StatelessWidget {
  const DefinitionTab({
    super.key,
    required this.word,
    required this.hPadding,
  });

  final Vocabulary word;
  final double hPadding;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverList.builder(
            itemCount: word.definitions.length,
            itemBuilder: (_, index) => Container(
                  padding: EdgeInsets.only(
                    top: hPadding,
                    left: hPadding,
                    right: hPadding,
                  ),
                  margin: index == word.definitions.length - 1
                      ? const EdgeInsets.only(
                          bottom: kBottomNavigationBarHeight)
                      : null,
                  child: DefinitionTile(
                      definition: word.definitions[index], word: word.word),
                ))
      ],
    );
  }
}

class RadialGradientPainter extends CustomPainter {
  final ColorScheme colorScheme;

  RadialGradientPainter({super.repaint, required this.colorScheme});
  @override
  void paint(Canvas canvas, Size size) {
    // 定义径向渐变
    final Rect rect = Offset.zero & size;
    final RadialGradient gradient1 = RadialGradient(
      center: const Alignment(.9, -.9), // 中心位置
      radius: 1, // 渐变的半径
      colors: [
        colorScheme.inversePrimary,
        colorScheme.onInverseSurface,
        colorScheme.inversePrimary,
        // Colors.transparent,
      ],
      stops: const [0.0, 0.6, .8], // 每个颜色的分布位置
    );
    final RadialGradient gradient2 = RadialGradient(
      center: const Alignment(-1, 1),
      radius: 1, // 渐变的半径
      colors: [
        colorScheme.inversePrimary,
        colorScheme.onInverseSurface,
        colorScheme.inversePrimary,
        // Colors.transparent,
      ],
      stops: const [0.0, 0.6, .8], // 每个颜色的分布位置
    );

    // 创建 Paint 对象，并设置 shader 为径向渐变
    // final Paint paint = Paint()..shader = gradient.createShader(rect);

    // 在画布上绘制矩形并填充渐变
    // canvas.drawRect(rect, paint);
    canvas.drawCircle(Offset(size.width, 0), size.height / 2,
        Paint()..shader = gradient1.createShader(rect));
    canvas.drawCircle(Offset(0, size.height), size.height / 2,
        Paint()..shader = gradient2.createShader(rect));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // 因为我们不需要重绘，所以返回 false
  }
}
