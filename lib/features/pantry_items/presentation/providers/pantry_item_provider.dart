import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/pantry_item_model.dart';
import '../state/pantry_item_state.dart';

final pantryItemControllerProvider =
    NotifierProvider<PantryItemController, PantryItemState>(
  PantryItemController.new,
);

class PantryItemController extends Notifier<PantryItemState> {
  static const _boxName = 'pantry_items';
  List<PantryItemModel> _allItems = [];

  @override
  PantryItemState build() {
    return const PantryItemInitial();
  }

  Future<Box<PantryItemModel>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<PantryItemModel>(_boxName);
    }
    return Hive.openBox<PantryItemModel>(_boxName);
  }

  List<String> _buildCategories() {
    final categories = _allItems
        .map((item) => item.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  Future<void> loadItems() async {
    state = const PantryItemLoading();
    try {
      final box = await _getBox();
      _allItems = box.values.cast<PantryItemModel>().toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      state = PantryItemLoaded(
        items: List.unmodifiable(_allItems),
        categories: _buildCategories(),
      );
    } catch (error, stackTrace) {
      _handleError('Failed to load pantry items', error, stackTrace);
    }
  }

  Future<void> searchItems(String query) async {
    if (_allItems.isEmpty) {
      await loadItems();
    }

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      state = PantryItemLoaded(
        items: List.unmodifiable(_allItems),
        categories: _buildCategories(),
      );
      return;
    }

    final filtered = _allItems.where((item) {
      return item.name.toLowerCase().contains(normalizedQuery) ||
          item.category.toLowerCase().contains(normalizedQuery);
    }).toList();

    state = PantryItemLoaded(
      items: filtered,
      categories: _buildCategories(),
    );
  }

  Future<void> filterByCategory(String category) async {
    if (_allItems.isEmpty) {
      await loadItems();
    }

    final filtered = _allItems
        .where((item) => item.category.toLowerCase() == category.toLowerCase())
        .toList();

    state = PantryItemLoaded(
      items: filtered,
      categories: _buildCategories(),
    );
  }

  Future<void> addItem(PantryItemModel item) async {
    try {
      final box = await _getBox();
      await box.put(item.id, item);
      await loadItems();
    } catch (error, stackTrace) {
      _handleError('Failed to add pantry item', error, stackTrace);
    }
  }

  Future<void> updateItem(PantryItemModel item) async {
    try {
      final box = await _getBox();
      await box.put(item.id, item);
      await loadItems();
    } catch (error, stackTrace) {
      _handleError('Failed to update pantry item', error, stackTrace);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      await loadItems();
    } catch (error, stackTrace) {
      _handleError('Failed to delete pantry item', error, stackTrace);
    }
  }

  void _handleError(String message, Object error, StackTrace stackTrace) {
    // Optionally log error/stackTrace somewhere useful.
    state = PantryItemError('$message: $error');
  }
}
