import 'package:flutter/material.dart';

import '../../algorithms/breadth_first_search.dart';

enum SpeedType { fast, normal, slow }

class Block {
  Block(int row, int column, NodeType type, Color startingColor,
      Color endingColor)
      : _row = row,
        _column = column,
        _type = type,
        _startingColor = startingColor,
        _endingColor = endingColor;

  final int _row;
  int get row => _row;

  final int _column;
  int get column => _column;

  final NodeType _type;
  NodeType get type => _type;

  final Color _startingColor;
  Color get startingColor => _startingColor;

  final Color _endingColor;
  Color get endingColor => _endingColor;
}

class PathfindingController extends ChangeNotifier {
  static const _animationTimesInMillisec = [100, 400, 800];

  final startingPosition = (1, 2);
  final endingPosition = (9, 7);
  final rowCount = 10;
  final columnCount = 10;

  final _blocks = <Block>[];
  int get animationTimeInMillisec =>
      _animationTimesInMillisec[_speedType.index];

  var _speedType = SpeedType.fast;
  SpeedType get speedType => _speedType;
  set speedType(SpeedType type) {
    if (_speedType != type) {
      _speedType = type;

      notifyListeners();
    }
  }

  var _graph = Graph(10, 10);

  final Size _blockSize = const Size(50, 50);
  Size get blockSize => _blockSize;

  NodeType getNodeType(int row, int column) => _graph.nodes[row][column].type;
  void changeNodeType(int row, int column, NodeType newType) {
    final node = _graph.nodes[row][column];
    if (node.type != newType) {
      node.type = newType;

      switch (newType) {
        case NodeType.none:
          for (var i = 0; i < _blocks.length; ++i) {
            if (_blocks[i].row == row && _blocks[i].column == column) {
              _blocks.removeAt(i);
              break;
            }
          }

          break;
        case NodeType.wallNode:
          final (startingColor, endingColor) =
              getStartingAndEndingColors(newType);
          _blocks.add(Block(
            row,
            column,
            newType,
            startingColor,
            endingColor,
          ));
          break;
        case NodeType.startingNode:
        case NodeType.endingNode:
        case NodeType.searchedNode:
        case NodeType.pathNode:
        default:
          break;
      }

      notifyListeners();
    }
  }

  (Color, Color) getStartingAndEndingColors(NodeType type) {
    switch (type) {
      case NodeType.searchedNode:
        return (Colors.indigoAccent, Colors.greenAccent);
      case NodeType.pathNode:
        return (Colors.yellowAccent, Colors.yellowAccent);
      case NodeType.wallNode:
        return (Colors.grey, Colors.black);
      default:
        throw Exception('$type is not defined in getStartingAndEndingColors');
    }
  }

  Block getBlock(int index) => _blocks[index];
  int getBlockCount() => _blocks.length;

  void removeBlock(Block block) {
    _blocks.remove(block);
  }

  void resetGraph() {
    _graph = Graph(rowCount, columnCount);
    _blocks.clear();

    notifyListeners();
  }

  Future<void> update(Node node) async {
    final (startingColor, endingColor) = getStartingAndEndingColors(node.type);
    _blocks.add(Block(
      node.row,
      node.column,
      node.type,
      startingColor,
      endingColor,
    ));

    notifyListeners();

    await Future.delayed(Duration(milliseconds: animationTimeInMillisec));
  }

  Future<void> startFindingPath() async {
    await _graph.bfs(
      _graph.nodes[startingPosition.$1][startingPosition.$2],
      _graph.nodes[endingPosition.$1][endingPosition.$2],
      update,
    );

    await _graph.findPath(
      _graph.nodes[startingPosition.$1][startingPosition.$2],
      _graph.nodes[endingPosition.$1][endingPosition.$2],
      update,
    );
  }
}
