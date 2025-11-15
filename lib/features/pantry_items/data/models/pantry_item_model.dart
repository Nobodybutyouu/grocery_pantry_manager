import 'package:hive/hive.dart';

part 'pantry_item_model.g.dart';

@HiveType(typeId: 0)
class PantryItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime? expirationDate;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  PantryItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.expirationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  PantryItemModel copyWith({
    String? id,
    String? name,
    int? quantity,
    String? category,
    DateTime? expirationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PantryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PantryItemModel.fromJson(Map<String, dynamic> json) {
    return PantryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      category: json['category'] as String,
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'expirationDate': expirationDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PantryItemModel(id: $id, name: $name, quantity: $quantity, category: $category, '
        'expirationDate: $expirationDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PantryItemModel &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.category == category &&
        other.expirationDate == expirationDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      quantity,
      category,
      expirationDate,
      createdAt,
      updatedAt,
    );
  }
}