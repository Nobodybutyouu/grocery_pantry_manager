
# Grocery & Pantry Manager

Offline-first Flutter app for tracking pantry inventory and expiring groceries.

## Highlights
- Add, edit, delete, and search pantry items with category filters.
- Visual cues for items nearing or past expiration.
- Hive-backed local storage keeps data available offline.

Planned next: low-stock alerts, grocery list generator, and expanded filters.

## Tech Stack
- Flutter 3+
- Riverpod for state management
- Hive for persistence
- Dartz for functional error handling

## Quick Start
1. Install Flutter/Dart tooling and clone the repo.
2. Fetch packages:
   ```bash
   flutter pub get
   ```
3. Generate Hive adapters when models change:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Architecture at a Glance
- **Core**: shared errors and Hive registration.
- **Features/pantry_items**:
  - _data_: Hive models, datasources, repositories.
  - _domain_: repository contracts.
  - _presentation_: Riverpod providers, controllers, screens.
- **Shared**: theme and cross-cutting UI assets.

## Troubleshooting
- Missing Hive adapters ➜ rerun `build_runner`.
- Red analyzer errors after dependency changes ➜ `flutter clean` then `flutter pub get`.

---
Maintained by the Grocery & Pantry Manager team. Feature 1 shipped; collaborations welcome.
