// lib/features/alerts/data/models/alert_item_model.dart

import '../../../pantry_items/data/models/pantry_item_model.dart';

enum AlertType { lowStock, expiringSoon, expired }

class AlertItemModel {
  const AlertItemModel({
    required this.id,
    required this.item,
    required this.alertType,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final PantryItemModel item;
  final AlertType alertType;
  final String message;
  final DateTime createdAt;

  AlertItemModel copyWith({
    String? id,
    PantryItemModel? item,
    AlertType? alertType,
    String? message,
    DateTime? createdAt,
  }) {
    return AlertItemModel(
      id: id ?? this.id,
      item: item ?? this.item,
      alertType: alertType ?? this.alertType,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AlertItemModel &&
        other.id == id &&
        other.item == item &&
        other.alertType == alertType &&
        other.message == message &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, item, alertType, message, createdAt);
  }
}
