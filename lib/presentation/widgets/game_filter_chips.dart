import 'package:flutter/material.dart';
import 'package:katze/core/enums/game_status.dart';

class GameFilterChips extends StatelessWidget {
  final Set<GameStatus> selectedFilters;
  final Function(GameStatus) onFilterToggled;

  const GameFilterChips({
    super.key,
    required this.selectedFilters,
    required this.onFilterToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: GameStatus.values.map((status) {
          final isSelected = selectedFilters.contains(status);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status.displayName),
              selected: isSelected,
              onSelected: (_) => onFilterToggled(status),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.8),
              checkmarkColor: Theme.of(context).textTheme.bodyLarge?.color,
              labelStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
