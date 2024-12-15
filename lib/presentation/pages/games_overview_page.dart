import 'package:flutter/material.dart';
import 'package:katze/core/enums/game_status.dart';
import 'package:katze/presentation/pages/create_game_page.dart';
import 'package:katze/presentation/pages/game_page.dart';
import 'package:katze/presentation/pages/settings_page.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_management_provider.dart';
import 'package:katze/presentation/widgets/game_card.dart';
import 'package:katze/presentation/widgets/game_filter_chips.dart';
import 'package:katze/presentation/widgets/loading_button.dart';
import 'package:katze/presentation/widgets/pagination_controls.dart';
import 'package:provider/provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameManagementProvider>().loadGames();
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

  List<Map<String, dynamic>> _getFilteredGames(List<Map<String, dynamic>> games) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoadingProvider, GameManagementProvider>(
      builder: (context, loadingProvider, gameManagementProvider, _) {
        final filteredGames = _getFilteredGames(gameManagementProvider.games);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Games'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => gameManagementProvider.loadGames(),
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
              child: GameFilterChips(
                selectedFilters: _selectedFilters,
                onFilterToggled: _toggleFilter,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => gameManagementProvider.loadGames(),
            child: loadingProvider.isLoading
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
                            LoadingButton(
                              isLoading: false,
                              onPressed: () => gameManagementProvider.loadGames(),
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
                                LoadingButton(
                                  isLoading: false,
                                  onPressed: !_selectedFilters.contains(GameStatus.all)
                                      ? () => _toggleFilter(GameStatus.all)
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const CreateGamePage(),
                                            ),
                                          );
                                        },
                                  child: Text(
                                    !_selectedFilters.contains(GameStatus.all)
                                        ? 'Show all games'
                                        : 'Create Game',
                                  ),
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
                                    return GameCard(
                                      game: game,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => GamePage(
                                              gameId: game['id'],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              if (filteredGames.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: PaginationControls(
                                    currentPage: gameManagementProvider.currentPage,
                                    totalPages: gameManagementProvider.lastPage,
                                    onPageChanged: (page) => gameManagementProvider.loadGames(page: page),
                                  ),
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
