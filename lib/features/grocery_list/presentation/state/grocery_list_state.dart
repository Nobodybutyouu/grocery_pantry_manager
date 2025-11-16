// lib/features/grocery_list/presentation/state/grocery_list_state.dart

import '../../data/models/grocery_item_model.dart';

abstract class GroceryListState {
  const GroceryListState();
}

class GroceryListInitial extends GroceryListState {
  const GroceryListInitial();
}

class GroceryListLoading extends GroceryListState {
  const GroceryListLoading();
}

class GroceryListLoaded extends GroceryListState {
  final List<GroceryItemModel> items;
  final int checkedCount;
  final int uncheckedCount;

  const GroceryListLoaded({
    required this.items,
    required this.checkedCount,
    required this.uncheckedCount,
  });

  int get totalCount => items.length;
  double get progress => totalCount > 0 ? checkedCount / totalCount : 0;
}

class GroceryListError extends GroceryListState {
  final String message;

  const GroceryListError(this.message);
}

class GroceryListSuccess extends GroceryListLoaded {
  final String message;

  const GroceryListSuccess({
    required this.message,
    required List<GroceryItemModel> items,
    required int checkedCount,
    required int uncheckedCount,
  }) : super(
          items: items,
          checkedCount: checkedCount,
          uncheckedCount: uncheckedCount,
        );
}