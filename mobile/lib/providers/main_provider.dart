import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../models/user_model.dart';

class MainProvider extends ChangeNotifier {
  MainProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  UserModel? _currentUser;
  List<DoctorModel> _doctors = const [];
  List<AppointmentModel> _appointments = const [];
  List<AppointmentModel> _doctorAppointments = const [];
  String _doctorSpecialty = 'Genel';
  int _doctorExperienceYears = 5;
  String _doctorHospitalName = 'Moritanya Hastanesi';
  String _doctorBiography = 'Hastalara modern yaklaşım ve uzman bakışıyla hizmet veriyorum.';
  bool _isAuthenticating = false;
  bool _isLoadingDoctors = false;
  bool _isLoadingAppointments = false;
  bool _isLoadingDoctorAppointments = false;
  bool _isBookingAppointment = false;
  bool _isUpdatingProfile = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  List<DoctorModel> get doctors => _doctors;
  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentModel> get doctorAppointments => _doctorAppointments;
  String get doctorSpecialty => _doctorSpecialty;
  int get doctorExperienceYears => _doctorExperienceYears;
  String get doctorHospitalName => _doctorHospitalName;
  String get doctorBiography => _doctorBiography;
  bool get isAuthenticating => _isAuthenticating;
  bool get isLoadingDoctors => _isLoadingDoctors;
  bool get isLoadingAppointments => _isLoadingAppointments;
  bool get isLoadingDoctorAppointments => _isLoadingDoctorAppointments;
  bool get isBookingAppointment => _isBookingAppointment;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get errorMessage => _errorMessage;

  bool get isBusy =>
      _isAuthenticating ||
      _isLoadingDoctors ||
      _isLoadingAppointments ||
      _isBookingAppointment;

  Future<void> login({
    required String phoneNumber,
    String? fullName,
    String role = 'patient',
    String? specialty,
    int? experienceYears,
  }) async {
    _isAuthenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _apiClient.login(
        phoneNumber: phoneNumber,
        fullName: fullName,
        role: role,
        specialty: specialty,
        experienceYears: experienceYears,
      );

      if (_currentUser?.role == 'doctor') {
        await fetchDoctorAppointments(notify: false);
      } else {
        await Future.wait([
          fetchDoctors(notify: false),
          fetchAppointments(notify: false),
        ]);
      }
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> fetchDoctors({bool notify = true}) async {
    _isLoadingDoctors = true;
    _errorMessage = null;
    if (notify) {
      notifyListeners();
    }

    try {
      _doctors = await _apiClient.getDoctors();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoadingDoctors = false;
      if (notify) {
        notifyListeners();
      }
    }
  }

  Future<void> fetchAppointments({bool notify = true}) async {
    final user = _currentUser;
    if (user == null) {
      _appointments = const [];
      if (notify) {
        notifyListeners();
      }
      return;
    }

    _isLoadingAppointments = true;
    _errorMessage = null;
    if (notify) {
      notifyListeners();
    }

    try {
      _appointments = await _apiClient.getPatientAppointments(user.id);
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoadingAppointments = false;
      if (notify) {
        notifyListeners();
      }
    }
  }

  Future<void> fetchDoctorAppointments({bool notify = true}) async {
    final user = _currentUser;
    if (user == null || user.role != 'doctor') {
      _doctorAppointments = const [];
      if (notify) {
        notifyListeners();
      }
      return;
    }

    _isLoadingDoctorAppointments = true;
    _errorMessage = null;
    if (notify) {
      notifyListeners();
    }

    try {
      _doctorAppointments = await _apiClient.getDoctorAppointments(user.id);
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoadingDoctorAppointments = false;
      if (notify) {
        notifyListeners();
      }
    }
  }

  Future<AppointmentModel> bookAppointment(DoctorModel doctor) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Randevu almak icin once giris yapilmasi gerekiyor.');
    }

    _isBookingAppointment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final scheduledAt = DateTime(
        now.year,
        now.month,
        now.day + 1,
        10 + (doctor.id % 5),
      );

      final appointment = await _apiClient.createAppointment(
        patientId: user.id,
        doctorId: doctor.id,
        appointmentDate: scheduledAt,
      );

      await fetchAppointments(notify: false);
      return appointment;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isBookingAppointment = false;
      notifyListeners();
    }
  }

  Future<AppointmentModel> updateAppointmentStatus({
    required int appointmentId,
    String? status,
    bool? paymentStatus,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Once giris yapman gerekiyor.');
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final appointment = await _apiClient.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
        paymentStatus: paymentStatus,
      );

      if (user.role == 'doctor') {
        await fetchDoctorAppointments(notify: false);
      } else {
        await fetchAppointments(notify: false);
      }

      return appointment;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Giris yapilmis kullanici bulunamadi.');
    }

    _isUpdatingProfile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _apiClient.updateProfile(
        userId: user.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      _currentUser = updatedUser;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }
  }

  void updateDoctorProfile({
    String? specialty,
    int? experienceYears,
    String? hospitalName,
    String? biography,
  }) {
    if (specialty != null && specialty.isNotEmpty) {
      _doctorSpecialty = specialty;
    }
    if (experienceYears != null && experienceYears > 0) {
      _doctorExperienceYears = experienceYears;
    }
    if (hospitalName != null && hospitalName.isNotEmpty) {
      _doctorHospitalName = hospitalName;
    }
    if (biography != null && biography.isNotEmpty) {
      _doctorBiography = biography;
    }
    notifyListeners();
  }

  Future<void> refreshHomeData() async {
    if (_currentUser?.role == 'doctor') {
      await fetchDoctorAppointments(notify: false);
    } else {
      await Future.wait([
        fetchDoctors(notify: false),
        fetchAppointments(notify: false),
      ]);
    }
    notifyListeners();
  }

  void clearSession() {
    _currentUser = null;
    _doctors = const [];
    _appointments = const [];
    _doctorAppointments = const [];
    _doctorSpecialty = 'Genel';
    _doctorExperienceYears = 5;
    _doctorHospitalName = 'Moritanya Hastanesi';
    _doctorBiography = 'Hastalara modern yaklaşım ve uzman bakışıyla hizmet veriyorum.';
    _errorMessage = null;
    notifyListeners();
  }
}
