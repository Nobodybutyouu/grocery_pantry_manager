// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/hive_registry.dart';
import 'shared/theme.dart';
import 'features/pantry_items/presentation/screens/pantry_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and register adapters
  await registerHiveAdapters();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Grocery & Pantry Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PantryListScreen(),
    );
  }
}