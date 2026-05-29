import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/appointment_model.dart';
import '../../../providers/main_provider.dart';

class DoctorPatientsTab extends StatelessWidget {
  const DoctorPatientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();
    final patients = _buildUniquePatients(provider.doctorAppointments);

    if (patients.isEmpty) {
      return const _EmptySection();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final patient = patients[index];
        return _PatientCard(patient: patient);
      },
    );
  }

  List<_PatientViewModel> _buildUniquePatients(List<AppointmentModel> appointments) {
    final map = <int, _PatientViewModel>{};
    for (final appointment in appointments) {
      final patientId = appointment.patientId ?? 0;
      if (patientId == 0) continue;
      map.putIfAbsent(
        patientId,
        () => _PatientViewModel(
          id: patientId,
          name: appointment.patientName ?? 'Hasta',
          phone: appointment.patientPhone ?? '-',
          lastVisit: appointment.appointmentDate,
        ),
      );
    }
    return map.values.toList()
      ..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final _PatientViewModel patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFF2A85FF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF10233F),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  patient.phone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Son: ${_formatShortDate(patient.lastVisit)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF2A85FF),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

class _PatientViewModel {
  _PatientViewModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.lastVisit,
  });

  final int id;
  final String name;
  final String phone;
  final DateTime lastVisit;
}

class _EmptySection extends StatelessWidget {
  const _EmptySection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.people_alt_rounded, size: 40, color: Color(0xFF2A85FF)),
            ),
            const SizedBox(height: 20),
            Text(
              'Henüz hasta kaydı yok',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF10233F),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Onaylanmış bir randevun olduğunda hastaların burada listelenecek.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
