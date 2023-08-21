const int maxDistance = 99999;

enum NodeType {
  none,
  searchedNode,
  pathNode,
  startNode,
  targetNode,
  wallNode,
}

enum AlgorithmType {
  none,
  bfs,
  dfs,
  da,
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
}

class Graph {
  final int rowCount;
  final int columnCount;
  final List<List<Node>> nodes;

  Graph(this.rowCount, this.columnCount)
      : nodes = List<List<Node>>.generate(
          rowCount,
          (row) => List<Node>.generate(
            columnCount,
            (column) => Node(row: row, column: column),
          ),
        );

  List<Node?> findAdjacentNodes(Node node) {
    final adjacencies = List<Node?>.filled(4, null);

    for (var i = 0; i < 4; ++i) {
      switch (i) {
        case 0:
          if (node.column + 1 < columnCount) {
            adjacencies[i] = nodes[node.row][node.column + 1];
          }
          break;
        case 1:
          if (node.row + 1 < rowCount) {
            adjacencies[i] = nodes[node.row + 1][node.column];
          }
          break;
        case 2:
          if (node.column > 0) {
            adjacencies[i] = nodes[node.row][node.column - 1];
          }
          break;
        case 3:
          if (node.row > 0) {
            adjacencies[i] = nodes[node.row - 1][node.column];
          }
          break;
        default:
          break;
      }
    }

    return adjacencies;
  }
}
