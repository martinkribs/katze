import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/core/services/game_service.dart';
import 'package:katze/presentation/providers/theme_provider.dart';

class CreateGameState extends ChangeNotifier {
  final AuthService _authService;
  final GameService _gameService;

  CreateGameState(this._authService, this._gameService);

  Future<void> createGame({
    required String name, 
    required String userId,
    required Map<String, dynamic> settings
  }) async {
    try {
      await _gameService.createGame(
        name: name, 
        settings: settings
      );
    } catch (e) {
      // Handle error, possibly with a method to get error message
      rethrow;
    }
  }
}

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  _CreateGamePageState createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final _gameNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Role distribution
  double _villagerCount = 3.0;
  double _werewolfCount = 1.0;
  bool _includeSeer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _gameNameController,
                decoration: const InputDecoration(
                  labelText: 'Game Name',
                  prefixIcon: Icon(Icons.gamepad),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a game name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Role Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildRoleSlider(
                label: 'Villagers',
                value: _villagerCount,
                onChanged: (value) {
                  setState(() {
                    _villagerCount = value;
                  });
                },
                min: 3.0,
                max: 10.0,
              ),
              _buildRoleSlider(
                label: 'Werewolves',
                value: _werewolfCount,
                onChanged: (value) {
                  setState(() {
                    _werewolfCount = value;
                  });
                },
                min: 1.0,
                max: 3.0,
              ),
              SwitchListTile(
                title: const Text('Include Seer'),
                value: _includeSeer,
                onChanged: (bool value) {
                  setState(() {
                    _includeSeer = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _createGame,
                child: const Text('Create Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSlider({
    required String label,
    required double value,
    required void Function(double) onChanged,
    required double min,
    required double max,
  }) {
    return Column(
      children: [
        Text('$label: ${value.round()}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _createGame() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Prepare custom rules
        final customRules = {
          'villagerCount': _villagerCount.round(),
          'werewolfCount': _werewolfCount.round(),
          'includeSeer': _includeSeer,
        };

        // Get current user ID from getCurrentUser
        final userData = await context.read<AuthService>().getCurrentUser();
        final userId = userData['user']['id'].toString();

        // Use the CreateGameState to create the game
        await context.read<CreateGameState>().createGame(
          name: _gameNameController.text,
          userId: userId,
          settings: customRules,
        );

        // Navigate back or to game lobby
        Navigator.of(context).pop();
      } catch (e) {
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create game: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }
}
