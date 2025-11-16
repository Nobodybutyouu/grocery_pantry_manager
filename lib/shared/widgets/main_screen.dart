// lib/shared/widgets/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/pantry_items/presentation/screens/pantry_list_screen.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../features/grocery_list/presentation/screens/grocery_list_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/alerts/presentation/providers/alert_provider.dart';
import '../../features/alerts/presentation/state/alert_state.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PantryListScreen(),
    AlertsScreen(),
    GroceryListScreen(),
    SearchScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load alerts on startup to get badge count
    Future.microtask(() {
      ref.read(alertControllerProvider.notifier).loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertControllerProvider);
    int alertCount = 0;

    // Get alert count for badge
    if (alertState is AlertLoaded) {
      alertCount = alertState.alerts.length;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Shows all labels
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Pantry',
          ),
          BottomNavigationBarItem(
            icon: alertCount > 0
                ? Badge(
                    label: Text(alertCount.toString()),
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Grocery List',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}