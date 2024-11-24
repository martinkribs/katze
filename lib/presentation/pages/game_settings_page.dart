import 'package:flutter/material.dart';
import 'package:katze/presentation/providers/game_provider.dart';
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
      final gameProvider = context.read<GameProvider>();
      await gameProvider.loadGameDetails(widget.gameId.toString());
      
      // Only load settings if game is pending
      if (gameProvider.currentGame?['status'] == 'pending') {
        await gameProvider.loadGameSettings(widget.gameId.toString());
        await gameProvider.loadRoles();
        
        if (gameProvider.currentGameSettings != null) {
          setState(() {
            _useDefault = gameProvider.currentGameSettings!['use_default'];
            // Convert role configuration from Map<String, dynamic> to Map<String, int>
            final roleConfig = gameProvider.currentGameSettings!['role_configuration'] as Map<String, dynamic>;
            _roleConfiguration = roleConfig.map((key, value) => MapEntry(key, value as int));
          });
        }
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context, GameProvider gameProvider) async {
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
        await gameProvider.deleteGame(widget.gameId.toString());
        if (mounted) {
          // Refresh games list before navigating back
          await gameProvider.loadGames();
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
    final villagerRole = context.read<GameProvider>().roles
        .firstWhere((role) => role['key'] == 'villager', orElse: () => {});
    final catRole = context.read<GameProvider>().roles
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
      final gameProvider = context.read<GameProvider>();
      await gameProvider.updateGameSettings(
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

  Widget _buildRoleList(GameProvider gameProvider) {
    final effectiveConfiguration = 
        gameProvider.currentGameSettings?['effective_configuration'] as Map<String, dynamic>? ?? {};
    final effectiveMap = effectiveConfiguration.map((key, value) => MapEntry(key, value as int));

    // Group roles by team
    final Map<String, List<Map<String, dynamic>>> rolesByTeam = {};
    for (var role in gameProvider.roles) {
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
            if (!_useDefault && gameProvider.roles.isNotEmpty) ...[
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
                      title: Text(role['key']), // Using key instead of name
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
                        width: 180,
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
            ] else if (gameProvider.isLoading) ...[
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
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Game Settings'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: gameProvider.isLoading ? null : _saveSettings,
              ),
            ],
          ),
          body: gameProvider.isLoading && gameProvider.currentGameSettings == null
              ? const Center(child: CircularProgressIndicator())
              : gameProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            gameProvider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await gameProvider.loadGameSettings(
                                  widget.gameId.toString());
                              await gameProvider.loadRoles();
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
                          _buildRoleList(gameProvider),
                          const SizedBox(height: 16),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.delete_forever, color: Colors.red),
                              title: const Text(
                                'Delete Game',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () => _confirmDelete(context, gameProvider),
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
