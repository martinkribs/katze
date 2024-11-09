import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katze/core/services/game_service.dart';
import 'package:katze/di/injection_container.dart';
import 'package:katze/presentation/bloc/theme/theme_bloc.dart';
import 'package:katze/presentation/pages/create_game_page.dart';
import 'package:katze/presentation/pages/game_page.dart';

class GamesOverviewPage extends StatefulWidget {
  const GamesOverviewPage({super.key});

  @override
  _GamesOverviewPageState createState() => _GamesOverviewPageState();
}

class _GamesOverviewPageState extends State<GamesOverviewPage> {
  final _gameService = sl<GameService>();
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _games = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final games = await _gameService.getGames();
      setState(() {
        _games = games;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGames,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGames,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGames,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _games.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No games yet',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CreateGamePage(),
                                  ),
                                );
                              },
                              child: const Text('Create Game'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _games.length,
                        itemBuilder: (context, index) {
                          final game = _games[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(game['name'] ?? 'Unnamed Game'),
                              subtitle: Text(
                                'Players: ${game['players']?.length ?? 0}',
                              ),
                              trailing: _buildGameStatusChip(game['status']),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => GamePage(
                                      gameId: game['id'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateGamePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGameStatusChip(String? status) {
    Color chipColor;
    String label;

    switch (status?.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        label = 'Pending';
        break;
      case 'in_progress':
        chipColor = Colors.green;
        label = 'In Progress';
        break;
      case 'completed':
        chipColor = Colors.blue;
        label = 'Completed';
        break;
      default:
        chipColor = Colors.grey;
        label = 'Unknown';
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }
}
