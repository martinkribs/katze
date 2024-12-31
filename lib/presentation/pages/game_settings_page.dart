import 'package:flutter/material.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_management_provider.dart';
import 'package:katze/presentation/providers/game_settings_provider.dart';
import 'package:katze/presentation/providers/role_info_provider.dart';
import 'package:katze/presentation/widgets/role_settings_card.dart';
import 'package:provider/provider.dart';

class GameSettingsPage extends StatefulWidget {
  final int gameId;

  const GameSettingsPage({
    super.key,
    required this.gameId,
  });

  @override
  State<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  bool _useDefault = true;
  Map<String, int> _roleConfiguration = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameManagementProvider = context.read<GameManagementProvider>();
      final gameSettingsProvider = context.read<GameSettingsProvider>();
      final roleInfoProvider = context.read<RoleInfoProvider>();

      await gameManagementProvider.loadGameDetails(widget.gameId.toString());
      
      if (gameManagementProvider.currentGame?['status'] == 'pending') {
        await gameSettingsProvider.loadGameSettings(widget.gameId.toString());
        await roleInfoProvider.loadRoles();
        
        if (gameSettingsProvider.currentGameSettings != null) {
          setState(() {
            _useDefault = gameSettingsProvider.currentGameSettings!['use_default'];
            final roleConfig = gameSettingsProvider.currentGameSettings!['role_configuration'] as Map<String, dynamic>;
            _roleConfiguration = roleConfig.map((key, value) => MapEntry(key, value as int));
          });
        }
      }
    });
  }

  void _showRoleInfo(BuildContext context, String roleId) async {
    final roleInfoProvider = context.read<RoleInfoProvider>();
    final role = roleInfoProvider.roles.firstWhere(
      (r) => r['id'].toString() == roleId,
      orElse: () => {},
    );
    if (role.isEmpty) return;

    final actionTypes = await roleInfoProvider.getRoleActionTypes(roleId);
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(role['key'].toString().toUpperCase()),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (role['description'] != null) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(role['description'].toString()),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Team',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(role['team'] ?? 'No team'),
                const SizedBox(height: 16),
                Text(
                  'Abilities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (role['allowed_phases']?.isNotEmpty == true) ...[
                  Text('• Can act during: ${_formatAllowedPhases(role['allowed_phases'])}'),
                ],
                if (role['can_vote'] == true)
                  const Text('• Can vote during voting phase'),
                const SizedBox(height: 16),
                Text(
                  'Action Types',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (actionTypes['action_types']?.isEmpty ?? true) ...[
                  const Text('No special actions'),
                ] else ...[
                  ...((actionTypes['action_types'] as List).map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${action['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (action['description'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(action['description']),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Allowed in: ${_formatAllowedPhases(action['allowed_phases'])}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final gameManagementProvider = context.read<GameManagementProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Game'),
          content: const Text('Are you sure you want to delete this game? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await gameManagementProvider.deleteGame(widget.gameId.toString());
        if (mounted) {
          await gameManagementProvider.loadGames();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete game: $e')),
          );
        }
      }
    }
  }

  bool _canSaveSettings() {
    if (_useDefault) return true;

    if (_roleConfiguration.isEmpty) return false;

    final roleInfoProvider = context.read<RoleInfoProvider>();
    final villagerRole = roleInfoProvider.roles
        .firstWhere((role) => role['key'] == 'villager', orElse: () => {});
    final catRole = roleInfoProvider.roles
        .firstWhere((role) => role['key'] == 'cat', orElse: () => {});

    final hasVillager = villagerRole.isNotEmpty && 
        (_roleConfiguration[villagerRole['id'].toString()] ?? 0) > 0;
    final hasCat = catRole.isNotEmpty && 
        (_roleConfiguration[catRole['id'].toString()] ?? 0) > 0;

    return hasVillager && hasCat;
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

  void _saveSettings() async {
    if (!_canSaveSettings()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid role configuration')),
      );
      return;
    }

    try {
      final gameSettingsProvider = context.read<GameSettingsProvider>();
      await gameSettingsProvider.updateGameSettings(
        gameId: widget.gameId.toString(),
        useDefault: _useDefault,
        roleConfiguration: _roleConfiguration,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LoadingProvider, GameSettingsProvider, RoleInfoProvider>(
      builder: (context, loadingProvider, gameSettingsProvider, roleInfoProvider, _) {
        final effectiveConfiguration = 
            gameSettingsProvider.currentGameSettings?['effective_configuration'] as Map<String, dynamic>? ?? {};
        final effectiveMap = effectiveConfiguration.map((key, value) => MapEntry(key, value as int));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Game Settings'),
            actions: [
              if (context.read<GameManagementProvider>().currentGame?['status'] == 'pending')
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: loadingProvider.isLoading ? null : _saveSettings,
                ),
            ],
          ),
          body: loadingProvider.isLoading && gameSettingsProvider.currentGameSettings == null
              ? const Center(child: CircularProgressIndicator())
              : loadingProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loadingProvider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await gameSettingsProvider.loadGameSettings(
                                  widget.gameId.toString());
                              await roleInfoProvider.loadRoles();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (context.read<GameManagementProvider>().currentGame?['status'] == 'pending') RoleSettingsCard(
                            useDefault: _useDefault,
                            onDefaultChanged: (value) {
                              setState(() {
                                _useDefault = value;
                                if (value) {
                                  _roleConfiguration = Map<String, int>.from(effectiveMap);
                                }
                              });
                            },
                            roleConfiguration: _roleConfiguration,
                            effectiveConfiguration: effectiveMap,
                            roles: roleInfoProvider.roles,
                            onRoleInfoPressed: (roleId) => _showRoleInfo(context, roleId),
                            onRoleQuantityChanged: (roleId, quantity) {
                              setState(() {
                                _roleConfiguration[roleId] = quantity;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.delete_forever, color: Colors.red),
                              title: const Text(
                                'Delete Game',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () => _confirmDelete(context),
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
