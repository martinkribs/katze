import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katze/presentation/bloc/game/game_bloc.dart';
import 'package:katze/presentation/bloc/theme/theme_bloc.dart';

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
              context.read<ThemeBloc>().add(ToggleThemeEvent());
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

  void _createGame() {
    if (_formKey.currentState!.validate()) {
      // Prepare custom rules
      final customRules = {
        'villagerCount': _villagerCount.round(),
        'werewolfCount': _werewolfCount.round(),
        'includeSeer': _includeSeer,
      };

      // Dispatch game creation event
      context.read<GameBloc>().add(
        CreateGameEvent(
          gameName: _gameNameController.text,
          userId: 'current_user_id', // TODO: Replace with actual user ID
        ),
      );

      // Navigate back or to game lobby
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }
}
