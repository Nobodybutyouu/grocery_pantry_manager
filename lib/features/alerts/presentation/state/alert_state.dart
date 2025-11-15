// lib/features/alerts/presentation/state/alert_state.dart

import '../../data/models/alert_item_model.dart';
import '../../data/models/alert_settings_model.dart';

abstract class AlertState {
  const AlertState();
}

class AlertInitial extends AlertState {
  const AlertInitial();
}

class AlertLoading extends AlertState {
  const AlertLoading();
}

class AlertLoaded extends AlertState {
  final List<AlertItemModel> alerts;
  final AlertSettingsModel settings;
  final int lowStockCount;
  final int expiringCount;
  final int expiredCount;

  const AlertLoaded({
    required this.alerts,
    required this.settings,
    required this.lowStockCount,
    required this.expiringCount,
    required this.expiredCount,
  });
}

class AlertError extends AlertState {
  final String message;

  const AlertError(this.message);
}

class AlertSuccess extends AlertState {
  final String message;

  const AlertSuccess(this.message);
}

class AlertSettingsState {
  const AlertSettingsState();
}

class AlertSettingsInitial extends AlertSettingsState {
  const AlertSettingsInitial();
}

class AlertSettingsLoading extends AlertSettingsState {
  const AlertSettingsLoading();
}

class AlertSettingsLoaded extends AlertSettingsState {
  final AlertSettingsModel settings;

  const AlertSettingsLoaded(this.settings);
}

class AlertSettingsError extends AlertSettingsState {
  final String message;

  const AlertSettingsError(this.message);
}

class AlertSettingsSuccess extends AlertSettingsState {
  final String message;
  final AlertSettingsModel settings;

  const AlertSettingsSuccess(this.message, this.settings);
}