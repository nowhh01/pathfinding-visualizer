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
    final localizations = AppLocalizations.of(context)!;
    final controller = context.read<PathfindingController>();

    return AppBar(
      title: Text(localizations.pathfindingViewTitle),
      actions: [
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {},
              child: Text(localizations.menuItemBfs),
            )
          ],
          child: Text(localizations.menuItemAlgorithms),
        ),
        MenuItemButton(
          onPressed: controller.reset,
          child: Text(localizations.menuItemClearBoard),
        ),
        MenuItemButton(
          onPressed: controller.startFindingPath,
          child: Text(localizations.menuItemStart),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                controller.speedType = SpeedType.fast;
              },
              child: Text(localizations.menuItemSpeedFast),
            ),
            MenuItemButton(
              onPressed: () {
                controller.speedType = SpeedType.normal;
              },
              child: Text(localizations.menuItemSpeedNormal),
            ),
            MenuItemButton(
              onPressed: () {
                controller.speedType = SpeedType.slow;
              },
              child: Text(localizations.menuItemSpeedSlow),
            ),
          ],
          child: Text(
            _getSpeedSubmenuButtonLabel(
              localizations,
              context.select((PathfindingController c) => c.speedType),
            ),
          ),
        ),
      ],
    );
  }

  String _getSpeedSubmenuButtonLabel(
    AppLocalizations localizations,
    SpeedType type,
  ) {
    switch (type) {
      case SpeedType.fast:
        return '${localizations.menuItemSpeed}: ${localizations.menuItemSpeedFast}';
      case SpeedType.normal:
        return '${localizations.menuItemSpeed}: ${localizations.menuItemSpeedNormal}';
      case SpeedType.slow:
        return '${localizations.menuItemSpeed}: ${localizations.menuItemSpeedSlow}';
      default:
        throw Exception('$type doesn\'t exist in SpeedType enum');
    }
  }
}
