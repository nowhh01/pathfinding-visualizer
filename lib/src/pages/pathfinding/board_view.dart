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
              final offset = _getOffset(
                block.row,
                block.column,
                width,
                height,
                _widthAdjuster,
                _heightAdjuster,
              );

              return AnimatedBlockWrapper(
                key: ObjectKey(block),
                width: width,
                offset: offset,
                startingColor: block.startingColor,
                endingColor: block.endingColor,
                animationTimeInMillisec: _controller.animationTimeInMillisec,
              );
            },
          );

          return CustomPaint(
            foregroundPainter: BoardPainter(
              width,
              height,
              _widthAdjuster,
              _heightAdjuster,
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

    switch (_controller.getNodeType(row, column)) {
      case NodeType.none:
        _controller.changeNodeType(row, column, NodeType.wallNode);
        break;
      case NodeType.wallNode:
        _controller.changeNodeType(row, column, NodeType.none);
        break;
      case NodeType.startingNode:
      case NodeType.endingNode:
      case NodeType.searchedNode:
      case NodeType.pathNode:
      default:
        break;
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
  final double _widthAdjuster;
  final double _heightAdjuster;

  BoardPainter(
      this._width, this._height, this._widthAdjuster, this._heightAdjuster);

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

  @override
  bool hitTest(Offset position) {
    return position.dx - _widthAdjuster >= 0 &&
        position.dy - _heightAdjuster >= 0;
  }
}
