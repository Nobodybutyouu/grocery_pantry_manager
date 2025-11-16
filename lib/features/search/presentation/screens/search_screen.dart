// lib/features/search/presentation/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../pantry_items/presentation/providers/pantry_item_provider.dart';
import '../../../pantry_items/presentation/state/pantry_item_state.dart';
import '../../../pantry_items/data/models/pantry_item_model.dart';
import '../../../pantry_items/presentation/screens/add_edit_item_screen.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  quantityAsc,
  quantityDesc,
  categoryAsc,
  expirationAsc,
  recentlyAdded,
  recentlyUpdated,
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  SortOption _sortOption = SortOption.nameAsc;
  bool _showOnlyLowStock = false;
  bool _showOnlyExpiring = false;
  int _lowStockThreshold = 2;
  int _expiringDays = 7;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pantryItemControllerProvider.notifier).loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PantryItemModel> _filterAndSortItems(List<PantryItemModel> items) {
    var filteredItems = List<PantryItemModel>.from(items);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filteredItems = filteredItems
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    // Apply low stock filter
    if (_showOnlyLowStock) {
      filteredItems = filteredItems
          .where((item) => item.quantity <= _lowStockThreshold)
          .toList();
    }

    // Apply expiring filter
    if (_showOnlyExpiring) {
      final now = DateTime.now();
      filteredItems = filteredItems.where((item) {
        if (item.expirationDate == null) return false;
        final daysUntilExpiration =
            item.expirationDate!.difference(now).inDays;
        return daysUntilExpiration <= _expiringDays;
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.nameAsc:
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        filteredItems.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.quantityAsc:
        filteredItems.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case SortOption.quantityDesc:
        filteredItems.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case SortOption.categoryAsc:
        filteredItems.sort((a, b) => a.category.compareTo(b.category));
        break;
      case SortOption.expirationAsc:
        filteredItems.sort((a, b) {
          if (a.expirationDate == null && b.expirationDate == null) return 0;
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          return a.expirationDate!.compareTo(b.expirationDate!);
        });
        break;
      case SortOption.recentlyAdded:
        filteredItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.recentlyUpdated:
        filteredItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pantryItemControllerProvider);
    final controller = ref.read(pantryItemControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Advanced Filters',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortBottomSheet(context),
            tooltip: 'Sort Options',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active Filters Display
          if (_selectedCategory != null ||
              _showOnlyLowStock ||
              _showOnlyExpiring)
            _buildActiveFiltersChips(),

          // Results Count
          if (state is PantryItemLoaded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filterAndSortItems(state.items).length} items found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = null;
                        _showOnlyLowStock = false;
                        _showOnlyExpiring = false;
                        _sortOption = SortOption.nameAsc;
                      });
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // Items List
          Expanded(
            child: _buildBody(state, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(_selectedCategory!),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
            ),
          if (_showOnlyLowStock)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: const Text('Low Stock'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _showOnlyLowStock = false;
                  });
                },
              ),
            ),
          if (_showOnlyExpiring)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: const Text('Expiring Soon'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _showOnlyExpiring = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(PantryItemState state, controller) {
    if (state is PantryItemInitial || state is PantryItemLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PantryItemError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadItems(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is PantryItemLoaded) {
      final filteredItems = _filterAndSortItems(state.items);

      if (filteredItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No items found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return _buildItemCard(item, controller);
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildItemCard(PantryItemModel item, controller) {
    final isExpiringSoon = item.expirationDate != null &&
        item.expirationDate!.difference(DateTime.now()).inDays <= 7;
    final isExpired = item.expirationDate != null &&
        item.expirationDate!.isBefore(DateTime.now());
    final isLowStock = item.quantity <= _lowStockThreshold;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpired
              ? Colors.red.shade100
              : isExpiringSoon
                  ? Colors.orange.shade100
                  : isLowStock
                      ? Colors.amber.shade100
                      : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.inventory_2,
            color: isExpired
                ? Colors.red
                : isExpiringSoon
                    ? Colors.orange
                    : isLowStock
                        ? Colors.amber.shade700
                        : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          item.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Category: ${item.category}'),
            Row(
              children: [
                Text('Quantity: ${item.quantity}'),
                if (isLowStock) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Low Stock',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (item.expirationDate != null)
              Text(
                'Expires: ${DateFormat('MMM dd, yyyy').format(item.expirationDate!)}',
                style: TextStyle(
                  color: isExpired
                      ? Colors.red
                      : isExpiringSoon
                          ? Colors.orange
                          : null,
                  fontWeight:
                      isExpired || isExpiringSoon ? FontWeight.bold : null,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditItemScreen(item: item),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Options',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Category Filter
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'All',
                  'Dairy',
                  'Vegetables',
                  'Fruits',
                  'Meat',
                  'Grains',
                  'Snacks'
                ].map((category) {
                  final isSelected = category == 'All'
                      ? _selectedCategory == null
                      : _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        setState(() {
                          _selectedCategory =
                              category == 'All' ? null : category;
                        });
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Low Stock Filter
              SwitchListTile(
                title: const Text('Show only low stock items'),
                subtitle: Text('Quantity ≤ $_lowStockThreshold'),
                value: _showOnlyLowStock,
                onChanged: (value) {
                  setModalState(() {
                    setState(() {
                      _showOnlyLowStock = value;
                    });
                  });
                },
              ),

              // Expiring Filter
              SwitchListTile(
                title: const Text('Show only expiring items'),
                subtitle: Text('Expiring within $_expiringDays days'),
                value: _showOnlyExpiring,
                onChanged: (value) {
                  setModalState(() {
                    setState(() {
                      _showOnlyExpiring = value;
                    });
                  });
                },
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              title: const Text('Name (A-Z)'),
              leading: Radio<SortOption>(
                value: SortOption.nameAsc,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Name (Z-A)'),
              leading: Radio<SortOption>(
                value: SortOption.nameDesc,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Quantity (Low to High)'),
              leading: Radio<SortOption>(
                value: SortOption.quantityAsc,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Quantity (High to Low)'),
              leading: Radio<SortOption>(
                value: SortOption.quantityDesc,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Category'),
              leading: Radio<SortOption>(
                value: SortOption.categoryAsc,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Expiration Date'),
              leading: Radio<SortOption>(
                value: SortOption.expirationAsc,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Recently Added'),
              leading: Radio<SortOption>(
                value: SortOption.recentlyAdded,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Recently Updated'),
              leading: Radio<SortOption>(
                value: SortOption.recentlyUpdated,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}