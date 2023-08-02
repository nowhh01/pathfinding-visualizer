import 'dart:collection';
import 'dart:developer';

import 'graph.dart';

extension BreadthFirstSearch on Graph {
  Future<void> bfs(
    Node startingNode,
    Node endingNode, [
    Future<void> Function(Node)? update,
  ]) async {
    startingNode.type = NodeType.searchedNode;
    startingNode.distance = 0;
    startingNode.previousNode = null;

    final queue = Queue<Node>();
    queue.addLast(startingNode);
    var isEndingNodeFound = false;

    while (queue.isNotEmpty && !isEndingNodeFound) {
      startingNode = queue.removeFirst();
      final adjacencies = findAdjacentNodes(startingNode);

      for (var neighborNode in adjacencies) {
        if (neighborNode?.type == NodeType.none) {
          neighborNode!.type = NodeType.searchedNode;
          neighborNode.distance = startingNode.distance + 1;
          neighborNode.previousNode = startingNode;
          queue.addLast(neighborNode);

          await update?.call(neighborNode);
        }

        if (neighborNode == endingNode) {
          neighborNode!.distance = startingNode.distance + 1;
          neighborNode.previousNode = startingNode;
          isEndingNodeFound = true;
          break;
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

      if (endingNode.type != NodeType.endingNode) {
        endingNode.type = NodeType.pathNode;
      }
      await update?.call(endingNode);
      log('${endingNode.row}-${endingNode.column}');
    }
  }
}
