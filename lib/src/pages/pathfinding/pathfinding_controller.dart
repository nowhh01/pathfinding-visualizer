import 'package:flutter/material.dart';

import '../../algorithms/breadth_first_search.dart';

enum SpeedType { fast, normal, slow }

class Block {
  Block(rowColumn, type)
      : _rowColumn = rowColumn,
        _type = type;

  final (int, int) _rowColumn;
  (int, int) get rowColumn => _rowColumn;

  final NodeType _type;
  NodeType get type => _type;
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
  void setNodeType(int row, int column, NodeType type) {
    _graph.nodes[row][column].type = type;
    _blocks.add(Block((row, column), type));

    notifyListeners();
  }

  Block getBlock(int index) => _blocks[index];
  int getBlockCount() => _blocks.length;

  void resetGraph() {
    _graph = Graph(rowCount, columnCount);
    _blocks.clear();

    notifyListeners();
  }

  Future<void> update(Node node) async {
    _blocks.add(Block((node.row, node.column), node.type));

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
