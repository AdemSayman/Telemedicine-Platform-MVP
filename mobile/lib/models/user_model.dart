class UserModel {
  const UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
  });

  final int id;
  final String phoneNumber;
  final String fullName;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asInt(json['id']),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }

  UserModel copyWith({
    int? id,
    String? phoneNumber,
    String? fullName,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString()) ?? 0;
  }
}
