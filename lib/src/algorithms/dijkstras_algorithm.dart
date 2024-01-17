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

    // final set = <Node>{};
    const weight = 1;
    startNode.distance = 0;

    while (queue.isNotEmpty) {
      queue.sort((a, b) => b.distance.compareTo(a.distance));
      final node = queue.removeLast();
      // set.add(node);

      for (var neighborNode in findAdjacentNodes(node)) {
        if (neighborNode != null) {
          if (neighborNode.type != NodeType.wallNode &&
              relax(node, neighborNode, weight)) {
            if (neighborNode.type == NodeType.targetNode) {
              return;
            }

            neighborNode.type = NodeType.searchedNode;
            await update?.call(neighborNode);
          }
        }
      }
    }

    var ddd = 1;
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
