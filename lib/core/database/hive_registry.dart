import 'package:hive_flutter/hive_flutter.dart';
import '../../features/pantry_items/data/models/pantry_item_model.dart';

Future<void> registerHiveAdapters() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register all adapters here
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PantryItemModelAdapter());
  }

  // Open boxes
  await Hive.openBox<PantryItemModel>('pantry_items');
}