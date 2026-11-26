class GroupMember {
  String _idMember;
  String _groupId;
  String _userId;
  String _role;
  DateTime _joinedDate;
  String? _userName;
  String? _userEmail;

  GroupMember({
    String idMember = '',
    String groupId = '',
    required String memberId,
    required String role,
    required DateTime joinedDate,
    String? userName,
    String? userEmail,
  })  : _idMember = idMember,
        _groupId = groupId,
        _userId = memberId,
        _role = role,
        _joinedDate = joinedDate,
        _userName = userName,
        _userEmail = userEmail;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return GroupMember(
      idMember: json['id_member']?.toString() ?? '',
      groupId: json['id_group']?.toString() ?? json['groupId']?.toString() ?? '',
      memberId: json['id_user']?.toString() ??
          json['id_student']?.toString() ??
          json['memberId']?.toString() ??
          json['id_member']?.toString() ??
          '',
      role: json['role']?.toString() ?? 'MEMBER',
      joinedDate: parseDate(json['joined_date'] ?? json['joined_at']),
      userName: json['name']?.toString() ?? json['user_name']?.toString(),
      userEmail: json['email']?.toString() ?? json['user_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_member': _idMember,
      'id_group': _groupId,
      'id_user': _userId,
      'id_student': _userId,
      'role': _role,
      'joined_date': _joinedDate.toIso8601String(),
      'joined_at': _joinedDate.toIso8601String(),
      if (_userName != null) 'name': _userName,
      if (_userEmail != null) 'email': _userEmail,
    };
  }

  String get idMember => _idMember;
  String get groupId => _groupId;
  String get memberId => _userId;
  String get userId => _userId;
  DateTime get joinedDate => _joinedDate;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  set groupId(String val) => _groupId = val;
  set idMember(String val) => _idMember = val;

  String getRole() {
    return _role;
  }
}
