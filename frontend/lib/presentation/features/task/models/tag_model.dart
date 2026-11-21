import 'package:flutter/material.dart';
import 'task_item_model.dart';

/// Preset accessible color swatches for Custom Task Tags.
@immutable
class TagColorPreset {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color textColor;

  const TagColorPreset({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
  });

  static const List<TagColorPreset> presets = [
    TagColorPreset(
      id: 'periwinkle',
      name: 'Periwinkle',
      backgroundColor: Color(0xFF778BEB),
      textColor: Color(0xFF1E296B),
    ),
    TagColorPreset(
      id: 'aqua',
      name: 'Aqua',
      backgroundColor: Color(0xFF63CDDA),
      textColor: Color(0xFF144D56),
    ),
    TagColorPreset(
      id: 'coral',
      name: 'Coral',
      backgroundColor: Color(0xFFFA6144),
      textColor: Colors.white,
    ),
    TagColorPreset(
      id: 'emerald',
      name: 'Emerald',
      backgroundColor: Color(0xFF6EE7B7),
      textColor: Color(0xFF064E3B),
    ),
    TagColorPreset(
      id: 'amber',
      name: 'Amber',
      backgroundColor: Color(0xFFFBBF24),
      textColor: Color(0xFF1F2937),
    ),
    TagColorPreset(
      id: 'plum',
      name: 'Plum',
      backgroundColor: Color(0xFF786FA6),
      textColor: Color(0xFFF1EEFF),
    ),
  ];

  static TagColorPreset byId(String? id) {
    for (final preset in presets) {
      if (preset.id == id) return preset;
    }
    return presets.first;
  }
}

/// Centralized representation of a reusable Custom Task Tag / Smart Filter Label.
@immutable
class CustomTagModel {
  final String id;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isDefault;

  const CustomTagModel({
    required this.id,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.isDefault = false,
  });

  TaskTagModel toTaskTagModel() {
    return TaskTagModel(
      label: label,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'background_color': backgroundColor.toARGB32(),
      'text_color': textColor.toARGB32(),
      'is_default': isDefault,
    };
  }

  factory CustomTagModel.fromMap(Map<String, dynamic> map) {
    return CustomTagModel(
      id: (map['id'] ?? '').toString(),
      label: (map['label'] ?? '').toString(),
      backgroundColor: Color(
        (map['background_color'] as num?)?.toInt() ?? 0xFF778BEB,
      ),
      textColor: Color(
        (map['text_color'] as num?)?.toInt() ?? 0xFF1E296B,
      ),
      isDefault: map['is_default'] == true,
    );
  }
}
