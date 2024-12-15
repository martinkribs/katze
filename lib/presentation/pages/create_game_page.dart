import 'package:flutter/material.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_management_provider.dart';
import 'package:katze/presentation/providers/theme_provider.dart';
import 'package:katze/presentation/widgets/timezone_dropdown.dart';
import 'package:provider/provider.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  _CreateGamePageState createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final _gameNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedTimezone;
  final bool _isPrivate = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoadingProvider, GameManagementProvider>(
      builder: (context, loadingProvider, gameManagementProvider, _) {
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
                  if (loadingProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        loadingProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value != null && value.length > 255) {
                        return 'Description cannot be longer than 255 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TimezoneDropdown(
                    value: _selectedTimezone,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTimezone = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a timezone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: loadingProvider.isLoading ? null : _createGame,
                    child: loadingProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Game'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _createGame() async {
    if (_formKey.currentState!.validate()) {
      try {
        final gameManagementProvider = context.read<GameManagementProvider>();
        await gameManagementProvider.createGame(
          name: _gameNameController.text,
          description: _descriptionController.text,
          isPrivate: _isPrivate,
          timezone: _selectedTimezone!,
        );

        if (mounted && gameManagementProvider.currentGame != null) {
          final gameId = gameManagementProvider.currentGame!['gameId'];
          if (gameId != null) {
            // Load full game details before navigating
            await gameManagementProvider.loadGameDetails(gameId.toString());
            
            // Refresh games list
            await gameManagementProvider.loadGames();
            
            // Navigate to the game page
            Navigator.pushReplacementNamed(
              context,
              '/game',
              arguments: gameId,
            );
          } else {
            throw Exception('Game ID not found in response');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create game: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
