# Health Heroes - Snake & Ladder (Flutter)

This directory contains a modular Flutter implementation.

## Structure
- `lib/main.dart` — App bootstrap with Provider
- `lib/services/game_service.dart` — Game logic & state
- `lib/widgets/home_shell.dart` — App shell & layout
- `lib/widgets/board_widget.dart` — Board, tokens & connections painter
- `lib/widgets/control_panel.dart` — Controls & progress dashboard

## How to run
1. `flutter pub get`
2. `flutter run`

## Next improvements
- Add sound effects & accessibility labels
- Extract theme/colors into a service
- Persist progress with local DB/shared_prefs
- Make board scalable for various screen ratios
