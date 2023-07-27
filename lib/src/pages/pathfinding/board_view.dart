import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../algorithms/breadth_first_search.dart';
import 'block.dart';
import 'pathfinding_controller.dart';

class BoardView extends StatefulWidget {
  const BoardView({super.key});

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late PathfindingController _controller;
  late double _widthAdjuster;
  late double _heightAdjuster;

  @override
  Widget build(BuildContext context) {
    _controller = context.watch<PathfindingController>();
    final width = _controller.blockSize.width;
    final height = _controller.blockSize.height;

    return GestureDetector(
      onTapDown: _onTapDown,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _widthAdjuster = constraints.maxWidth % width / 2;
          _heightAdjuster = constraints.maxHeight % height / 2;

          final animatedBlocks = List<Widget>.generate(
            _controller.getBlockCount(),
            (i) {
              final block = _controller.getBlock(i);
              final (row, column) = block.rowColumn;

              return AnimatedBlockWrapper(
                key: ObjectKey(block),
                width,
                _getOffset(
                  row,
                  column,
                  width,
                  height,
                  _widthAdjuster,
                  _heightAdjuster,
                ),
                block.type,
                _controller.animationTimeInMillisec,
              );
            },
          );

          return CustomPaint(
            painter: BoardPainter(
              width,
              height,
              _heightAdjuster,
              _widthAdjuster,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  BlockPaint(
                    size: _controller.blockSize,
                    icon: Icons.chevron_right,
                    offset: _getOffset(
                      _controller.startingPosition.$1,
                      _controller.startingPosition.$2,
                      width,
                      height,
                      _widthAdjuster,
                      _heightAdjuster,
                    ),
                  ),
                  ...animatedBlocks,
                  BlockPaint(
                    size: _controller.blockSize,
                    icon: Icons.adjust,
                    offset: _getOffset(
                      _controller.endingPosition.$1,
                      _controller.endingPosition.$2,
                      width,
                      height,
                      _widthAdjuster,
                      _heightAdjuster,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    final row = (details.localPosition.dy - _heightAdjuster) ~/
        _controller.blockSize.height;
    final column = (details.localPosition.dx - _widthAdjuster) ~/
        _controller.blockSize.width;

    if (_controller.getNodeType(row, column) == NodeType.none) {
      _controller.setNodeType(row, column, NodeType.wallNode);
    }
  }

  Offset _getOffset(
    int row,
    int column,
    double width,
    double height,
    double widthAdjuster,
    double heightAdjuster,
  ) {
    return Offset(
        column * width + widthAdjuster, row * height + heightAdjuster);
  }
}

class BoardPainter extends CustomPainter {
  final double _width;
  final double _height;
  final double _heightAdjuster;
  final double _widthAdjuster;

  BoardPainter(
      this._width, this._height, this._heightAdjuster, this._widthAdjuster);

  @override
  void paint(Canvas canvas, Size size) {
    final vLines = (size.width ~/ _width) + 1;
    final hLines = (size.height ~/ _height) + 1;

    final paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw vertical lines
    final endY = size.height - (_heightAdjuster * 2);
    for (var i = 0; i < vLines; ++i) {
      final x = _width * i + _widthAdjuster;
      path.moveTo(x, _heightAdjuster);
      path.relativeLineTo(0, endY);
    }

    // Draw horizontal lines
    final endX = size.width - (_widthAdjuster * 2);
    for (var i = 0; i < hLines; ++i) {
      final y = _height * i + _heightAdjuster;
      path.moveTo(_widthAdjuster, y);
      path.relativeLineTo(endX, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
