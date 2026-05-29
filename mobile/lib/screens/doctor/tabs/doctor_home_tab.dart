import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/appointment_model.dart';
import '../../../providers/main_provider.dart';

class DoctorHomeTab extends StatelessWidget {
  const DoctorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();
    final currentUser = provider.currentUser;
    final appointments = provider.doctorAppointments;
    final todayAppointments = _countTodayAppointments(appointments);
    final pendingCount = _countByStatus(appointments, 'pending');
    final completedCount = _countByStatus(appointments, 'completed');
    final nextAppointment = _findNextAppointment(appointments);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, currentUser?.fullName ?? ''),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Bugünkü Randevular', value: todayAppointments.toString(), icon: Icons.today_rounded)),
              const SizedBox(width: 14),
              Expanded(child: _StatCard(label: 'Onay Bekleyenler', value: pendingCount.toString(), icon: Icons.hourglass_top_rounded)),
              const SizedBox(width: 14),
              Expanded(child: _StatCard(label: 'Tamamlananlar', value: completedCount.toString(), icon: Icons.check_circle_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Sıradaki Hasta',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          nextAppointment != null
              ? _NextPatientCard(appointment: nextAppointment)
              : _EmptyStateCard(
                  title: 'Henüz sıradaki hasta yok',
                  subtitle: 'Yeni bir randevu onaylandığında burada görünecek.',
                ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String fullName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A85FF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332A85FF),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş geldin Dr. ${fullName.split(' ').first}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Bugünün randevu özetini ve hastalarınla ilgili hızlı bilgileri buradan takip edebilirsin.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.88),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  int _countTodayAppointments(List<AppointmentModel> appointments) {
    final today = DateTime.now();
    return appointments.where((appointment) {
      final date = appointment.appointmentDate;
      return date.year == today.year && date.month == today.month && date.day == today.day;
    }).length;
  }

  int _countByStatus(List<AppointmentModel> appointments, String status) {
    return appointments.where((appointment) => appointment.status == status).length;
  }

  AppointmentModel? _findNextAppointment(List<AppointmentModel> appointments) {
    final now = DateTime.now();
    final upcoming = appointments.where((appointment) => appointment.appointmentDate.isAfter(now)).toList();
    if (upcoming.isEmpty) {
      return null;
    }
    upcoming.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    return upcoming.first;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2A85FF), size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
          ),
        ],
      ),
    );
  }
}

class _NextPatientCard extends StatelessWidget {
  const _NextPatientCard({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF2A85FF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName ?? 'Hasta bilgisi yok',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF10233F),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appointment.patientPhone ?? '-',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 18),
          Text(
            'Randevu Tarihi',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(appointment.appointmentDate),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Oca',
      'Sub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Agu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year} • $hour:$minute';
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.calendar_month_outlined, size: 40, color: Color(0xFF2A85FF)),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
