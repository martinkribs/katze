import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:katze/presentation/providers/game_provider.dart';
import 'package:katze/presentation/providers/theme_provider.dart';
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

  // Filtered list of time zones
  Future<List<DropdownMenuItem<String>>> _getFilteredTimeZones() async {
    final filteredTimezones = [
      'America/New_York',
      'Europe/Berlin',
      'Asia/Tokyo',
      'Australia/Sydney',
      'America/Los_Angeles',
      'Africa/Johannesburg'
    ];
    return filteredTimezones.map((String timezone) {
      return DropdownMenuItem<String>(
        value: timezone,
        child: Text(timezone),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

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
              if (gameProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    gameProvider.error!,
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
              FutureBuilder<List<DropdownMenuItem<String>>>(
                future: _getFilteredTimeZones(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error loading time zones');
                  } else {
                    return DropdownButtonFormField2<String>(
                      value: _selectedTimezone,
                      decoration: InputDecoration(
                        labelText: 'Timezone',
                        prefixIcon: const Icon(Icons.access_time),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: snapshot.data,
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
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 60,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: WidgetStateProperty.all(6),
                          thumbVisibility: WidgetStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 48,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: gameProvider.isLoading ? null : _createGame,
                child: gameProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createGame() async {
    if (_formKey.currentState!.validate()) {
      try {
        final gameProvider = context.read<GameProvider>();
        await gameProvider.createGame(
          name: _gameNameController.text,
          description: _descriptionController.text,
          isPrivate: _isPrivate,
          timezone: _selectedTimezone!,
        );

        if (mounted && gameProvider.currentGame != null) {
          final gameId = gameProvider.currentGame!['gameId'];
          if (gameId != null) {
            // Load full game details before navigating
            await gameProvider.loadGameDetails(gameId.toString());
            
            // Refresh games list
            await gameProvider.loadGames();
            
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
