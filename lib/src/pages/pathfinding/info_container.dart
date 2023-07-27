import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoContainer extends StatelessWidget {
  const InfoContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8.0,
      runSpacing: 16,
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      children: [
        FittedBox(
          child: Row(
            children: [
              const Icon(Icons.chevron_right),
              Text(localizations.startBlock),
            ],
          ),
        ),
        FittedBox(
          child: Row(
            children: [
              const Icon(Icons.adjust),
              Text(localizations.targetBlock),
            ],
          ),
        ),
        FittedBox(
          child: Row(
            children: [
              const Icon(Icons.square_outlined, color: Colors.red),
              Text(localizations.unvisitedBlock),
            ],
          ),
        ),
        FittedBox(
          child: Row(
            children: [
              const Icon(Icons.square, color: Colors.greenAccent),
              Text(localizations.visitedBlock),
            ],
          ),
        ),
        FittedBox(
          child: Row(
            children: [
              const Icon(Icons.square, color: Colors.yellow),
              Text(localizations.shortestPathBlock),
            ],
          ),
        ),
        FittedBox(
          child: Row(
            children: [
              const Icon(Icons.square, color: Colors.black),
              Text(localizations.wallBlock),
            ],
          ),
        ),
      ],
    );
  }
}
