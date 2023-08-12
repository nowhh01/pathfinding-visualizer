import 'dart:developer';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../algorithms/graph.dart';
import 'block.dart';
import 'pathfinding_controller.dart';

class BoardView extends StatefulWidget {
  const BoardView({super.key});

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> with TickerProviderStateMixin {
  final _animationControllers = <AnimationController>[];
  late PathfindingController _controller;

  @override
  void initState() {
    super.initState();
    log('initState called');

    _controller = context.read<PathfindingController>();
    _controller.nodeBlockAddingEventHandler.subscribe(_raiseNodeBlockAdding);
    _controller.resettingEventHandler.subscribe(_raiseResetting);
    _controller.speedChangedEventHandler.subscribe(_raiseSpeedChanged);
  }

  @override
  void dispose() {
    _controller.nodeBlockAddingEventHandler.unsubscribe(_raiseNodeBlockAdding);
    _controller.resettingEventHandler.unsubscribe(_raiseResetting);
    _controller.speedChangedEventHandler.unsubscribe(_raiseSpeedChanged);

    for (var i = 0; i < _animationControllers.length; ++i) {
      _animationControllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<PathfindingController>();

    return GestureDetector(
      onTapDown: _onTapDown,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minLength = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;
          final width = minLength / _controller.columnCount;
          final height = minLength / _controller.rowCount;
          _controller.blockSize = Size(width, height);

          final widthAdjuster = (constraints.maxWidth - minLength) / 2;
          final heightAdjuster = (constraints.maxHeight - minLength) / 2;
          _controller.widthAdjuster = widthAdjuster;
          _controller.heightAdjuster = heightAdjuster;

          final animatedBlocks = List<Widget>.generate(
            _controller.getNodeBlockCount(),
            (i) {
              final nodeBlock = _controller.getNodeBlock(i);
              final offset = _getOffset(nodeBlock.row, nodeBlock.column);
              final animationController = _animationControllers[i];

              return AnimatedBlock(
                controller: animationController,
                width: width,
                offset: offset,
                startingColor: nodeBlock.startingColor,
                endingColor: nodeBlock.endingColor,
                onTap: () async {
                  switch (nodeBlock.type) {
                    case NodeType.wallNode:
                      log('remove nodeblock');
                      await animationController.reverse();
                      animationController.dispose();

                      _animationControllers.remove(animationController);
                      _controller.changeNodeType(
                          nodeBlock.row, nodeBlock.column, NodeType.none);
                      break;
                    default:
                      break;
                  }
                },
                icon: switch (nodeBlock.direction) {
                  Direction.up => Icons.keyboard_arrow_up,
                  Direction.down => Icons.keyboard_arrow_down,
                  Direction.left => Icons.keyboard_arrow_left,
                  Direction.right => Icons.keyboard_arrow_right,
                  _ => null
                },
              );
            },
          );
          final isDragging = _controller.isDragging;
          final draggingType = _controller.draggingType;

          return CustomPaint(
            foregroundPainter: BoardPainter(
              width,
              height,
              widthAdjuster,
              heightAdjuster,
              _onHitTest,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  Block(
                    size: _controller.blockSize,
                    icon: Icons.keyboard_arrow_right,
                    iconColor: isDragging && draggingType == NodeType.startNode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black,
                    offset: _getOffset(
                      _controller.startingRowColumn.$1,
                      _controller.startingRowColumn.$2,
                    ),
                    onPanStart: (details) => panStart(
                      details,
                      _controller.startingRowColumn.$1,
                      _controller.startingRowColumn.$2,
                      NodeType.startNode,
                    ),
                    onPanUpdate: (details) => panUpdate(
                      details,
                      _controller.startingRowColumn.$1,
                      _controller.startingRowColumn.$2,
                    ),
                    onPanEnd: (details) => panEnd(
                      details,
                      _controller.startingRowColumn.$1,
                      _controller.startingRowColumn.$2,
                    ),
                  ),
                  ...animatedBlocks,
                  Block(
                    size: _controller.blockSize,
                    icon: Icons.adjust,
                    iconColor: isDragging && draggingType == NodeType.targetNode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black,
                    offset: _getOffset(
                      _controller.endingRowColumn.$1,
                      _controller.endingRowColumn.$2,
                    ),
                    onPanStart: (details) => panStart(
                      details,
                      _controller.endingRowColumn.$1,
                      _controller.endingRowColumn.$2,
                      NodeType.targetNode,
                    ),
                    onPanUpdate: (details) => panUpdate(
                      details,
                      _controller.endingRowColumn.$1,
                      _controller.endingRowColumn.$2,
                    ),
                    onPanEnd: (details) => panEnd(
                      details,
                      _controller.endingRowColumn.$1,
                      _controller.endingRowColumn.$2,
                    ),
                  ),
                  if (_controller.isDragging)
                    Block(
                      size: _controller.blockSize,
                      icon: _controller.draggingType == NodeType.startNode
                          ? Icons.chevron_right
                          : Icons.adjust,
                      offset: _controller.blockPosition!,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void panUpdate(
    DragUpdateDetails details,
    int row,
    int column,
  ) {
    final width = _controller.blockSize.width;
    final height = _controller.blockSize.height;
    final draggingBlockPosAjuster = _controller.draggingBlockPosAjuster;
    final blockX = details.localPosition.dx -
        draggingBlockPosAjuster.dx +
        (column * width);
    final blockY =
        details.localPosition.dy - draggingBlockPosAjuster.dy + (row * height);

    _controller.blockPosition = Offset(blockX, blockY);
  }

  void panStart(
    DragStartDetails details,
    int row,
    int column,
    NodeType type,
  ) {
    _controller.draggingType = type;
  }

  void panEnd(
    DragEndDetails details,
    int row,
    int column,
  ) {
    final width = _controller.blockSize.width;
    final height = _controller.blockSize.height;
    final blockPosition = _controller.blockPosition!;
    final draggingBlockPosAjuster = _controller.draggingBlockPosAjuster;

    final x = blockPosition.dx + draggingBlockPosAjuster.dx;
    final y = blockPosition.dy + draggingBlockPosAjuster.dy;
    final newColumn = x ~/ width;
    final newRow = y ~/ height;

    final draggingType = _controller.draggingType!;
    final newRowColumn = (newRow, newColumn);
    if (draggingType == NodeType.startNode) {
      _controller.startingRowColumn = newRowColumn;
    } else {
      _controller.endingRowColumn = newRowColumn;
    }

    _controller.changeNodeType(row, column, NodeType.none);
    _controller.changeNodeType(newRow, newColumn, draggingType);
    _controller.blockPosition = null;
    _controller.draggingType = null;
  }

  void _raiseNodeBlockAdding([EventArgs? _]) {
    final newController = AnimationController(
      duration: Duration(milliseconds: _controller.animationTimeInMillisec),
      vsync: this,
    );
    _animationControllers.add(newController);
    newController.forward();
  }

  void _raiseResetting([EventArgs? _]) {
    for (var i = 0; i < _animationControllers.length; ++i) {
      _animationControllers[i].dispose();
    }
    _animationControllers.clear();
  }

  void _raiseSpeedChanged([EventArgs? _]) {
    final duration =
        Duration(milliseconds: _controller.animationTimeInMillisec);
    for (var i = 0; i < _animationControllers.length; ++i) {
      _animationControllers[i].duration = duration;
    }
  }

  void _onTapDown(TapDownDetails details) {
    log('tap down');
    final (int row, int column) =
        _getRowAndColumnFromOffset(details.localPosition);

    switch (_controller.getNodeType(row, column)) {
      case NodeType.none:
        _controller.changeNodeType(row, column, NodeType.wallNode);
        break;
      case NodeType.wallNode:
      case NodeType.startNode:
      case NodeType.targetNode:
      case NodeType.searchedNode:
      case NodeType.pathNode:
      default:
        break;
    }
  }

  bool _onHitTest(Offset position) {
    if (_controller.isDragging) {
      return false;
    }

    if (position.dx - _controller.widthAdjuster < 0 ||
        position.dy - _controller.heightAdjuster < 0) {
      return false;
    }

    final (int row, int column) = _getRowAndColumnFromOffset(position);
    final result = _controller.getNodeType(row, column) == NodeType.none;

    if (row == _controller.startingRowColumn.$1 &&
        column == _controller.startingRowColumn.$2) {
      return false;
    }

    return result;
  }

  (int, int) _getRowAndColumnFromOffset(Offset position) {
    final row = (position.dy - _controller.heightAdjuster) ~/
        _controller.blockSize.height;
    final column = (position.dx - _controller.widthAdjuster) ~/
        _controller.blockSize.width;

    return (row, column);
  }

  Offset _getOffset(
    int row,
    int column,
  ) {
    return Offset(
        column * _controller.blockSize.width + _controller.widthAdjuster,
        row * _controller.blockSize.height + _controller.heightAdjuster);
  }
}

class BoardPainter extends CustomPainter {
  final double _width;
  final double _height;
  final double _widthAdjuster;
  final double _heightAdjuster;
  final bool Function(Offset)? _onHitTest;

  BoardPainter(this._width, this._height, this._widthAdjuster,
      this._heightAdjuster, this._onHitTest);

  @override
  void paint(Canvas canvas, Size size) {
    final minLength = size.width < size.height ? size.width : size.height;
    final lineCount = (minLength ~/ _width) + 1;

    final paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw vertical lines
    final endY = size.height - (_heightAdjuster * 2);
    for (var i = 0; i < lineCount; ++i) {
      final x = _width * i + _widthAdjuster;
      path.moveTo(x, _heightAdjuster);
      path.relativeLineTo(0, endY);
    }

    // Draw horizontal lines
    final endX = size.width - (_widthAdjuster * 2);
    for (var i = 0; i < lineCount; ++i) {
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
  bool? hitTest(Offset position) {
    return _onHitTest?.call(position);
  }
}
