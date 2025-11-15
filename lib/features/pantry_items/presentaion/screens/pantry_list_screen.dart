import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pantry_item_provider.dart';
import '../state/pantry_item_state.dart';
import 'add_edit_item_screen.dart';
import 'package:intl/intl.dart';

class PantryListScreen extends ConsumerStatefulWidget {
  const PantryListScreen({super.key});

  @override
  ConsumerState<PantryListScreen> createState() => _PantryListScreenState();
}

class _PantryListScreenState extends ConsumerState<PantryListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load items when screen initializes
    Future.microtask(() {
      ref.read(pantryItemControllerProvider.notifier).loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pantryItemControllerProvider);
    final controller = ref.read(pantryItemControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        actions: [
          if (state is PantryItemLoaded && _selectedCategory != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                });
                controller.loadItems();
              },
              tooltip: 'Clear Filter',
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
                          controller.loadItems();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                if (value.isEmpty) {
                  controller.loadItems();
                } else {
                  controller.searchItems(value);
                }
              },
            ),
          ),

          // Category Filter Chips
          if (state is PantryItemLoaded && state.categories.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        if (selected) {
                          controller.filterByCategory(category);
                        } else {
                          controller.loadItems();
                        }
                      },
                    ),
                  );
                },
              ),
            ),

          // Items List
          Expanded(
            child: _buildBody(state, controller),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditItemScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
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
      if (state.items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No items found'
                    : 'No items in pantry',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try a different search'
                    : 'Tap + to add your first item',
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
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          final isExpiringSoon = item.expirationDate != null &&
              item.expirationDate!.difference(DateTime.now()).inDays <= 7;
          final isExpired = item.expirationDate != null &&
              item.expirationDate!.isBefore(DateTime.now());

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isExpired
                    ? Colors.red.shade100
                    : isExpiringSoon
                        ? Colors.orange.shade100
                        : Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.inventory_2,
                  color: isExpired
                      ? Colors.red
                      : isExpiringSoon
                          ? Colors.orange
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
                  Text('Quantity: ${item.quantity}'),
                  if (item.expirationDate != null)
                    Text(
                      'Expires: ${DateFormat('MMM dd, yyyy').format(item.expirationDate!)}',
                      style: TextStyle(
                        color: isExpired
                            ? Colors.red
                            : isExpiringSoon
                                ? Colors.orange
                                : null,
                        fontWeight: isExpired || isExpiringSoon
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditItemScreen(item: item),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, item.id, item.name, controller);
                  }
                },
              ),
            ),
          );
        },
      );
    }

    return const SizedBox();
  }

  void _showDeleteDialog(
      BuildContext context, String id, String name, controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteItem(id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}