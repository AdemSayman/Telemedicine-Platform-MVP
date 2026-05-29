import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/appointment_model.dart';
import '../../../providers/main_provider.dart';
import '../../video_call_screen.dart';

class DoctorAppointmentsTab extends StatefulWidget {
  const DoctorAppointmentsTab({super.key});

  @override
  State<DoctorAppointmentsTab> createState() => _DoctorAppointmentsTabState();
}

class _DoctorAppointmentsTabState extends State<DoctorAppointmentsTab> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();
    final appointments = provider.doctorAppointments;
    final pendingAppointments = appointments.where((appointment) => appointment.status == 'pending').toList();
    final confirmedAppointments = appointments.where((appointment) => appointment.status == 'paid' || appointment.status == 'completed').toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              _TabButton(
                label: 'Bekleyen Talepler',
                isActive: _activeTabIndex == 0,
                onTap: () => setState(() => _activeTabIndex = 0),
              ),
              const SizedBox(width: 12),
              _TabButton(
                label: 'Onaylananlar',
                isActive: _activeTabIndex == 1,
                onTap: () => setState(() => _activeTabIndex = 1),
              ),
            ],
          ),
        ),
        Expanded(
          child: _activeTabIndex == 0
              ? _buildPendingTab(context, provider, pendingAppointments)
              : _buildConfirmedTab(context, confirmedAppointments),
        ),
      ],
    );
  }

  Widget _buildPendingTab(BuildContext context, MainProvider provider, List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return const _EmptySection(message: 'Henüz onay bekleyen randevu yok.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentRequestCard(
          appointment: appointment,
          onAccept: () async {
            await provider.updateAppointmentStatus(
              appointmentId: appointment.id,
              status: 'paid',
              paymentStatus: true,
            );
          },
          onReject: () async {
            await provider.updateAppointmentStatus(
              appointmentId: appointment.id,
              status: 'cancelled',
            );
          },
        );
      },
    );
  }

  Widget _buildConfirmedTab(BuildContext context, List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return const _EmptySection(message: 'Henüz onaylanmış randevu yok.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _ConfirmedAppointmentCard(
          appointment: appointment,
          onStartCall: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideoCallScreen(appointment: appointment),
              ),
            );
          },
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2A85FF) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? const Color(0xFF2A85FF) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isActive ? Colors.white : const Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentRequestCard extends StatelessWidget {
  const _AppointmentRequestCard({
    required this.appointment,
    required this.onAccept,
    required this.onReject,
  });

  final AppointmentModel appointment;
  final VoidCallback onAccept;
  final VoidCallback onReject;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_rounded, color: Color(0xFF2A85FF)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName ?? 'Hasta bilgisi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF10233F),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF2A85FF)),
              const SizedBox(width: 8),
              Text(
                _formatDate(appointment.appointmentDate),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF10233F),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2A85FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Onayla'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2A85FF),
                    side: const BorderSide(color: Color(0xFFBED7F5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Reddet'),
                ),
              ),
            ],
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
    return '$day ${months[date.month - 1]} • $hour:$minute';
  }
}

class _ConfirmedAppointmentCard extends StatelessWidget {
  const _ConfirmedAppointmentCard({
    required this.appointment,
    required this.onStartCall,
  });

  final AppointmentModel appointment;
  final VoidCallback onStartCall;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_rounded, color: Color(0xFF2A85FF)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName ?? 'Hasta bilgisi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF10233F),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.patientPhone ?? '-',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatDate(appointment.appointmentDate),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onStartCall,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2A85FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Görüşmeyi Başlat'),
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
    return '$day ${months[date.month - 1]} • $hour:$minute';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final palette = _statusPalette(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        palette.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: palette.foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

_StatusPalette _statusPalette(String status) {
  switch (status) {
    case 'pending':
      return const _StatusPalette(
        label: 'Beklemede',
        background: Color(0xFFFFF3E3),
        foreground: Color(0xFFC97A18),
      );
    case 'paid':
      return const _StatusPalette(
        label: 'Onaylandı',
        background: Color(0xFFEAF3FF),
        foreground: Color(0xFF2A85FF),
      );
    case 'completed':
      return const _StatusPalette(
        label: 'Tamamlandı',
        background: Color(0xFFE7F7EE),
        foreground: Color(0xFF237A52),
      );
    case 'cancelled':
      return const _StatusPalette(
        label: 'İptal',
        background: Color(0xFFFBE7E9),
        foreground: Color(0xFFB65460),
      );
    default:
      return const _StatusPalette(
        label: 'Bilinmiyor',
        background: Color(0xFFF1F5F9),
        foreground: Color(0xFF64748B),
      );
  }
}

class _StatusPalette {
  const _StatusPalette({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

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
              child: const Icon(Icons.event_busy_rounded, size: 40, color: Color(0xFF2A85FF)),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF10233F),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Yeni randevular geldikçe burada görünecek.',
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
