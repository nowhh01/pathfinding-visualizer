import 'package:flutter/material.dart';

import '../../algorithms/breadth_first_search.dart';

class AnimatedBlockWrapper extends StatefulWidget {
  final double width;
  final Offset offset;
  final int animationTimeInMillisec;
  final NodeType nodeType;

  const AnimatedBlockWrapper(
      this.width, this.offset, this.nodeType, this.animationTimeInMillisec,
      {super.key});

  @override
  State<AnimatedBlockWrapper> createState() => _AnimatedBlockWrapperState();
}

class _AnimatedBlockWrapperState extends State<AnimatedBlockWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.animationTimeInMillisec),
      vsync: this,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.nodeType) {
      case NodeType.searchedNode:
        return AnimatedBlock(
          controller: _controller,
          width: widget.width,
          offset: widget.offset,
          color1: Colors.indigoAccent,
          color2: Colors.greenAccent,
        );
      case NodeType.pathNode:
        return AnimatedBlock(
          controller: _controller,
          width: widget.width,
          offset: widget.offset,
          color1: Colors.yellowAccent,
          color2: Colors.yellowAccent,
        );
      case NodeType.wallNode:
        return AnimatedBlock(
          controller: _controller,
          width: widget.width,
          offset: widget.offset,
          color1: Colors.grey,
          color2: Colors.black,
        );
      default:
        return Container();
    }
  }
}

class AnimatedBlock extends AnimatedWidget {
  AnimatedBlock({
    Key? key,
    required Animation<double> controller,
    required double width,
    required Offset offset,
    required Color color1,
    required Color color2,
  })  : _size = SizeTween(
          begin: const Size(0.0, 0.0),
          end: Size(width * 1.2, width * 1.2),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.0,
              0.8,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        _sizeForSubtraction = SizeTween(
          begin: const Size(0.0, 0.0),
          end: Size(width * 0.2, width * 0.2),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.8,
              1.0,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        color = ColorTween(
          begin: color1,
          end: color2,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.0,
              1.0,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        _offset = Tween<Offset>(
          begin: Offset(offset.dx + (width / 2), offset.dy + (width / 2)),
          end: Offset(offset.dx - (width * 0.1), offset.dy - (width * 0.1)),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.0,
              0.8,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        _offsetForAddition = Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: Offset(width * 0.1, width * 0.1),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.8,
              1.0,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        super(key: key, listenable: controller);

  final Animation<Size?> _size;
  final Animation<Size?> _sizeForSubtraction;
  final Animation<Offset> _offset;
  final Animation<Offset> _offsetForAddition;
  final Animation<Color?> color;

  @override
  Widget build(BuildContext context) {
    final size = _size.value ?? Size.zero;
    final sizeForSubtraction = _sizeForSubtraction.value ?? Size.zero;
    final offset = _offset.value;
    final offsetForAddition = _offsetForAddition.value;

    return BlockPaint(
      size: size,
      sizeForSubtraction: sizeForSubtraction,
      color: color.value!,
      offset: offset,
      offsetForAddition: offsetForAddition,
    );
  }
}

class BlockPaint extends StatelessWidget {
  const BlockPaint({
    super.key,
    required this.size,
    required this.offset,
    this.color = Colors.black,
    this.icon,
    this.sizeForSubtraction = Size.zero,
    this.offsetForAddition = Offset.zero,
  });

  final Size size;
  final Size sizeForSubtraction;
  final Color color;
  final Offset offset;
  final Offset offsetForAddition;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BlockPainter(
          size.width - sizeForSubtraction.width,
          size.height - sizeForSubtraction.width,
          color,
          offset.dx + offsetForAddition.dx,
          offset.dy + offsetForAddition.dy,
          icon),
    );
  }
}

class BlockPainter extends CustomPainter {
  final double width;
  final double height;
  final Color color;
  final double xPos;
  final double yPos;
  final IconData? icon;

  BlockPainter(this.width, this.height, this.color, this.xPos, this.yPos,
      [this.icon]);

  @override
  void paint(Canvas canvas, Size size) {
    if (icon != null) {
      final textPainter = TextPainter(textDirection: TextDirection.rtl);
      textPainter.text = TextSpan(
          text: String.fromCharCode(icon!.codePoint),
          style: TextStyle(
              fontSize: width, fontFamily: icon!.fontFamily, color: color));
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos, yPos));
    } else {
      final paint = Paint()
        ..strokeWidth = 5
        ..color = color
        ..style = PaintingStyle.fill;
      final square = Rect.fromLTWH(xPos, yPos, width, height);

      canvas.drawRect(square, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is BlockPainter) {
      if (oldDelegate.color != color ||
          oldDelegate.width != width ||
          xPos != oldDelegate.xPos ||
          oldDelegate.yPos != yPos) {
        return true;
      }
    }

    return false;
  }
}
