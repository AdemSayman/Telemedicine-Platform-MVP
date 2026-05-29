import 'user_model.dart';

class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.specialty,
    required this.experienceYears,
    required this.isAvailable,
    required this.user,
  });

  final int id;
  final String specialty;
  final int experienceYears;
  final bool isAvailable;
  final UserModel user;

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final nestedUser = json['user'];

    return DoctorModel(
      id: _asInt(json['doctor_id'] ?? json['id']),
      specialty: (json['specialty'] ?? '').toString(),
      experienceYears: _asInt(json['experience_years']),
      isAvailable: _asBool(json['is_available']),
      user: nestedUser is Map<String, dynamic>
          ? UserModel.fromJson(nestedUser)
          : UserModel(
              id: _asInt(json['user_id'] ?? json['id']),
              phoneNumber: (json['phone_number'] ?? '').toString(),
              fullName: (json['full_name'] ?? '').toString(),
              role: (json['role'] ?? 'doctor').toString(),
            ),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value == 1;
    }

    final normalized = value.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
}
