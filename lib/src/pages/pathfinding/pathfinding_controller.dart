import 'package:event/event.dart';
import 'package:flutter/material.dart';

import '../../algorithms/breadth_first_search.dart';

enum SpeedType { fast, normal, slow }

class NodeBlock {
  NodeBlock(int row, int column, NodeType type, Color startingColor,
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
  PathfindingController() {
    _graph.nodes[startingRowColumn.$1][startingRowColumn.$2].type =
        NodeType.startingNode;
    _graph.nodes[endingRowColumn.$1][endingRowColumn.$2].type =
        NodeType.endingNode;
  }

  static const _animationTimesInMillisec = [100, 400, 800];

  final _nodeBlockAddingEventHandler = Event();
  Event get nodeBlockAddingEventHandler => _nodeBlockAddingEventHandler;

  final _speedChangedEventHandler = Event();
  Event get speedChangedEventHandler => _speedChangedEventHandler;

  final _resettingEventHandler = Event();
  Event get resettingEventHandler => _resettingEventHandler;

  var startingRowColumn = (1, 2);
  var endingRowColumn = (9, 7);
  NodeType? draggingType;
  final rowCount = 10;
  final columnCount = 10;

  bool get isDragging => _blockPosition != null;

  Offset? _blockPosition;
  Offset? get blockPosition => _blockPosition;
  set blockPosition(newPosition) {
    _blockPosition = newPosition;

    notifyListeners();
  }

  final _nodeBlocks = <NodeBlock>[];
  int get animationTimeInMillisec =>
      _animationTimesInMillisec[_speedType.index];

  var _speedType = SpeedType.fast;
  SpeedType get speedType => _speedType;
  set speedType(SpeedType type) {
    if (_speedType != type) {
      _speedType = type;

      _speedChangedEventHandler.broadcast();
      notifyListeners();
    }
  }

  var _graph = Graph(10, 10);

  final Size _nodeBlockSize = const Size(50, 50);
  Size get blockSize => _nodeBlockSize;

  NodeType getNodeType(int row, int column) => _graph.nodes[row][column].type;
  void changeNodeType(int row, int column, NodeType newType) {
    final node = _graph.nodes[row][column];
    if (node.type != newType) {
      node.type = newType;

      switch (newType) {
        case NodeType.none:
          for (var i = 0; i < _nodeBlocks.length; ++i) {
            if (_nodeBlocks[i].row == row && _nodeBlocks[i].column == column) {
              _nodeBlocks.removeAt(i);
              break;
            }
          }

          break;
        case NodeType.wallNode:
          final (startingColor, endingColor) =
              _getStartingAndEndingColors(newType);
          _addNodeBlock(NodeBlock(
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

  NodeBlock getNodeBlock(int index) => _nodeBlocks[index];
  int getNodeBlockCount() => _nodeBlocks.length;

  void reset() {
    _resettingEventHandler.broadcast();
    _graph = Graph(rowCount, columnCount);
    _nodeBlocks.clear();
    notifyListeners();
  }

  Future<void> startFindingPath() async {
    await _graph.bfs(
      _graph.nodes[startingRowColumn.$1][startingRowColumn.$2],
      _graph.nodes[endingRowColumn.$1][endingRowColumn.$2],
      _update,
    );

    await _graph.findPath(
      _graph.nodes[startingRowColumn.$1][startingRowColumn.$2],
      _graph.nodes[endingRowColumn.$1][endingRowColumn.$2],
      _update,
    );
  }

  Future<void> _update(Node node) async {
    final (startingColor, endingColor) = _getStartingAndEndingColors(node.type);
    _addNodeBlock(NodeBlock(
      node.row,
      node.column,
      node.type,
      startingColor,
      endingColor,
    ));
    notifyListeners();

    await Future.delayed(Duration(milliseconds: animationTimeInMillisec));
  }

  void _addNodeBlock(NodeBlock newNodeBlock) {
    _nodeBlockAddingEventHandler.broadcast();
    _nodeBlocks.add(newNodeBlock);
  }

  (Color, Color) _getStartingAndEndingColors(NodeType type) {
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
}
