import 'package:stack/stack.dart';

import 'graph.dart';

extension DepthFirstSearch on Graph {
  Future<void> dfs(
    Node startingNode,
    Node endingNode, [
    Future<void> Function(Node)? update,
  ]) async {
    final stack = Stack<Node>();
    for (var adjacentNode in findAdjacentNodes(startingNode)) {
      if (adjacentNode != null) {
        stack.push(adjacentNode);
      }
    }

    var isEndingNodeFound = false;
    while (stack.isNotEmpty && !isEndingNodeFound) {
      final node = stack.pop();

      if (node.type == NodeType.none) {
        node.type = NodeType.searchedNode;
        node.previousNode = startingNode;
        node.distance = startingNode.distance + 1;
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
          startingNode = node;
        }
      }

      if (node == endingNode) {
        node.distance = startingNode.distance + 1;
        node.previousNode = startingNode;
        isEndingNodeFound = true;
        break;
      }
    }
  }
}
