class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.appointmentDate,
    required this.status,
    required this.paymentStatus,
    required this.agoraToken,
    this.patientId,
    this.doctorId,
    this.doctorName,
    this.specialty,
    this.patientName,
    this.patientPhone,
  });

  final int id;
  final DateTime appointmentDate;
  final String status;
  final bool paymentStatus;
  final String agoraToken;
  final int? patientId;
  final int? doctorId;
  final String? doctorName;
  final String? specialty;
  final String? patientName;
  final String? patientPhone;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: _asInt(json['id']),
      appointmentDate: DateTime.tryParse(
            (json['appointment_date'] ?? '').toString(),
          ) ??
          DateTime.now(),
      status: (json['status'] ?? '').toString(),
      paymentStatus: _asBool(json['payment_status']),
      agoraToken: (json['agora_token'] ?? '').toString(),
      patientId: json['patient_id'] == null ? null : _asInt(json['patient_id']),
      doctorId: json['doctor_id'] == null ? null : _asInt(json['doctor_id']),
      doctorName: json['doctor_name']?.toString(),
      specialty: json['specialty']?.toString(),
      patientName: json['patient_name']?.toString(),
      patientPhone: json['patient_phone']?.toString(),
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
