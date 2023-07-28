import 'package:flutter/material.dart';

class AnimatedBlockWrapper extends StatefulWidget {
  final double width;
  final Offset offset;
  final int animationTimeInMillisec;
  final Color startingColor;
  final Color endingColor;

  const AnimatedBlockWrapper({
    super.key,
    required this.width,
    required this.offset,
    required this.startingColor,
    required this.endingColor,
    required this.animationTimeInMillisec,
  });

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
    return AnimatedBlock(
      controller: _controller,
      width: widget.width,
      offset: widget.offset,
      startingColor: widget.startingColor,
      endingColor: widget.endingColor,
    );
  }
}

class AnimatedBlock extends AnimatedWidget {
  AnimatedBlock({
    Key? key,
    required Animation<double> controller,
    required double width,
    required Offset offset,
    required Color startingColor,
    required Color endingColor,
  })  : _size = SizeTween(
          begin: const Size(0.0, 0.0),
          end: Size(width * 1.2, width * 1.2),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.0,
              0.7,
              curve: Curves.linear,
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
              curve: Curves.linear,
            ),
          ),
        ),
        _color = ColorTween(
          begin: startingColor,
          end: endingColor,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.2,
              1.0,
              curve: Curves.easeInOutBack,
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
              0.7,
              curve: Curves.linear,
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
              curve: Curves.linear,
            ),
          ),
        ),
        _radius = Tween<double>(
          begin: width / 4,
          end: 0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.6,
              0.8,
              curve: Curves.easeInQuad,
            ),
          ),
        ),
        super(key: key, listenable: controller);

  final Animation<Size?> _size;
  final Animation<Size?> _sizeForSubtraction;
  final Animation<Offset> _offset;
  final Animation<Offset> _offsetForAddition;
  final Animation<Color?> _color;
  final Animation<double> _radius;

  @override
  Widget build(BuildContext context) {
    final size = _size.value ?? Size.zero;
    final sizeForSubtraction = _sizeForSubtraction.value ?? Size.zero;
    final offset = _offset.value;
    final offsetForAddition = _offsetForAddition.value;

    return BlockPaint(
      size: size,
      sizeForSubtraction: sizeForSubtraction,
      color: _color.value!,
      offset: offset,
      offsetForAddition: offsetForAddition,
      radius: _radius.value,
    );
  }
}

class BlockPaint extends StatelessWidget {
  const BlockPaint({
    super.key,
    required this.size,
    required this.offset,
    this.radius = 0,
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
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BlockPainter(
          size.width - sizeForSubtraction.width,
          size.height - sizeForSubtraction.width,
          radius,
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
  final double radius;

  BlockPainter(
      this.width, this.height, this.radius, this.color, this.xPos, this.yPos,
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
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xPos, yPos, width, height),
        Radius.circular(radius),
      );

      canvas.drawRRect(rrect, paint);
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
