import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../algorithms/breadth_first_search.dart';
import '../settings/settings_view.dart';

const rowCount = 10;
const columnCount = 10;
const startingPosition = (1, 2);
const endingPosition = (9, 7);

class PathfindingView extends StatefulWidget {
  const PathfindingView({super.key});

  static const routeName = '/';

  @override
  State<PathfindingView> createState() => _PathfindingViewState();
}

class _PathfindingViewState extends State<PathfindingView> {
  var graph = Graph(rowCount, columnCount);

  void resetGraph() {
    setState(() {
      graph = Graph(rowCount, columnCount);
    });
  }

  Future<void> update() async {
    setState(() {
      graph = graph;
      // count += 1;
    });

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pathfindingViewTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(
                context,
                SettingsView.routeName,
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minimumLength = constraints.maxWidth > constraints.maxHeight
              ? constraints.maxHeight
              : constraints.maxWidth;
          final width = minimumLength / 10 / 3;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    await graph.bfs(
                      startingPosition.$1,
                      startingPosition.$2,
                      update,
                    );

                    graph.findPath(
                        graph.nodes[startingPosition.$1][startingPosition.$2],
                        graph.nodes[endingPosition.$1][endingPosition.$2],
                        update);
                  },
                  child: const Text('start')),
              ElevatedButton(onPressed: resetGraph, child: const Text('reset')),
              for (var r in List.generate(rowCount, (index) => index))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(columnCount, (index) => index)
                      .map<Widget>((c) {
                    final node = graph.nodes[r][c];

                    return Block(
                        key: ValueKey('${node.row}${node.column}${node.color}'),
                        node: node,
                        width: width);
                  }).toList(),
                )
            ],
          );
        },
      ),
    );
  }
}

class Block extends StatelessWidget {
  const Block({
    super.key,
    required this.node,
    required this.width,
  });

  final Node node;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.black),
              color: node.color),
          padding: EdgeInsets.all(width),
        ),
        if ((node.row == startingPosition.$1 &&
                node.column == startingPosition.$2) ||
            (node.row == endingPosition.$1 && node.column == endingPosition.$2))
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
            ),
            padding: EdgeInsets.all(width / 2),
          )
      ],
    );
  }
}
