// lib/features/pantry_items/presentation/state/pantry_item_state.dart

import '../../data/models/pantry_item_model.dart';

abstract class PantryItemState {
  const PantryItemState();
}

class PantryItemInitial extends PantryItemState {
  const PantryItemInitial();
}

class PantryItemLoading extends PantryItemState {
  const PantryItemLoading();
}

class PantryItemLoaded extends PantryItemState {
  final List<PantryItemModel> items;
  final List<String> categories;

  const PantryItemLoaded({
    required this.items,
    required this.categories,
  });
}

class PantryItemError extends PantryItemState {
  final String message;

  const PantryItemError(this.message);
}

class PantryItemSuccess extends PantryItemState {
  final String message;

  const PantryItemSuccess(this.message);
}