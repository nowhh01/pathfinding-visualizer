import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';

const int maxDistance = 99999;

class Node {
  final int row;
  final int column;
  Color color;
  int distance;
  Node? previousNode;

  Node(
      {this.color = Colors.white,
      this.distance = maxDistance,
      this.previousNode,
      required this.row,
      required this.column});

  @override
  // ignore: hash_and_equals
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
    int row,
    int colum, [
    Future<void> Function()? update,
  ]) async {
    var startNode = nodes[row][colum];
    startNode.color = Colors.grey;
    startNode.distance = 0;
    startNode.previousNode = null;

    final queue = Queue<Node>();
    queue.addLast(startNode);

    while (queue.isNotEmpty) {
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
        if (neighborNode?.color == Colors.white) {
          neighborNode!.color = Colors.grey;
          neighborNode.distance = startNode.distance + 1;
          neighborNode.previousNode = startNode;
          queue.addLast(neighborNode);
        }
      }

      await update?.call();
      // startNode.color = Colors.black;
    }
  }

  Future<void> findPath(
    Node startingNode,
    Node endingNode, [
    Future<void> Function()? update,
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
      await update?.call();
      endingNode.color = Colors.yellow;
      log('${endingNode.row}-${endingNode.column}');
    }
  }
}
