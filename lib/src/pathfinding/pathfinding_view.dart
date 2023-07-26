import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../algorithms/breadth_first_search.dart';

const rowCount = 10;
const columnCount = 10;
const startingPosition = (1, 2);
const endingPosition = (9, 7);
const double _boxSize = 50;

class BoardPainter extends CustomPainter {
  final double _boxSize;
  final double _heightAdjuster;
  final double _widthAdjuster;

  BoardPainter(this._boxSize, this._heightAdjuster, this._widthAdjuster);

  @override
  void paint(Canvas canvas, Size size) {
    final vLines = (size.width ~/ _boxSize) + 1;
    final hLines = (size.height ~/ _boxSize) + 1;

    final paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw vertical lines
    final endY = size.height - (_heightAdjuster * 2);
    for (var i = 0; i < vLines; ++i) {
      final x = _boxSize * i + _widthAdjuster;
      path.moveTo(x, _heightAdjuster);
      path.relativeLineTo(0, endY);
    }

    // Draw horizontal lines
    final endX = size.width - (_widthAdjuster * 2);
    for (var i = 0; i < hLines; ++i) {
      final y = _boxSize * i + _heightAdjuster;
      path.moveTo(_widthAdjuster, y);
      path.relativeLineTo(endX, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Block {
  Block(rowColumn, type)
      : _rowColumn = rowColumn,
        _type = type;

  final (int, int) _rowColumn;
  (int, int) get rowColumn => _rowColumn;

  final NodeType _type;
  NodeType get type => _type;
}

class MenuEntry {
  const MenuEntry(
      {required this.label, this.shortcut, this.onPressed, this.menuChildren})
      : assert(menuChildren == null || onPressed == null,
            'onPressed is ignored if menuChildren are provided');
  final String label;

  final MenuSerializableShortcut? shortcut;
  final VoidCallback? onPressed;
  final List<MenuEntry>? menuChildren;

  static List<Widget> build(List<MenuEntry> selections) {
    Widget buildSelection(MenuEntry selection) {
      if (selection.menuChildren != null) {
        return SubmenuButton(
          menuChildren: MenuEntry.build(selection.menuChildren!),
          child: Text(selection.label),
        );
      }

      return MenuItemButton(
        shortcut: selection.shortcut,
        onPressed: selection.onPressed,
        child: Text(selection.label),
      );
    }

    return selections.map<Widget>(buildSelection).toList();
  }

  static Map<MenuSerializableShortcut, Intent> shortcuts(
      List<MenuEntry> selections) {
    final Map<MenuSerializableShortcut, Intent> result =
        <MenuSerializableShortcut, Intent>{};
    for (final MenuEntry selection in selections) {
      if (selection.menuChildren != null) {
        result.addAll(MenuEntry.shortcuts(selection.menuChildren!));
      } else {
        if (selection.shortcut != null && selection.onPressed != null) {
          result[selection.shortcut!] =
              VoidCallbackIntent(selection.onPressed!);
        }
      }
    }
    return result;
  }
}

class PathfindingView extends StatefulWidget {
  const PathfindingView({super.key});

  final padding = 5.0;
  static const routeName = '/';

  @override
  State<PathfindingView> createState() => _PathfindingViewState();
}

class _PathfindingViewState extends State<PathfindingView> {
  static const startingPosition = (1, 2);
  static const endingPosition = (9, 7);
  static const rowCount = 10;
  static const columnCount = 10;

  final _blocks = <Block>[];
  final _animationTimeInMillisec = 500;

  var _widthAdjuster = double.nan;
  var _heightAdjuster = double.nan;

  var _graph = Graph(rowCount, columnCount);
  Graph get graph => _graph;

  void reset() {
    _graph = Graph(rowCount, columnCount);

    setState(() {
      _blocks.clear();
    });
  }

  Future<void> update(Node node) async {
    setState(() {
      _blocks.add(Block((node.row, node.column), node.type));
    });

    await Future.delayed(Duration(milliseconds: _animationTimeInMillisec));
  }

  Future<void> startFindingPath() async {
    await _graph.bfs(
      graph.nodes[startingPosition.$1][startingPosition.$2],
      graph.nodes[endingPosition.$1][endingPosition.$2],
      update,
    );

    await _graph.findPath(graph.nodes[startingPosition.$1][startingPosition.$2],
        graph.nodes[endingPosition.$1][endingPosition.$2], update);
  }

  void _onTapDown(TapDownDetails details) {
    final row = (details.localPosition.dy - _heightAdjuster) ~/ _boxSize;
    final column = (details.localPosition.dx - _widthAdjuster) ~/ _boxSize;

    if (_graph.nodes[row][column].type == NodeType.none) {
      _graph.nodes[row][column].type = NodeType.wallNode;

      setState(() {
        _blocks.add(Block((row, column), NodeType.wallNode));
      });
    }
  }

  Offset _getOffset(
    int row,
    int column,
    double width,
    double height,
    double widthAdjuster,
    double heightAdjuster,
  ) {
    return Offset(
        column * width + widthAdjuster, row * height + heightAdjuster);
  }

  List<MenuEntry> _getMenus() {
    final List<MenuEntry> result = <MenuEntry>[
      MenuEntry(
        label: 'Algorithms',
        menuChildren: <MenuEntry>[
          MenuEntry(
            label: 'Breadth-First Search',
            onPressed: () {},
          ),
        ],
      ),
      MenuEntry(
        label: 'Clear Board',
        onPressed: reset,
      ),
      MenuEntry(
        label: 'Start',
        onPressed: startFindingPath,
      )
    ];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pathfindingViewTitle),
        actions: MenuEntry.build(_getMenus()),
      ),
      body: Padding(
        padding: EdgeInsets.all(widget.padding),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 16,
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  children: [
                    FittedBox(
                      child: Row(
                        children: [
                          Icon(Icons.chevron_right),
                          Text('Start Node'),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          Icon(Icons.adjust),
                          Text('Target Node'),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          Icon(
                            Icons.square_outlined,
                            color: Colors.red,
                          ),
                          Text('Unvisited Node'),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          Icon(Icons.square, color: Colors.greenAccent),
                          Text('Visited Node'),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          Icon(
                            Icons.square,
                            color: Colors.yellow,
                          ),
                          Text('Shortest Path Node'),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          Icon(
                            Icons.square,
                            color: Colors.black,
                          ),
                          Text('Wall Node'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTapDown: _onTapDown,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _widthAdjuster = constraints.maxWidth % _boxSize / 2;
                        _heightAdjuster = constraints.maxHeight % _boxSize / 2;

                        final animatedBlocks = List<Widget>.generate(
                          _blocks.length,
                          (i) {
                            final block = _blocks[i];
                            final (row, column) = block.rowColumn;

                            return AnimatedBlock(
                              key: ObjectKey(block),
                              _boxSize,
                              _getOffset(row, column, _boxSize, _boxSize,
                                  _widthAdjuster, _heightAdjuster),
                              block.type,
                              _animationTimeInMillisec,
                            );
                          },
                        );

                        return CustomPaint(
                          painter: BoardPainter(
                              _boxSize, _heightAdjuster, _widthAdjuster),
                          child: SizedBox(
                            width: double.infinity,
                            child: Stack(
                              children: [
                                BlockPaint(
                                  size: const Size(_boxSize, _boxSize),
                                  // color: Colors.pink,
                                  icon: Icons.chevron_right,
                                  offset: _getOffset(
                                      startingPosition.$1,
                                      startingPosition.$2,
                                      _boxSize,
                                      _boxSize,
                                      _widthAdjuster,
                                      _heightAdjuster),
                                ),
                                ...animatedBlocks,
                                BlockPaint(
                                  size: const Size(_boxSize, _boxSize),
                                  // color: Colors.pink,
                                  icon: Icons.adjust,
                                  offset: _getOffset(
                                      endingPosition.$1,
                                      endingPosition.$2,
                                      _boxSize,
                                      _boxSize,
                                      _widthAdjuster,
                                      _heightAdjuster),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBlock extends StatefulWidget {
  final double width;
  final Offset offset;
  final int animationTimeInMillisec;
  final NodeType nodeType;

  const AnimatedBlock(
      this.width, this.offset, this.nodeType, this.animationTimeInMillisec,
      {super.key});

  @override
  State<AnimatedBlock> createState() => _AnimatedBlockState();
}

class _AnimatedBlockState extends State<AnimatedBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.animationTimeInMillisec),
      vsync: this,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.nodeType) {
      case NodeType.searchedNode:
        return AnimatedBlock1(
          controller: _controller,
          width: widget.width,
          offset: widget.offset,
          color1: Colors.indigoAccent,
          color2: Colors.greenAccent,
        );
      case NodeType.pathNode:
        return AnimatedBlock1(
          controller: _controller,
          width: widget.width,
          offset: widget.offset,
          color1: Colors.yellowAccent,
          color2: Colors.yellowAccent,
        );
      case NodeType.wallNode:
        return AnimatedBlock1(
          controller: _controller,
          width: widget.width,
          offset: widget.offset,
          color1: Colors.grey,
          color2: Colors.black,
        );
      default:
        return Container();
    }
  }
}

class AnimatedBlock1 extends AnimatedWidget {
  AnimatedBlock1({
    Key? key,
    required Animation<double> controller,
    required double width,
    required Offset offset,
    required Color color1,
    required Color color2,
  })  : _size = SizeTween(
          begin: const Size(0.0, 0.0),
          end: Size(width * 1.2, width * 1.2),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.0,
              0.8,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        _sizeForSubtraction = SizeTween(
          begin: const Size(0.0, 0.0),
          end: Size(width * 0.2, width * 0.2),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.8,
              1.0,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        color = ColorTween(
          begin: color1,
          end: color2,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.0,
              1.0,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        _offset = Tween<Offset>(
          begin: Offset(offset.dx + (width / 2), offset.dy + (width / 2)),
          end: Offset(offset.dx - (width * 0.1), offset.dy - (width * 0.1)),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.0,
              0.8,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        _offsetForAddition = Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: Offset(width * 0.1, width * 0.1),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.8,
              1.0,
              curve: Curves.easeInToLinear,
            ),
          ),
        ),
        super(key: key, listenable: controller);

  final Animation<Size?> _size;
  final Animation<Size?> _sizeForSubtraction;
  final Animation<Offset> _offset;
  final Animation<Offset> _offsetForAddition;
  final Animation<Color?> color;

  @override
  Widget build(BuildContext context) {
    final size = _size.value ?? Size.zero;
    final sizeForSubtraction = _sizeForSubtraction.value ?? Size.zero;
    final offset = _offset.value;
    final offsetForAddition = _offsetForAddition.value;

    return BlockPaint(
      size: size,
      sizeForSubtraction: sizeForSubtraction,
      color: color.value!,
      offset: offset,
      offsetForAddition: offsetForAddition,
    );
  }
}

class BlockPaint extends StatelessWidget {
  const BlockPaint({
    super.key,
    required this.size,
    required this.offset,
    this.color = Colors.black,
    this.icon,
    this.sizeForSubtraction = Size.zero,
    this.offsetForAddition = Offset.zero,
  });

  final Size size;
  final Size sizeForSubtraction;
  final Color color;
  final Offset offset;
  final Offset offsetForAddition;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BlockPainter(
          size.width - sizeForSubtraction.width,
          size.height - sizeForSubtraction.width,
          color,
          offset.dx + offsetForAddition.dx,
          offset.dy + offsetForAddition.dy,
          icon),
    );
  }
}

class BlockPainter extends CustomPainter {
  final double width;
  final double height;
  final Color color;
  final double xPos;
  final double yPos;
  final IconData? icon;

  BlockPainter(this.width, this.height, this.color, this.xPos, this.yPos,
      [this.icon]);

  @override
  void paint(Canvas canvas, Size size) {
    if (icon != null) {
      final textPainter = TextPainter(textDirection: TextDirection.rtl);
      textPainter.text = TextSpan(
          text: String.fromCharCode(icon!.codePoint),
          style: TextStyle(
              fontSize: width, fontFamily: icon!.fontFamily, color: color));
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos, yPos));
    } else {
      final paint = Paint()
        ..strokeWidth = 5
        ..color = color
        ..style = PaintingStyle.fill;
      final square = Rect.fromLTWH(xPos, yPos, width, height);

      canvas.drawRect(square, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is BlockPainter) {
      if (oldDelegate.color != color ||
          oldDelegate.width != width ||
          xPos != oldDelegate.xPos ||
          oldDelegate.yPos != yPos) {
        return true;
      }
    }

    return false;
  }
}
