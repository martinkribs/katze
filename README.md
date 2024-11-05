++# Cat Game (Werewolf/Mafia Variant)

## Project Overview

Cat Game is a digital implementation of the classic Werewolf/Mafia social deduction game. The application is built using Flutter and follows clean architecture principles.

## Key Features

- User authentication
- Game creation and joining
- Role assignment
- Day/Night phase management
- Player actions and interactions

## Architecture

- Domain Layer: Entities, Repositories, Use Cases
- Presentation Layer: Blocs, Pages
- Dependency Injection: Managed via get_it

## Project Structure

```
lib/
├── core/
│   └── error/
├── di/
│   └── injection_container.dart
├── domain/
│   ├── entities/
│   │   ├── game_instance.dart
│   │   ├── player.dart
│   │   ├── role.dart
│   │   ├── action.dart
│   │   ├── round.dart
│   │   └── notification.dart
│   ├── repositories/
│   │   └── game_repository.dart
│   └── usecases/
│       ├── create_game.dart
│       └── join_game.dart
├── presentation/
│   ├── bloc/
│   │   ├── game/
│   │   └── notification/
│   └── pages/
│       └── home_page.dart
└── main.dart
```

## Game Mechanics

### Roles
- Villagers
- Werewolves
- Special roles (Seer, Doctor, etc.)

### Game Flow
1. Game Creation
2. Player Invitation
3. Role Assignment
4. Day/Night Phases
5. Voting and Actions
6. Game Resolution

## Technical Details

- State Management: Flutter Bloc
- Dependency Injection: get_it
- Architecture: Clean Architecture
- State Immutability: Equatable

## Planned Enhancements

- Real-time WebSocket integration
- Advanced role mechanics
- Persistent game state
- Comprehensive user authentication

## Development Setup

1. Ensure Flutter SDK is installed
2. Clone the repository
3. Run `flutter pub get`
4. Launch with `flutter run`

## Testing

Run tests with:
```
flutter test
```
