import 'package:flutter/material.dart';

class RoleListItem extends StatelessWidget {
  final Map<String, dynamic> role;
  final int quantity;
  final VoidCallback onInfoPressed;
  final ValueChanged<int> onQuantityChanged;

  const RoleListItem({
    super.key,
    required this.role,
    required this.quantity,
    required this.onInfoPressed,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final roleKey = role['key']?.toString() ?? 'Unknown Role';
    
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(roleKey),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onInfoPressed,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.info_outline, size: 20),
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (role['allowed_phases']?.isNotEmpty == true)
            Text(
              'Can act in: ${_formatAllowedPhases(role['allowed_phases'])}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: SizedBox(
        width: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (quantity > 0) {
                  onQuantityChanged(quantity - 1);
                }
              },
            ),
            Text('$quantity'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onQuantityChanged(quantity + 1),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAllowedPhases(List<dynamic> phases) {
    final formattedPhases = phases.map((phase) {
      switch (phase) {
        case 'preparation':
          return 'Preparation';
        case 'day':
          return 'Day';
        case 'night':
          return 'Night';
        case 'voting':
          return 'Voting';
        default:
          return phase.toString();
      }
    }).toList();
    return formattedPhases.join(' & ');
  }
}
