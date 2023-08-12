import 'graph.dart';

extension DijkstrasAlgorithm on Graph {
  Future<void> da(
    Node startNode,
    Node targetNode, [
    Future<void> Function(Node)? update,
  ]) async {
    final queue = <Node>[];

    for (var i = 0; i < nodes.length; ++i) {
      for (var k = 0; k < nodes[i].length; ++k) {
        queue.add(nodes[i][k]);
      }
    }

    queue.sort((a, b) => (b.row + b.column).compareTo(a.row + a.column));
    startNode.distance = 0;

    final set = <Node>{};
    final weight = 1;

    while (queue.isNotEmpty) {
      final node = queue.last;
      queue.removeLast();
      set.add(node);

      for (var neighborNode in findAdjacentNodes(node)) {
        if (neighborNode != null) {
          if (relax(node, neighborNode, weight)) {
            if (neighborNode.type == NodeType.targetNode) {
              return;
            } else {
              neighborNode.type = NodeType.searchedNode;
              await update?.call(neighborNode);
            }
          }
        }
      }
    }
  }

  bool relax(Node node, Node targetNode, int weight) {
    if (targetNode.distance > node.distance + weight) {
      targetNode.distance = node.distance + weight;
      targetNode.previousNode = node;

      return true;
    }

    return false;
  }
}
