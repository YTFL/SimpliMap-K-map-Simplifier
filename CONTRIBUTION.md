# Contributing to SimpliMap

Thanks for your interest in contributing! This document explains the preferred workflow and expectations to help your PR get merged quickly.
 
## Before you start
- Check existing issues to avoid duplicates.
- If you plan a large change, open an issue first to discuss the design.

## Development setup
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Get dependencies:

```bash
flutter pub get
```

3. Run the app locally:

```bash
flutter run
```

## Coding style and checks
- Follow Dart & Flutter style conventions. Run the analyzer before submitting changes:

```bash
flutter analyze
```

- Format code with:

```bash
flutter format .
```

- Keep changes focused and small. Write clear commit messages and PR descriptions.

## Tests
- Add unit tests for logic in `lib/logic/` where possible.
- Add widget tests for UI in `lib/widgets/` or `lib/screens/`.
- Run tests with:

```bash
flutter test
```

## Branching and PRs
- Create a branch named like `feature/short-description` or `fix/short-description`.
- Rebase or merge the target branch before opening a PR to keep history clean.
- Provide a clear PR description with motivation, what changed, and any migration steps.

## PR checklist
- [ ] Code builds and runs locally
- [ ] `flutter analyze` passes
- [ ] Code formatted (`flutter format .`)
- [ ] New behavior covered by tests (where applicable)
- [ ] No sensitive data or credentials

## Reporting bugs
- Open an issue with reproduction steps, environment (Flutter version, device), and logs if available.

## License and CLA
By contributing you agree that your contributions will be licensed under the project's MIT License.

---
YTFL — https://github.com/YTFL

---
Thanks — YTFL.