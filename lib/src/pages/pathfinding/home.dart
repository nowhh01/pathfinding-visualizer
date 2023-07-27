import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'app_bar.dart';
import 'board_view.dart';
import 'info_container.dart';
import 'pathfinding_controller.dart';

class PathfindingView extends StatefulWidget {
  const PathfindingView({super.key});

  final padding = 5.0;
  static const routeName = '/';

  @override
  State<PathfindingView> createState() => _PathfindingViewState();
}

class _PathfindingViewState extends State<PathfindingView> {
  final _controller = PathfindingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: const PathfindingAppBar(),
        body: Padding(
          padding: EdgeInsets.all(widget.padding),
          child: const SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: InfoContainer(),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: BoardView(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
