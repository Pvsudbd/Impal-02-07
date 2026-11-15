class GroupMember {
  String _memberId;
  String _role;
  DateTime _joinedDate;

  GroupMember({
    required String memberId,
    required String role,
    required DateTime joinedDate,
  })  : _memberId = memberId,
        _role = role,
        _joinedDate = joinedDate;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return GroupMember(
      memberId: json['id_user'] ?? json['id_student'] ?? json['id_member'] ?? '',
      role: json['role'] ?? 'MEMBER',
      joinedDate: parseDate(json['joined_date'] ?? json['joined_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': _memberId,
      'id_student': _memberId,
      'role': _role,
      'joined_date': _joinedDate.toIso8601String(),
    };
  }

  String get memberId => _memberId;
  DateTime get joinedDate => _joinedDate;

  String getRole() {
    return _role;
  }
}
