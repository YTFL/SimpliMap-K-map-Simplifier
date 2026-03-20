# SimpliMap

SimpliMap is a Flutter app for creating, visualizing and minimizing Boolean expressions using Karnaugh maps (K-maps). It provides a solver UI, step-by-step minimization, and components to explore K-map grouping and simplified expressions.

## Features
- Create and edit minterms and K-maps.
- Automatic Boolean expression minimization.
- Step-by-step breakdown of minimization and groupings.
- Export or view minimized equation results.

## Quick start
Prerequisites
- Flutter SDK (stable) installed: https://flutter.dev/docs/get-started/install
- For Android builds: Android SDK + an emulator or device.
- For web builds: a modern browser.

Run locally
1. Get dependencies:

```bash
flutter pub get
```

2. Run on an available device (Android, iOS, web, desktop):

```bash
flutter run
```

3. Build release APK (Android):

```bash
flutter build apk --release
```

Build for web:

```bash
flutter build web
```

## Project structure (key files)
- [lib/main.dart](lib/main.dart) — app entry point
- [lib/screens/solver_screen.dart](lib/screens/solver_screen.dart) — main solver UI
- [lib/logic/minimizer.dart](lib/logic/minimizer.dart) — K-map minimization logic
- [lib/logic/boolean_parser.dart](lib/logic/boolean_parser.dart) — boolean parsing utilities
- [lib/widgets/kmap_grid.dart](lib/widgets/kmap_grid.dart) — interactive K-map grid widget
- [lib/state/kmap_provider.dart](lib/state/kmap_provider.dart) — app state provider

Explore the `lib/` folder for UI widgets and models: `models/`, `widgets/`, `logic/`, and `screens/`.

## Development notes
- Follow Flutter best practices: use `flutter analyze` and `flutter format` regularly.
- To run the analyzer:

```bash
flutter analyze
```

- To format code:

```bash
flutter format .
```

## Tests
This repository does not appear to include automated tests. Consider adding unit tests for `minimizer.dart` and widget tests for the main UI screens.

## Contributing
Contributions are welcome. Suggested workflow:
1. Create a feature branch.
2. Run `flutter analyze` and `flutter format`.
3. Open a pull request with a clear description of changes.

Please add a license file to clarify reuse terms if you plan to accept outside contributions.

## License
This project will be licensed under the MIT License. The `LICENSE` file will be added using GitHub's MIT license template — the full license text is not included here.

## Contact
For questions or collaboration, open an issue in this repository or add a PR with suggested changes.
YTFL — https://github.com/YTFL
