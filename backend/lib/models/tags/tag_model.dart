class TagModel {
  final String idTag;
  final String idUser;
  final String label;
  final int backgroundColor;
  final int textColor;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TagModel({
    required this.idTag,
    required this.idUser,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return TagModel(
      idTag: (json['id_tag'] ?? json['id'] ?? '').toString(),
      idUser: (json['id_user'] ?? json['id_student'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      backgroundColor: (json['background_color'] as num?)?.toInt() ?? 0xFF778BEB,
      textColor: (json['text_color'] as num?)?.toInt() ?? 0xFF1E296B,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      createdAt: parseDt(json['created_at']),
      updatedAt: parseDt(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idTag,
      'id_tag': idTag,
      'id_user': idUser,
      'label': label,
      'background_color': backgroundColor,
      'text_color': textColor,
      'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

