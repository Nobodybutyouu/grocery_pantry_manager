// lib/features/alerts/presentation/screens/alerts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/alert_provider.dart';
import '../state/alert_state.dart';
import '../../data/models/alert_item_model.dart';
import 'alert_settings_screen.dart';
import 'restock_dialog.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(alertControllerProvider.notifier).loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertControllerProvider);
    final controller = ref.read(alertControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlertSettingsScreen(),
                ),
              );
            },
            tooltip: 'Alert Settings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadAlerts(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          if (state is AlertLoaded) _buildStatisticsCards(state),

          // Filter Chips
          if (state is AlertLoaded) _buildFilterChips(state, controller),

          // Alerts List
          Expanded(
            child: _buildBody(state, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(AlertLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Low Stock',
              state.lowStockCount.toString(),
              Colors.orange,
              Icons.inventory_2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Expiring',
              state.expiringCount.toString(),
              Colors.amber,
              Icons.access_time,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Expired',
              state.expiredCount.toString(),
              Colors.red,
              Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(AlertLoaded state, controller) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedFilter == null,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = null;
              });
              controller.loadAlerts();
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text('Low Stock (${state.lowStockCount})'),
            selected: _selectedFilter == AlertType.lowStock,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? AlertType.lowStock : null;
              });
              controller.filterByType(selected ? AlertType.lowStock : null);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text('Expiring (${state.expiringCount})'),
            selected: _selectedFilter == AlertType.expiringSoon,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? AlertType.expiringSoon : null;
              });
              controller.filterByType(selected ? AlertType.expiringSoon : null);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text('Expired (${state.expiredCount})'),
            selected: _selectedFilter == AlertType.expired,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? AlertType.expired : null;
              });
              controller.filterByType(selected ? AlertType.expired : null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AlertState state, controller) {
    if (state is AlertInitial || state is AlertLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AlertError) {
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
              onPressed: () => controller.loadAlerts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is AlertLoaded) {
      if (state.alerts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFilter != null
                    ? 'No alerts for this filter'
                    : 'No alerts at the moment',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'All items are well stocked!',
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
        itemCount: state.alerts.length,
        itemBuilder: (context, index) {
          final alert = state.alerts[index];
          return _buildAlertCard(alert, controller);
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildAlertCard(AlertItemModel alert, controller) {
    Color cardColor;
    Color iconColor;
    IconData icon;

    switch (alert.alertType) {
      case AlertType.lowStock:
        cardColor = Colors.orange.shade50;
        iconColor = Colors.orange;
        icon = Icons.inventory_2;
        break;
      case AlertType.expiringSoon:
        cardColor = Colors.amber.shade50;
        iconColor = Colors.amber.shade700;
        icon = Icons.access_time;
        break;
      case AlertType.expired:
        cardColor = Colors.red.shade50;
        iconColor = Colors.red;
        icon = Icons.warning;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          alert.item.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text('Category: ${alert.item.category}'),
            if (alert.alertType == AlertType.lowStock)
              Text('Current quantity: ${alert.item.quantity}'),
            if (alert.item.expirationDate != null)
              Text(
                  'Exp. date: ${DateFormat('MMM dd, yyyy').format(alert.item.expirationDate!)}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (alert.alertType == AlertType.lowStock)
              const PopupMenuItem(
                value: 'restock',
                child: Row(
                  children: [
                    Icon(Icons.add_shopping_cart),
                    SizedBox(width: 8),
                    Text('Restock'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'used',
              child: Row(
                children: [
                  Icon(Icons.done),
                  SizedBox(width: 8),
                  Text('Mark as Used'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'restock') {
              _showRestockDialog(context, alert, controller);
            } else if (value == 'used') {
              _showMarkAsUsedDialog(context, alert, controller);
            }
          },
        ),
      ),
    );
  }

  void _showRestockDialog(BuildContext context, AlertItemModel alert, controller) {
    showDialog(
      context: context,
      builder: (context) => RestockDialog(
        item: alert.item,
        onRestock: (newQuantity) {
          controller.markAsRestocked(alert.item.id, newQuantity);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMarkAsUsedDialog(
      BuildContext context, AlertItemModel alert, controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Used'),
        content: Text(
            'Are you sure you want to remove "${alert.item.name}" from your pantry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.markAsUsed(alert.item.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}