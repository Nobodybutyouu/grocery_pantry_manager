// lib/core/database/hive_registry.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/pantry_items/data/models/pantry_item_model.dart';
import '../../features/alerts/data/models/alert_settings_model.dart';

Future<void> registerHiveAdapters() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register all adapters here
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PantryItemModelAdapter());
  }
  
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(AlertSettingsModelAdapter());
  }

  // Open boxes
  await Hive.openBox<PantryItemModel>('pantry_items');
  await Hive.openBox<AlertSettingsModel>('alert_settings');
}