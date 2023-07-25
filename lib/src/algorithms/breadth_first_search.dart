import 'dart:collection';
import 'dart:developer';

const int maxDistance = 99999;

enum NodeType {
  none,
  searchedNode,
  pathNode,
  startingNode,
  endingNode,
  wallNode,
}

class Node {
  int row;
  int column;
  NodeType type;
  int distance;
  Node? previousNode;

  Node(
      {this.type = NodeType.none,
      this.distance = maxDistance,
      this.previousNode,
      required this.row,
      required this.column});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          column == other.column;
}

class Graph {
  late final int rowCount;
  late final int columnCount;
  late final List<List<Node>> nodes;

  Graph(this.rowCount, this.columnCount) {
    nodes = List<List<Node>>.generate(
      rowCount,
      (row) => List<Node>.generate(
        columnCount,
        (column) => Node(row: row, column: column),
      ),
    );
  }

  Future<void> bfs(
    Node startingNode,
    Node endingNode, [
    Future<void> Function(Node)? update,
  ]) async {
    var startNode = nodes[startingNode.row][startingNode.column];
    startNode.type = NodeType.searchedNode;
    startNode.distance = 0;
    startNode.previousNode = null;

    final queue = Queue<Node>();
    queue.addLast(startNode);
    var isEndingNodeFound = false;

    while (queue.isNotEmpty && !isEndingNodeFound) {
      startNode = queue.removeFirst();

      var adjacencies = List<Node?>.filled(4, null);
      for (var i = 0; i < 4; ++i) {
        switch (i) {
          case 0:
            if (startNode.column + 1 < columnCount) {
              adjacencies[0] = nodes[startNode.row][startNode.column + 1];
            }
            break;
          case 1:
            if (startNode.column > 0) {
              adjacencies[1] = nodes[startNode.row][startNode.column - 1];
            }
            break;
          case 2:
            if (startNode.row + 1 < rowCount) {
              adjacencies[2] = nodes[startNode.row + 1][startNode.column];
            }
            break;
          case 3:
            if (startNode.row > 0) {
              adjacencies[3] = nodes[startNode.row - 1][startNode.column];
            }
            break;
          default:
            break;
        }
      }

      for (var neighborNode in adjacencies) {
        if (neighborNode?.type == NodeType.none) {
          neighborNode!.type = NodeType.searchedNode;
          neighborNode.distance = startNode.distance + 1;
          neighborNode.previousNode = startNode;
          queue.addLast(neighborNode);

          await update?.call(neighborNode);

          if (neighborNode == endingNode) {
            isEndingNodeFound = true;
            break;
          }
        }
      }
    }
  }

  Future<void> findPath(
    Node startingNode,
    Node endingNode, [
    Future<void> Function(Node)? update,
  ]) async {
    if (startingNode == endingNode) {
      log('${endingNode.row}-${endingNode.column} same');
    } else if (endingNode.previousNode == null) {
      log('${endingNode.row}-${endingNode.column} no path');
    } else {
      await findPath(
        startingNode,
        endingNode.previousNode!,
        update,
      );
      endingNode.type = NodeType.pathNode;
      await update?.call(endingNode);
      log('${endingNode.row}-${endingNode.column}');
    }
  }
}
