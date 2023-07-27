import 'package:flutter/material.dart';

class InfoContainer extends StatelessWidget {
  const InfoContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Wrap(
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
    );
  }
}
