// lib/models/drug.dart - Complete version with all fields
import 'package:azlistview/azlistview.dart';

class Drug with ISuspensionBean {
  Drug({
    required this.name,
    required this.name_lower,
    required this.keywords,
    required this.mechanism,
    required this.susceptibility,
    required this.dosage,
    required this.adverse,
    required this.status,
    required this.references,
    required this.trials,
    required this.features,
    required this.images,
  }) : tag = name.isNotEmpty ? name[0].toUpperCase() : '#';

  final String name;
  String tag;
  final String name_lower;
  final List<dynamic> keywords;
  final String mechanism;
  final String susceptibility;
  final String dosage;
  final String adverse;
  final String status;
  final List<dynamic> references;
  final List<dynamic> trials;
  final String features; // Added this field
  final String images; // Added this field

  factory Drug.fromMap(Map<String, dynamic> map) {
    try {
      return Drug(
        name: (map['name'] ?? '').toString(),

        // Handle name_lower being either String or number
        name_lower: (map['name_lower'] ?? '').toString().toLowerCase(),

        // Handle keywords - could be array or string
        keywords: _parseArrayField(map['keywords']),

        mechanism: (map['mechanism'] ?? '').toString(),
        susceptibility: (map['susceptibility'] ?? '').toString(),
        dosage: (map['dosage'] ?? '').toString(),
        adverse: (map['adverse'] ?? '').toString(),
        status: (map['status'] ?? '').toString(),
        features: (map['features'] ?? '').toString(), // Added this field
        images: (map['images'] ?? '').toString(), // Added this field
        // Handle references - could be array or string
        references: _parseArrayField(map['references']),

        // Handle trials - could be array or string
        trials: _parseArrayField(map['trials']),
      );
    } catch (e) {
      print('❌ Error parsing Drug from map: $e');
      print('❌ Problematic map: $map');
      rethrow;
    }
  }

  // Helper function to parse array fields that might be strings or arrays
  static List<dynamic> _parseArrayField(dynamic field) {
    if (field == null) return [""];

    if (field is List) {
      return field.isEmpty ? [""] : field;
    }

    if (field is String) {
      if (field.isEmpty) return [""];

      // Try to parse as comma-separated values
      if (field.contains(',')) {
        return field.split(',').map((s) => s.trim()).toList();
      }

      // Single value
      return [field];
    }

    // Fallback
    return [field.toString()];
  }

  @override
  String getSuspensionTag() => tag;
}
