import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/core/services/game_service.dart';
import 'package:katze/presentation/pages/create_game_page.dart';
import 'package:katze/presentation/pages/game_page.dart';
import 'package:katze/presentation/providers/theme_provider.dart';

enum GameStatus {
  all,
  pending,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case GameStatus.all:
        return 'All';
      case GameStatus.pending:
        return 'Pending';
      case GameStatus.inProgress:
        return 'In Progress';
      case GameStatus.completed:
        return 'Completed';
    }
  }
}

class GamesOverviewState extends ChangeNotifier {
  final GameService _gameService;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _allGames = [];
  Set<GameStatus> _selectedFilters = {GameStatus.all};

  GamesOverviewState(this._gameService) {
    loadGames();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<GameStatus> get selectedFilters => _selectedFilters;
  
  // Filtered games getter
  List<Map<String, dynamic>> get games {
    if (_selectedFilters.contains(GameStatus.all)) {
      return _allGames;
    }
    
    return _allGames.where((game) {
      final status = game['status']?.toLowerCase();
      return _selectedFilters.any((filter) {
        switch (filter) {
          case GameStatus.pending:
            return status == 'pending';
          case GameStatus.inProgress:
            return status == 'in_progress';
          case GameStatus.completed:
            return status == 'completed';
          case GameStatus.all:
            return true;
        }
      });
    }).toList();
  }

  void toggleFilter(GameStatus status) {
    if (status == GameStatus.all) {
      _selectedFilters = {GameStatus.all};
    } else {
      _selectedFilters.remove(GameStatus.all);
      if (_selectedFilters.contains(status)) {
        _selectedFilters.remove(status);
        if (_selectedFilters.isEmpty) {
          _selectedFilters = {GameStatus.all};
        }
      } else {
        _selectedFilters.add(status);
      }
    }
    notifyListeners();
  }

  Future<void> loadGames() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final games = await _gameService.getGames();
      _allGames = games;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Widget buildGameStatusChip(String? status, {bool small = false}) {
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
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 12 : 14,
        ),
      ),
      backgroundColor: chipColor,
      padding: small ? const EdgeInsets.all(4) : null,
    );
  }
}

class GamesOverviewPage extends StatelessWidget {
  const GamesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GamesOverviewState(context.read<GameService>()),
      child: const _GamesOverviewView(),
    );
  }
}

class _GamesOverviewView extends StatelessWidget {
  const _GamesOverviewView();

  @override
  Widget build(BuildContext context) {
    final gamesState = context.watch<GamesOverviewState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => gamesState.loadGames(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _FilterChips(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => gamesState.loadGames(),
        child: gamesState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : gamesState.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gamesState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => gamesState.loadGames(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : gamesState.games.isEmpty
                    ? const _EmptyGamesView()
                    : _GamesList(games: gamesState.games),
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
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gamesState = context.watch<GamesOverviewState>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: GameStatus.values.map((status) {
          final isSelected = gamesState.selectedFilters.contains(status);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status.displayName),
              selected: isSelected,
              onSelected: (_) => gamesState.toggleFilter(status),
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyGamesView extends StatelessWidget {
  const _EmptyGamesView();

  @override
  Widget build(BuildContext context) {
    final gamesState = context.watch<GamesOverviewState>();
    bool hasFilters = !gamesState.selectedFilters.contains(GameStatus.all);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasFilters 
                ? 'No games match the selected filters'
                : 'No games yet',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          if (hasFilters)
            ElevatedButton(
              onPressed: () => gamesState.toggleFilter(GameStatus.all),
              child: const Text('Show all games'),
            )
          else
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
    );
  }
}

class _GamesList extends StatelessWidget {
  final List<Map<String, dynamic>> games;

  const _GamesList({required this.games});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
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
            trailing: context.read<GamesOverviewState>().buildGameStatusChip(game['status']),
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
    );
  }
}