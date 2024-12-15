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
