import 'package:flutter/material.dart';
import 'package:katze/presentation/widgets/role_list_item.dart';

class RoleSettingsCard extends StatelessWidget {
  final bool useDefault;
  final ValueChanged<bool> onDefaultChanged;
  final Map<String, int> roleConfiguration;
  final Map<String, int> effectiveConfiguration;
  final List<Map<String, dynamic>> roles;
  final ValueChanged<String> onRoleInfoPressed;
  final Function(String, int) onRoleQuantityChanged;

  const RoleSettingsCard({
    super.key,
    required this.useDefault,
    required this.onDefaultChanged,
    required this.roleConfiguration,
    required this.effectiveConfiguration,
    required this.roles,
    required this.onRoleInfoPressed,
    required this.onRoleQuantityChanged,
  });

  int get totalPlayers =>
      roleConfiguration.values.fold(0, (sum, quantity) => sum + quantity);

  @override
  Widget build(BuildContext context) {
    // Group roles by team
    final Map<String, List<Map<String, dynamic>>> rolesByTeam = {};
    for (var role in roles) {
      final teamName = role['team'] ?? 'Other';
      rolesByTeam.putIfAbsent(teamName, () => []).add(role);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Use Default Settings'),
              value: useDefault,
              onChanged: onDefaultChanged,
            ),
            const Divider(),
            if (!useDefault && roles.isNotEmpty) ...[
              ...rolesByTeam.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          entry.key,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      ...entry.value.map((role) {
                        final roleId = role['id'].toString();
                        return RoleListItem(
                          role: role,
                          quantity: roleConfiguration[roleId] ?? 0,
                          onInfoPressed: () => onRoleInfoPressed(roleId),
                          onQuantityChanged: (value) =>
                              onRoleQuantityChanged(roleId, value),
                        );
                      }),
                    ],
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Players Required: $totalPlayers',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
