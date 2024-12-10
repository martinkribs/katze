import 'package:flutter/material.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_management_provider.dart';
import 'package:katze/presentation/providers/game_settings_provider.dart';
import 'package:katze/presentation/providers/game_action_provider.dart';
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
    // Load current settings and available roles when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameManagementProvider = context.read<GameManagementProvider>();
      final gameSettingsProvider = context.read<GameSettingsProvider>();
      final gameActionProvider = context.read<GameActionProvider>();

      await gameManagementProvider.loadGameDetails(widget.gameId.toString());
      
      // Only load settings if game is pending
      if (gameManagementProvider.currentGame?['status'] == 'pending') {
        await gameSettingsProvider.loadGameSettings(widget.gameId.toString());
        await gameActionProvider.loadRoles();
        
        if (gameSettingsProvider.currentGameSettings != null) {
          setState(() {
            _useDefault = gameSettingsProvider.currentGameSettings!['use_default'];
            // Convert role configuration from Map<String, dynamic> to Map<String, int>
            final roleConfig = gameSettingsProvider.currentGameSettings!['role_configuration'] as Map<String, dynamic>;
            _roleConfiguration = roleConfig.map((key, value) => MapEntry(key, value as int));
          });
        }
      }
    });
  }

  void _showRoleInfo(BuildContext context, Map<String, dynamic> role) async {
    // Load action types for this role
    final gameActionProvider = context.read<GameActionProvider>();
    await gameActionProvider.loadRoleActionTypes(role['id'].toString());
    
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
                if (role['can_use_night_action'] == true)
                  const Text('• Can perform night actions'),
                if (role['can_vote'] == true)
                  const Text('• Can vote during day phase'),
                const SizedBox(height: 16),
                Text(
                  'Action Types',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Consumer<GameActionProvider>(
                  builder: (context, gameActionProvider, _) {
                    final actionTypes = gameActionProvider.roleActionTypes?['action_types'] ?? [];
                    if (actionTypes.isEmpty) {
                      return const Text('No special actions');
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...actionTypes.map((action) => Padding(
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
                                  action['is_day_action'] ? 'Day Action' : 'Night Action',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    );
                  },
                ),
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
          // Refresh games list before navigating back
          await gameManagementProvider.loadGames();
          Navigator.of(context).pop(); // Return to games list
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

  int get _totalPlayers => _roleConfiguration.values.fold(0, (sum, quantity) => sum + quantity);

  bool _canSaveSettings() {
    if (_useDefault) return true;

    // Check if there's at least one role
    if (_roleConfiguration.isEmpty) return false;

    // Find roles by ID
    final gameActionProvider = context.read<GameActionProvider>();
    final villagerRole = gameActionProvider.roles
        .firstWhere((role) => role['key'] == 'villager', orElse: () => {});
    final catRole = gameActionProvider.roles
        .firstWhere((role) => role['key'] == 'cat', orElse: () => {});

    // Check quantities using role IDs
    final hasVillager = villagerRole.isNotEmpty && 
        (_roleConfiguration[villagerRole['id'].toString()] ?? 0) > 0;
    final hasCat = catRole.isNotEmpty && 
        (_roleConfiguration[catRole['id'].toString()] ?? 0) > 0;

    return hasVillager && hasCat;
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

  Widget _buildRoleList(GameSettingsProvider gameSettingsProvider, GameActionProvider gameActionProvider) {
    final effectiveConfiguration = 
        gameSettingsProvider.currentGameSettings?['effective_configuration'] as Map<String, dynamic>? ?? {};
    final effectiveMap = effectiveConfiguration.map((key, value) => MapEntry(key, value as int));

    // Group roles by team
    final Map<String, List<Map<String, dynamic>>> rolesByTeam = {};
    for (var role in gameActionProvider.roles) {
      final teamName = role['team'] ?? 'Other';
      rolesByTeam.putIfAbsent(teamName, () => []).add(role);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Role Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Total Players: $_totalPlayers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Use Default Settings'),
              value: _useDefault,
              onChanged: (value) {
                setState(() {
                  _useDefault = value;
                  if (value) {
                    // Reset to effective configuration when switching to default
                    _roleConfiguration = Map<String, int>.from(effectiveMap);
                  }
                });
              },
            ),
            const Divider(),
            if (!_useDefault && gameActionProvider.roles.isNotEmpty) ...[
              ...rolesByTeam.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...entry.value.map((role) {
                    final roleId = role['id'].toString();
                    final quantity = _roleConfiguration[roleId] ?? 0;

                    return ListTile(
                      title: Row(
                        children: [
                          Text(role['key']), // Using key instead of name
                          IconButton(
                            icon: const Icon(Icons.info_outline, size: 20),
                            onPressed: () => _showRoleInfo(context, role),
                            padding: const EdgeInsets.only(left: 8),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (role['can_use_night_action'] == true)
                            Text(
                              'Night Action',
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
                                setState(() {
                                  if (quantity > 0) {
                                    _roleConfiguration[roleId] = quantity - 1;
                                  }
                                });
                              },
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _roleConfiguration[roleId] = quantity + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              )),
            ] else if (gameSettingsProvider.currentGameSettings == null) ...[
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              const Center(child: Text('No roles available')),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LoadingProvider, GameSettingsProvider, GameActionProvider>(
      builder: (context, loadingProvider, gameSettingsProvider, gameActionProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Game Settings'),
            actions: [
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
                              await gameActionProvider.loadRoles();
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
                          _buildRoleList(gameSettingsProvider, gameActionProvider),
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
