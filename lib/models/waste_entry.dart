import 'dart:convert';

class WasteEntry {
  final String id;
  final String itemName;
  final String category;
  final double quantity;
  final String unit;
  final double unitCost;
  final String reason;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const WasteEntry({
    required this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.reason,
    required this.date,
    this.note,
    required this.createdAt,
  });

  double get totalLoss => quantity * unitCost;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'unitCost': unitCost,
      'reason': reason,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WasteEntry.fromMap(Map<String, dynamic> map) {
    return WasteEntry(
      id: map['id'] as String,
      itemName: map['itemName'] as String? ?? '',
      category: map['category'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'kg',
      unitCost: (map['unitCost'] as num?)?.toDouble() ?? 0,
      reason: map['reason'] as String? ?? 'Other',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      note: map['note'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory WasteEntry.fromJson(String source) =>
      WasteEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}