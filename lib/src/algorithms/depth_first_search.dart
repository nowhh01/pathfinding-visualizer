import 'package:stack/stack.dart';

import 'graph.dart';

extension DepthFirstSearch on Graph {
  Future<void> dfs(
    Node startNode,
    Node targetNode, [
    Future<void> Function(Node)? update,
  ]) async {
    final stack = Stack<Node>();
    for (var adjacentNode in findAdjacentNodes(startNode)) {
      if (adjacentNode != null) {
        stack.push(adjacentNode);
      }
    }

    while (stack.isNotEmpty) {
      final node = stack.pop();

      if (node.type == NodeType.none) {
        node.type = NodeType.searchedNode;
        node.previousNode = startNode;
        node.distance = startNode.distance + 1;
        await update?.call(node);

        var isNewNodeAdded = false;
        for (var adjacentNode in findAdjacentNodes(node)) {
          if (adjacentNode != null &&
              (adjacentNode.type == NodeType.none ||
                  adjacentNode.type == NodeType.endingNode)) {
            stack.push(adjacentNode);
            isNewNodeAdded = true;
          }
        }

        if (isNewNodeAdded) {
          startNode = node;
        }
      }

      if (node == targetNode) {
        node.distance = startNode.distance + 1;
        node.previousNode = startNode;
        return;
      }
    }
  }
}
