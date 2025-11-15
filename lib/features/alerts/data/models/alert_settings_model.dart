import 'package:hive/hive.dart';

part 'alert_settings_model.g.dart';

@HiveType(typeId: 1)
class AlertSettingsModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int lowStockThreshold;

  @HiveField(2)
  final int expirationWarningDays;

  @HiveField(3)
  final bool enableLowStockAlerts;

  @HiveField(4)
  final bool enableExpirationAlerts;

  @HiveField(5)
  final DateTime updatedAt;

  AlertSettingsModel({
    required this.id,
    required this.lowStockThreshold,
    required this.expirationWarningDays,
    required this.enableLowStockAlerts,
    required this.enableExpirationAlerts,
    required this.updatedAt,
  });

  AlertSettingsModel copyWith({
    String? id,
    int? lowStockThreshold,
    int? expirationWarningDays,
    bool? enableLowStockAlerts,
    bool? enableExpirationAlerts,
    DateTime? updatedAt,
  }) {
    return AlertSettingsModel(
      id: id ?? this.id,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      expirationWarningDays: expirationWarningDays ?? this.expirationWarningDays,
      enableLowStockAlerts: enableLowStockAlerts ?? this.enableLowStockAlerts,
      enableExpirationAlerts: enableExpirationAlerts ?? this.enableExpirationAlerts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Default settings
  factory AlertSettingsModel.defaultSettings() {
    return AlertSettingsModel(
      id: 'default',
      lowStockThreshold: 2,
      expirationWarningDays: 7,
      enableLowStockAlerts: true,
      enableExpirationAlerts: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertSettingsModel &&
        other.id == id &&
        other.lowStockThreshold == lowStockThreshold &&
        other.expirationWarningDays == expirationWarningDays &&
        other.enableLowStockAlerts == enableLowStockAlerts &&
        other.enableExpirationAlerts == enableExpirationAlerts &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        lowStockThreshold.hashCode ^
        expirationWarningDays.hashCode ^
        enableLowStockAlerts.hashCode ^
        enableExpirationAlerts.hashCode ^
        updatedAt.hashCode;
  }
}