
# Grocery & Pantry Manager 

An offline-first Flutter mobile application for managing grocery items and pantry inventory.

## Features Implemented (So Far)

### Feature 1: Add & Manage Items (COMPLETE)

* Add new pantry items with name, quantity, category, and expiration date
* Edit existing items
* Delete items with confirmation
* View all pantry items in a list
* Real-time search functionality
* Filter by category
* Visual indicators for expiring/expired items

### Remaining Features (To Be Implemented)

* Feature 2: Low Stock & Expiration Alerts
* Feature 3: Grocery List Generator
* Feature 4: Search & Filter Items (partially done - integrated into Feature 1)
* Feature 5: Offline Data Storage (already working via Hive)

## Getting Started

### Prerequisites

* Flutter SDK (3.0 or higher)
* Dart SDK
* Android Studio / VS Code with Flutter extensions

### Installation Steps

1. **Clone the repository** (or create the project):

```bash
flutter create grocery_pantry_manager
cd grocery_pantry_manager
```

2. **Install dependencies** :

```bash
flutter pub add hive hive_flutter dartz google_fonts flutter_form_builder form_builder_validators flutter_riverpod intl

flutter pub add --dev hive_generator build_runner
```

3. **Create the folder structure** :

```
lib/
├── core/
│   ├── errors/
│   │   └── failures.dart
│   └── database/
│       └── hive_registry.dart
├── features/
│   └── pantry_items/
│       ├── data/
│       │   ├── models/
│       │   │   └── pantry_item_model.dart
│       │   ├── datasources/
│       │   │   ├── pantry_item_local_datasource.dart
│       │   │   └── pantry_item_local_datasource_impl.dart
│       │   └── repositories/
│       │       └── pantry_item_repository_impl.dart
│       ├── domain/
│       │   └── repositories/
│       │       └── pantry_item_repository.dart
│       └── presentation/
│           ├── providers/
│           │   └── pantry_item_provider.dart
│           ├── state/
│           │   └── pantry_item_state.dart
│           ├── controllers/
│           │   └── pantry_item_controller.dart
│           └── screens/
│               ├── pantry_list_screen.dart
│               └── add_edit_item_screen.dart
├── shared/
│   └── theme.dart
└── main.dart
```

4. **Copy all the code files** I provided above into their respective locations.
5. **Generate Hive adapters** :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create `pantry_item_model.g.dart` in the models folder.

6. **Run the app** :

```bash
flutter run
```

## Project Structure Explained

### Core Layer

* **failures.dart** : Defines error types (DatabaseFailure, NotFoundFailure, etc.)
* **hive_registry.dart** : Centralized Hive adapter registration

### Data Layer (Feature 1)

* **Models** : Data structures that extend HiveObject for persistence
* **DataSources** : Interface and implementation for Hive database operations
* **Repositories (Implementation)** : Handles error cases and returns Either<Failure, Data>

### Domain Layer

* **Repositories (Interface)** : Abstract contracts for data operations

### Presentation Layer

* **State** : Different states (Loading, Loaded, Error, Success)
* **Controllers** : Business logic using StateNotifier
* **Providers** : Dependency injection using Riverpod
* **Screens** : UI components

## Design Patterns Used

1. **Clean Architecture** : Separation of concerns (Data, Domain, Presentation)
2. **Repository Pattern** : Abstract data access
3. **Provider Pattern** : State management with Riverpod
4. **Either Pattern** : Functional error handling with dartz

## Testing the App

### Test Cases for Feature 1:

1. **Add Item** :

* Tap the + button
* Fill in all fields
* Verify item appears in list

1. **Edit Item** :

* Tap the three-dot menu on any item
* Select "Edit"
* Modify fields
* Verify changes are saved

1. **Delete Item** :

* Tap the three-dot menu
* Select "Delete"
* Confirm deletion
* Verify item is removed

1. **Search** :

* Type in search bar
* Verify filtered results

1. **Filter by Category** :

* Tap a category chip
* Verify only items from that category show

1. **Expiration Warnings** :

* Add items with expiration dates within 7 days
* Verify orange indicator appears
* Add expired items
* Verify red indicator appears

## Next Steps

### For Your Team Members:

**Member 2** should implement:

* Feature 2: Low Stock & Expiration Alerts
* Create similar data layer structure
* Add AlertModel, AlertRepository, etc.

**Member 3** should implement:

* Feature 3: Grocery List Generator
* Can read from PantryItems to generate lists

**Member 4** can:

* Enhance Feature 4: Search & Filter (add more advanced filters)
* Or implement Feature 5: Settings & Data Management

### Creating a Bottom Navigation Bar

After all features are complete, Member 1 should create a bottom navigation that includes:

1. Pantry (Current Feature 1)
2. Alerts (Feature 2)
3. Grocery List (Feature 3)
4. Search (Feature 4)
5. More (Settings)

## Common Issues & Solutions

### Issue: Red errors after creating files

 **Solution** :

```bash
flutter pub get
flutter clean
flutter pub get
```

### Issue: Hive adapter not found

 **Solution** : Make sure you ran:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Import errors

 **Solution** : Check that all file paths in import statements match your folder structure exactly.

### Issue: State not updating

 **Solution** : Make sure you're using `ref.read()` for actions and `ref.watch()` for state observation.

## Video Demo Checklist

When recording your video, demonstrate:

* Adding a new item with all fields
* Editing an existing item
* Deleting an item
* Searching for items
* Filtering by category
* Items with expiration warnings
* Empty state (when no items exist)
* App works offline (turn off internet)

## Resources

* [Flutter Documentation](https://docs.flutter.dev/)
* [Riverpod Documentation](https://riverpod.dev/)
* [Hive Documentation](https://docs.hivedb.dev/)
* [Dartz Package](https://pub.dev/packages/dartz)

## Team Members

1. Jerel Jean A. Arojado - Feature 1: Add & Manage Items
2. Bea Jane S. Espinosa - Feature 2: Alerts
3. John Lester E. Bohol - Feature 3: Grocery List
4. Mark Lourince Margallo - Feature 4: Advanced Search/Settings

---

 **Status** : Feature 1 Complete | Ready for team collaboration
