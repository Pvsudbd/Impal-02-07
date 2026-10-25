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
    return GroupMember(
      memberId: json['id_student'] ?? json['id_member'] ?? '',
      role: json['role'] ?? 'MEMBER',
      joinedDate: DateTime.parse(json['joined_date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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