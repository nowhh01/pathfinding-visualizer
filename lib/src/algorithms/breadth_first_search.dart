import 'dart:collection';
import 'dart:developer';

import 'graph.dart';

extension BreadthFirstSearch on Graph {
  Future<void> bfs(
    Node startNode,
    Node targetNode, [
    Future<void> Function(Node)? update,
  ]) async {
    startNode.distance = 0;

    final queue = Queue<Node>();
    queue.addLast(startNode);

    while (queue.isNotEmpty) {
      startNode = queue.removeFirst();
      final adjacencies = findAdjacentNodes(startNode);

      for (var neighborNode in adjacencies) {
        if (neighborNode?.type == NodeType.none) {
          neighborNode!.type = NodeType.searchedNode;
          neighborNode.distance = startNode.distance + 1;
          neighborNode.previousNode = startNode;
          queue.addLast(neighborNode);

          await update?.call(neighborNode);
        }

        if (neighborNode == targetNode) {
          neighborNode!.distance = startNode.distance + 1;
          neighborNode.previousNode = startNode;
          return;
        }
      }
    }
  }

  Future<void> findPath(
    Node startNode,
    Node targetNode, [
    Future<void> Function(Node)? update,
  ]) async {
    if (startNode == targetNode) {
      log('${targetNode.row}-${targetNode.column} same');
    } else if (targetNode.previousNode == null) {
      log('${targetNode.row}-${targetNode.column} no path');
    } else {
      await findPath(
        startNode,
        targetNode.previousNode!,
        update,
      );

      if (targetNode.type != NodeType.endingNode) {
        targetNode.type = NodeType.pathNode;
      }
      await update?.call(targetNode);
      log('${targetNode.row}-${targetNode.column}');
    }
  }
}
