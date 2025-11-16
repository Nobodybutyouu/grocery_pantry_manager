// lib/features/grocery_list/presentation/screens/grocery_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/grocery_item_model.dart';
import '../providers/grocery_list_provider.dart';
import '../state/grocery_list_state.dart';
import 'add_grocery_item_screen.dart';

class GroceryListScreen extends ConsumerStatefulWidget {
  const GroceryListScreen({super.key});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(groceryListControllerProvider.notifier).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groceryListControllerProvider);
    final controller = ref.read(groceryListControllerProvider.notifier);

    // Listen for success/error messages
    ref.listen<GroceryListState>(groceryListControllerProvider, (previous, next) {
      if (next is GroceryListSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox(width: 8),
                    Text('Generate from Pantry'),
                  ],
                ),
              ),
              if (state is GroceryListLoaded && state.checkedCount > 0)
                const PopupMenuItem(
                  value: 'clear_checked',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle),
                      SizedBox(width: 8),
                      Text('Clear Checked Items'),
                    ],
                  ),
                ),
              if (state is GroceryListLoaded && state.items.isNotEmpty)
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All Items', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
            onSelected: (value) {
              if (value == 'generate') {
                _showGenerateDialog(context, controller);
              } else if (value == 'clear_checked') {
                _showClearCheckedDialog(context, controller);
              } else if (value == 'clear_all') {
                _showClearAllDialog(context, controller);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Card
          if (state is GroceryListLoaded && state.items.isNotEmpty)
            _buildProgressCard(state),

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
              builder: (context) => const AddGroceryItemScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressCard(GroceryListLoaded state) {
    final progress = state.progress;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shopping Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$progressPercent%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.checkedCount} of ${state.totalCount} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${state.uncheckedCount} remaining',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(GroceryListState state, controller) {
    if (state is GroceryListInitial || state is GroceryListLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GroceryListError) {
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

    if (state is GroceryListLoaded || state is GroceryListSuccess) {
      final List<GroceryItemModel> itemsList = state is GroceryListLoaded
          ? state.items
          : (state as GroceryListSuccess).items;

      if (itemsList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No items in grocery list',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add items manually or generate from pantry',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showGenerateDialog(context, controller),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate from Pantry'),
              ),
            ],
          ),
        );
      }

      // Separate checked and unchecked items
      final uncheckedItems = itemsList.where((item) => !item.isChecked).toList();
      final checkedItems = itemsList.where((item) => item.isChecked).toList();

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Unchecked Items
          if (uncheckedItems.isNotEmpty) ...[
            Text(
              'To Buy (${uncheckedItems.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            ...uncheckedItems.map((item) => _buildGroceryCard(item, controller, false)),
            const SizedBox(height: 16),
          ],

          // Checked Items
          if (checkedItems.isNotEmpty) ...[
            Text(
              'Purchased (${checkedItems.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            ...checkedItems.map((item) => _buildGroceryCard(item, controller, true)),
          ],
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildGroceryCard(
    GroceryItemModel item,
    GroceryListController controller,
    bool isChecked,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isChecked ? Colors.grey.shade100 : null,
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (_) => controller.toggleChecked(item.id),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: isChecked ? TextDecoration.lineThrough : null,
            color: isChecked ? Colors.grey.shade600 : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Quantity: ${item.quantity}'),
            Text('Category: ${item.category}'),
            if (item.isAutoGenerated)
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: Colors.blue.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Auto-generated',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        secondary: PopupMenuButton(
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
                  builder: (context) => AddGroceryItemScreen(item: item),
                ),
              );
            } else if (value == 'delete') {
              _showDeleteDialog(context, item.id, item.name, controller);
            }
          },
        ),
      ),
    );
  }

  void _showGenerateDialog(BuildContext context, controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Grocery List'),
        content: const Text(
          'This will automatically add low stock items from your pantry to the grocery list. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.generateFromPantry();
              Navigator.pop(context);
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showClearCheckedDialog(BuildContext context, controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Checked Items'),
        content: const Text('Remove all checked items from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearCheckedItems();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Items'),
        content: const Text('Remove all items from the grocery list? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearAllItems();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String name, controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Remove "$name" from grocery list?'),
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