import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../pantry_items/data/models/pantry_item_model.dart';
import '../../data/models/alert_item_model.dart';
import '../../data/models/alert_settings_model.dart';
import '../state/alert_state.dart';

final alertControllerProvider =
    NotifierProvider<AlertController, AlertState>(AlertController.new);

class AlertController extends Notifier<AlertState> {
  static const _settingsBoxName = 'alert_settings';
  AlertType? _activeFilter;
  List<AlertItemModel> _allAlerts = const [];
  AlertSettingsModel _settings = AlertSettingsModel.defaultSettings();

  @override
  AlertState build() {
    return const AlertInitial();
  }

  Future<void> loadAlerts() async {
    state = const AlertLoading();
    try {
      await _loadSettings();
      await _generateAlerts();
      _emitLoaded();
    } catch (error) {
      state = AlertError('Failed to load alerts: $error');
    }
  }

  Future<void> filterByType(AlertType? type) async {
    _activeFilter = type;
    if (_allAlerts.isEmpty) {
      await loadAlerts();
      return;
    }
    _emitLoaded();
  }

  Future<void> markAsRestocked(String itemId, int newQuantity) async {
    try {
      final pantryBox = await _openPantryBox();
      final item = pantryBox.get(itemId);
      if (item != null) {
        final updated = item.copyWith(
          quantity: newQuantity,
          updatedAt: DateTime.now(),
        );
        await pantryBox.put(itemId, updated);
      }
      await loadAlerts();
    } catch (error) {
      state = AlertError('Failed to restock item: $error');
    }
  }

  Future<void> markAsUsed(String itemId) async {
    try {
      final pantryBox = await _openPantryBox();
      await pantryBox.delete(itemId);
      await loadAlerts();
    } catch (error) {
      state = AlertError('Failed to mark item as used: $error');
    }
  }

  Future<void> updateSettings(AlertSettingsModel settings) async {
    try {
      final box = await _openSettingsBox();
      await box.put(settings.id, settings);
      _settings = settings;
      _emitLoaded();
    } catch (error) {
      state = AlertError('Failed to update alert settings: $error');
    }
  }

  Future<void> _generateAlerts() async {
    final pantryBox = await _openPantryBox();
    final items = pantryBox.values.toList();
    final now = DateTime.now();

    final alerts = <AlertItemModel>[];

    for (final item in items) {
      if (_settings.enableLowStockAlerts && item.quantity <= _settings.lowStockThreshold) {
        alerts.add(
          AlertItemModel(
            id: 'low-${item.id}',
            item: item,
            alertType: AlertType.lowStock,
            message: '${item.name} is running low (${item.quantity} left)',
            createdAt: now,
          ),
        );
      }

      if (_settings.enableExpirationAlerts && item.expirationDate != null) {
        final difference = item.expirationDate!.difference(now).inDays;
        if (difference < 0) {
          alerts.add(
            AlertItemModel(
              id: 'expired-${item.id}',
              item: item,
              alertType: AlertType.expired,
              message: '${item.name} expired on ${item.expirationDate!.toLocal().toIso8601String().split('T').first}',
              createdAt: now,
            ),
          );
        } else if (difference <= _settings.expirationWarningDays) {
          alerts.add(
            AlertItemModel(
              id: 'expiring-${item.id}',
              item: item,
              alertType: AlertType.expiringSoon,
              message: '${item.name} expires in $difference day${difference == 1 ? '' : 's'}',
              createdAt: now,
            ),
          );
        }
      }
    }

    _allAlerts = alerts;
  }

  void _emitLoaded() {
    final filteredAlerts = _activeFilter == null
        ? _allAlerts
        : _allAlerts.where((alert) => alert.alertType == _activeFilter).toList();

    final lowStockCount =
        _allAlerts.where((alert) => alert.alertType == AlertType.lowStock).length;
    final expiringCount =
        _allAlerts.where((alert) => alert.alertType == AlertType.expiringSoon).length;
    final expiredCount =
        _allAlerts.where((alert) => alert.alertType == AlertType.expired).length;

    state = AlertLoaded(
      alerts: filteredAlerts,
      settings: _settings,
      lowStockCount: lowStockCount,
      expiringCount: expiringCount,
      expiredCount: expiredCount,
    );
  }

  Future<void> _loadSettings() async {
    final box = await _openSettingsBox();
    if (box.isEmpty) {
      final defaults = AlertSettingsModel.defaultSettings();
      await box.put(defaults.id, defaults);
      _settings = defaults;
    } else {
      _settings = box.get('default') ?? AlertSettingsModel.defaultSettings();
    }
  }

  Future<Box<AlertSettingsModel>> _openSettingsBox() async {
    if (Hive.isBoxOpen(_settingsBoxName)) {
      return Hive.box<AlertSettingsModel>(_settingsBoxName);
    }
    return Hive.openBox<AlertSettingsModel>(_settingsBoxName);
  }

  Future<Box<PantryItemModel>> _openPantryBox() async {
    if (Hive.isBoxOpen('pantry_items')) {
      return Hive.box<PantryItemModel>('pantry_items');
    }
    return Hive.openBox<PantryItemModel>('pantry_items');
  }
}
