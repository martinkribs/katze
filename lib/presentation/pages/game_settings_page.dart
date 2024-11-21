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
  // Role distribution
  double _villagerCount = 3.0;
  double _catCount = 1.0;
  bool _includeSeer = false;
  bool _includeWitch = false;
  bool _includeHunter = false;

  // Game rules
  bool _allowNightChat = false;
  int _votingTime = 60; // seconds
  int _nightTime = 30; // seconds

  @override
  void initState() {
    super.initState();
    // Load current settings when available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      final settings = gameProvider.currentGame?['settings'];
      if (settings != null) {
        setState(() {
          _villagerCount = (settings['villagerCount'] ?? 3).toDouble();
          _catCount = (settings['catCount'] ?? 1).toDouble();
          _includeSeer = settings['includeSeer'] ?? false;
          _includeWitch = settings['includeWitch'] ?? false;
          _includeHunter = settings['includeHunter'] ?? false;
          _allowNightChat = settings['allowNightChat'] ?? false;
          _votingTime = settings['votingTime'] ?? 60;
          _nightTime = settings['nightTime'] ?? 30;
        });
      }
    });
  }

  void _saveSettings() async {
    final settings = {
      'villagerCount': _villagerCount.round(),
      'catCount': _catCount.round(),
      'includeSeer': _includeSeer,
      'includeWitch': _includeWitch,
      'includeHunter': _includeHunter,
      'allowNightChat': _allowNightChat,
      'votingTime': _votingTime,
      'nightTime': _nightTime,
    };

    try {
      final gameProvider = context.read<GameProvider>();
      await gameProvider.updateGameSettings(
        gameId: widget.gameId.toString(),
        settings: settings,
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
          body: gameProvider.isLoading
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
                            onPressed: () => gameProvider.loadGameDetails(widget.gameId.toString()),
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
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Role Distribution',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildRoleSlider(
                                    label: 'Villagers',
                                    value: _villagerCount,
                                    min: 3,
                                    max: 10,
                                    onChanged: (value) {
                                      setState(() => _villagerCount = value);
                                    },
                                  ),
                                  _buildRoleSlider(
                                    label: 'Cats',
                                    value: _catCount,
                                    min: 1,
                                    max: 3,
                                    onChanged: (value) {
                                      setState(() => _catCount = value);
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Include Seer'),
                                    value: _includeSeer,
                                    onChanged: (value) {
                                      setState(() => _includeSeer = value);
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Include Witch'),
                                    value: _includeWitch,
                                    onChanged: (value) {
                                      setState(() => _includeWitch = value);
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Include Hunter'),
                                    value: _includeHunter,
                                    onChanged: (value) {
                                      setState(() => _includeHunter = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Game Rules',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  SwitchListTile(
                                    title: const Text('Allow Night Chat'),
                                    subtitle: const Text(
                                        'Cats can chat during the night'),
                                    value: _allowNightChat,
                                    onChanged: (value) {
                                      setState(() => _allowNightChat = value);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Voting Time'),
                                    subtitle: Text('$_votingTime seconds'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              if (_votingTime > 30) {
                                                _votingTime -= 10;
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              if (_votingTime < 120) {
                                                _votingTime += 10;
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('Night Time'),
                                    subtitle: Text('$_nightTime seconds'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              if (_nightTime > 20) {
                                                _nightTime -= 5;
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              if (_nightTime < 60) {
                                                _nightTime += 5;
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildRoleSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
