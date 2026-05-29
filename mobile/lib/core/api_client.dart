import 'package:dio/dio.dart';

import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../models/user_model.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.0.2.2:3000/api',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  final Dio _dio;

  Future<UserModel> login({
    required String phoneNumber,
    String? fullName,
    String role = 'patient',
    String? specialty,
    int? experienceYears,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'phone_number': phoneNumber,
          'role': role,
          if (fullName != null && fullName.trim().isNotEmpty)
            'full_name': fullName.trim(),
          if (role == 'doctor' && specialty != null && specialty.trim().isNotEmpty)
            'specialty': specialty.trim(),
          if (role == 'doctor' && experienceYears != null)
            'experience_years': experienceYears,
        },
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Kullanici verisi alinamadi.');
      }

      return UserModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<DoctorModel>> getDoctors() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/doctors');
      final rawList = response.data?['data'] as List<dynamic>? ?? [];

      return rawList
          .map(
            (item) => DoctorModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<AppointmentModel> createAppointment({
    required int patientId,
    required int doctorId,
    required DateTime appointmentDate,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/appointments',
        data: {
          'patient_id': patientId,
          'doctor_id': doctorId,
          'appointment_date': appointmentDate.toIso8601String(),
        },
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Randevu verisi alinamadi.');
      }

      return AppointmentModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<AppointmentModel>> getDoctorAppointments(int doctorId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/appointments/doctor/$doctorId',
      );
      final payload = response.data?['data'] as Map<String, dynamic>? ?? {};
      final rawList = payload['appointments'] as List<dynamic>? ?? [];

      return rawList
          .map(
            (item) => AppointmentModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<AppointmentModel> updateAppointmentStatus({
    required int appointmentId,
    String? status,
    bool? paymentStatus,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/appointments/$appointmentId/status',
        data: {
          if (status != null) 'status': status,
          if (paymentStatus != null) 'payment_status': paymentStatus,
        },
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Randevu verisi alinamadi.');
      }

      return AppointmentModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<UserModel> updateProfile({
    required int userId,
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/users/profile',
        data: {
          'user_id': userId,
          if (fullName != null && fullName.trim().isNotEmpty)
            'full_name': fullName.trim(),
          if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
            'phone_number': phoneNumber.trim(),
        },
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Kullanici verisi alinamadi.');
      }

      return UserModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<AppointmentModel>> getPatientAppointments(int patientId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/appointments/patient/$patientId',
      );
      final payload = response.data?['data'] as Map<String, dynamic>? ?? {};
      final rawList = payload['appointments'] as List<dynamic>? ?? [];

      return rawList
          .map(
            (item) => AppointmentModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  String _extractErrorMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Sunucuya baglanirken zaman asimi olustu.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Backend baglantisi kurulamadi. Emulator ve server durumunu kontrol et.';
    }

    return 'Beklenmeyen bir ag hatasi olustu.';
  }
}
