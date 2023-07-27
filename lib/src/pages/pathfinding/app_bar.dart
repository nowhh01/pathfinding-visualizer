import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'pathfinding_controller.dart';

class PathfindingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PathfindingAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final controller = context.read<PathfindingController>();

    return AppBar(
      title: Text(AppLocalizations.of(context)!.pathfindingViewTitle),
      actions: [
        SubmenuButton(
          child: Text('Algorithms'),
          menuChildren: [
            MenuItemButton(
              onPressed: () {},
              child: Text('Breadth-First Search'),
            )
          ],
        ),
        MenuItemButton(
          onPressed: controller.resetGraph,
          child: Text('Clear Board'),
        ),
        MenuItemButton(
          onPressed: controller.startFindingPath,
          child: Text('Start'),
        ),
        SubmenuButton(
          child: Text(
              'Speed: ${context.select((PathfindingController c) => c.speedType).name}'),
          menuChildren: [
            for (var type in SpeedType.values)
              MenuItemButton(
                onPressed: () {
                  controller.speedType = type;
                },
                child: Text('${type.name}'),
              )
          ],
        ),
      ],
    );
  }
}
