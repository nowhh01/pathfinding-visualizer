import 'package:flutter/material.dart';

class AnimatedBlock extends AnimatedWidget {
  AnimatedBlock({
    Key? key,
    required Animation<double> controller,
    required double width,
    required Offset offset,
    required Color startingColor,
    required Color endingColor,
    void Function()? onTap,
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
        _onTap = onTap,
        super(key: key, listenable: controller);

  final Animation<Size?> _size;
  final Animation<Size?> _sizeForSubtraction;
  final Animation<Offset> _offset;
  final Animation<Offset> _offsetForAddition;
  final Animation<Color?> _color;
  final Animation<double> _radius;
  final void Function()? _onTap;

  @override
  Widget build(BuildContext context) {
    final size = _size.value ?? Size.zero;
    final sizeForSubtraction = _sizeForSubtraction.value ?? Size.zero;
    final offset = _offset.value;
    final offsetForAddition = _offsetForAddition.value;

    return Block(
      size: size,
      sizeForSubtraction: sizeForSubtraction,
      backgroundColor: _color.value!,
      offset: offset,
      offsetForAddition: offsetForAddition,
      radius: _radius.value,
      onTap: _onTap,
    );
  }
}

class Block extends StatelessWidget {
  const Block({
    super.key,
    required this.size,
    required this.offset,
    this.radius = 0,
    this.backgroundColor,
    this.icon,
    this.iconColor,
    this.sizeForSubtraction = Size.zero,
    this.offsetForAddition = Offset.zero,
    this.onTap,
  });

  final Size size;
  final Size sizeForSubtraction;
  final Color? backgroundColor;
  final Offset offset;
  final Offset offsetForAddition;
  final IconData? icon;
  final Color? iconColor;
  final double radius;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx + offsetForAddition.dx,
      top: offset.dy + offsetForAddition.dy,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size.width - sizeForSubtraction.width,
          height: size.height - sizeForSubtraction.width,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: icon != null ? Icon(icon, size: size.width) : null,
        ),
      ),
    );
  }
}
