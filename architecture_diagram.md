# Application Architecture - MVVM Pattern

```
┌────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                      │
│  ┌─────────────────┐        ┌──────────────┐    ┌──────────┐   │
│  │      Pages      │        │   Widgets    │    │  Theme   │   │
│  │                 │        │              │    │          │   │
│  │ - game_page     │        │ - chat_widget│    │- colors  │   │
│  │ - settings_page │        │ - game_card  │    │- styles  │   │
│  │ - login_page    │        │ - player_list│    │          │   │
│  └────────┬────────┘        └───────┬──────┘    └──────────┘   │
│           │                         │                          │
│           │         Observes        │                          │
│           ▼                         ▼                          │
│  ┌─────────────────────────────────────────────┐               │
│  │              ViewModels (Providers)         │               │
│  │                                             │               │
│  │  - game_provider                            │               │
│  │  - auth_state_provider                      │               │
│  │  - game_management_provider                 │               │
│  │  - chat_provider                            │               │
│  └───────────────────┬─────────────────────────┘               │
└──────────────────────│─────────────────────────────────────────┘
                       │
                       │ Uses
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Core/Services Layer                        │
│                                                                 │
│  ┌─────────────────┐    ┌───────────────┐    ┌──────────────┐   │
│  │   WebSocket     │    │     Auth      │    │     Chat     │   │
│  │    Service      │    │    Service    │    │    Service   │   │
│  └─────────────────┘    └───────────────┘    └──────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Data Flow:
1. UI (Pages/Widgets) observes ViewModels (Providers)
2. User interactions trigger ViewModel methods
3. ViewModels communicate with Services
4. Services handle business logic and data operations
5. Updates flow back through ViewModels to UI

Key Components:

1. View Layer (Presentation)
   - Pages: Main UI containers
   - Widgets: Reusable UI components
   - Theme: Visual styling

2. ViewModel Layer (Providers)
   - Manages UI state
   - Handles UI logic
   - Communicates with Services
   - Provides data to Views

3. Service Layer (Core)
   - Implements business logic
   - Handles data operations
   - Manages external communications
   - Provides core functionality

This architecture follows MVVM pattern where:
- Model: Services in core/services/
- View: UI components in presentation/pages/ and presentation/widgets/
- ViewModel: Providers that manage state and business logic
