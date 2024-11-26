import 'package:flutter/material.dart';
import 'package:katze/presentation/pages/create_game_page.dart';
import 'package:katze/presentation/pages/game_page.dart';
import 'package:katze/presentation/pages/settings_page.dart';
import 'package:katze/presentation/providers/game_provider.dart';
import 'package:provider/provider.dart';

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

class GamesOverviewPage extends StatefulWidget {
  const GamesOverviewPage({super.key});

  @override
  State<GamesOverviewPage> createState() => _GamesOverviewPageState();
}

class _GamesOverviewPageState extends State<GamesOverviewPage> {
  Set<GameStatus> _selectedFilters = {GameStatus.all};

  @override
  void initState() {
    super.initState();
    // Load games when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadGames();
    });
  }

  void _toggleFilter(GameStatus status) {
    setState(() {
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
    });
  }

  List<Map<String, dynamic>> _getFilteredGames(
      List<Map<String, dynamic>> games) {
    if (_selectedFilters.contains(GameStatus.all)) {
      return games;
    }

    return games.where((game) {
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

  Widget _buildGameStatusDot(String? status) {
    Color dotColor;
    String tooltip;

    switch (status?.toLowerCase()) {
      case 'pending':
        dotColor = Colors.orange;
        tooltip = 'Pending';
        break;
      case 'in_progress':
        dotColor = Colors.green;
        tooltip = 'In Progress';
        break;
      case 'completed':
        dotColor = Colors.blue;
        tooltip = 'Completed';
        break;
      default:
        dotColor = Colors.grey;
        tooltip = 'Unknown';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildPaginationControls(GameProvider gameProvider) {
    final totalPages = gameProvider.lastPage;
    final currentPage = gameProvider.currentPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed:
              currentPage > 1 ? () => gameProvider.loadGames(page: 1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () => gameProvider.loadGames(page: currentPage - 1)
              : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 50),
          child: Text(
            '$currentPage / $totalPages',
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () => gameProvider.loadGames(page: currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage < totalPages
              ? () => gameProvider.loadGames(page: totalPages)
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final filteredGames = _getFilteredGames(gameProvider.games);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Games'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => gameProvider.loadGames(),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: GameStatus.values.map((status) {
                    final isSelected = _selectedFilters.contains(status);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status.displayName),
                        selected: isSelected,
                        onSelected: (_) => _toggleFilter(status),
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        selectedColor:
                            Theme.of(context).primaryColor.withOpacity(0.8),
                        checkmarkColor:
                            Theme.of(context).textTheme.bodyLarge?.color,
                        labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => gameProvider.loadGames(),
            child: gameProvider.isLoading
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
                              onPressed: () => gameProvider.loadGames(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredGames.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  !_selectedFilters.contains(GameStatus.all)
                                      ? 'No games match the selected filters'
                                      : 'No games yet',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 16),
                                if (!_selectedFilters.contains(GameStatus.all))
                                  ElevatedButton(
                                    onPressed: () =>
                                        _toggleFilter(GameStatus.all),
                                    child: const Text('Show all games'),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateGamePage(),
                                        ),
                                      );
                                    },
                                    child: const Text('Create Game'),
                                  ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredGames.length,
                                  itemBuilder: (context, index) {
                                    final game = filteredGames[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      elevation: 4,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => GamePage(
                                                gameId: game['id'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      game['name'] ?? 'Unnamed Game',
                                                      style: Theme.of(context).textTheme.titleLarge,
                                                    ),
                                                  ),
                                                  _buildGameStatusDot(game['status']),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  const Icon(Icons.people, size: 20),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${game['playerCount'] ?? 0} Players',
                                                    style: Theme.of(context).textTheme.bodyLarge,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (filteredGames.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: _buildPaginationControls(gameProvider),
                                ),
                            ],
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
      },
    );
  }
}
