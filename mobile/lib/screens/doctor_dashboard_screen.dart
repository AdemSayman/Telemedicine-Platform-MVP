import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment_model.dart';
import '../providers/main_provider.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Doktor Paneli'),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF10233F),
            elevation: 0,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: provider.fetchDoctorAppointments,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  Text(
                    'Gelen Randevular',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF10233F),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hastalarin talep ettigi randevulari burada gorebilir, onaylayabilir veya tamamlayabilirsin.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 22),
                  if (provider.isLoadingDoctorAppointments &&
                      provider.doctorAppointments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.doctorAppointments.isEmpty)
                    const _EmptyDoctorAppointmentsState()
                  else
                    ...provider.doctorAppointments.map(
                      (appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _DoctorAppointmentTile(appointment: appointment),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DoctorAppointmentTile extends StatelessWidget {
  const _DoctorAppointmentTile({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MainProvider>();
    final statusStyle = _statusPalette(appointment.status);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF2A85FF),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientName ?? 'Hasta bilgisi',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: const Color(0xFF10233F),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appointment.patientPhone ?? '-',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: Color(0xFF2A85FF),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formatDate(appointment.appointmentDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusStyle.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusStyle.label,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: statusStyle.foreground,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appointment.paymentStatus ? 'Odendi' : 'Bekliyor',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DoctorActionButtons(
                appointment: appointment,
                provider: provider,
              ),
            ],
          ),
        ),
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

    return '$day ${months[date.month - 1]} ${date.year} - $hour:$minute';
  }
}

class _DoctorActionButtons extends StatelessWidget {
  const _DoctorActionButtons({
    required this.appointment,
    required this.provider,
  });

  final AppointmentModel appointment;
  final MainProvider provider;

  @override
  Widget build(BuildContext context) {
    final isPending = appointment.status == 'pending';
    final isPaid = appointment.status == 'paid';
    final isCompleted = appointment.status == 'completed';
    final isCancelled = appointment.status == 'cancelled';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPending) ...[
          FilledButton(
            onPressed: () => _handleAction(
              context,
              status: 'paid',
              paymentStatus: true,
              successMessage: 'Randevu onaylandi ve odeme bekleniyor.',
            ),
            child: const Text('Onayla'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _handleAction(
              context,
              status: 'cancelled',
              successMessage: 'Randevu iptal edildi.',
            ),
            child: const Text('Reddet'),
          ),
        ] else if (isPaid) ...[
          FilledButton(
            onPressed: () => _handleAction(
              context,
              status: 'completed',
              paymentStatus: true,
              successMessage: 'Randevu tamamlandi.',
            ),
            child: const Text('Tamamlandi olarak isaretle'),
          ),
        ] else if (isCompleted || isCancelled) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              isCompleted ? 'Gorusme tamamlandi.' : 'Randevu iptal edildi.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context, {
    required String status,
    bool? paymentStatus,
    required String successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.updateAppointmentStatus(
        appointmentId: appointment.id,
        status: status,
        paymentStatus: paymentStatus,
      );

      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
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

_StatusPalette _statusPalette(String status) {
  switch (status) {
    case 'paid':
      return const _StatusPalette(
        label: 'Paid',
        background: Color(0xFFE7F7EE),
        foreground: Color(0xFF237A52),
      );
    case 'completed':
      return const _StatusPalette(
        label: 'Completed',
        background: Color(0xFFEAF3FF),
        foreground: Color(0xFF2A85FF),
      );
    case 'pending':
      return const _StatusPalette(
        label: 'Pending',
        background: Color(0xFFFFF3E3),
        foreground: Color(0xFFC97A18),
      );
    case 'cancelled':
      return const _StatusPalette(
        label: 'Cancelled',
        background: Color(0xFFFBE7E9),
        foreground: Color(0xFFB65460),
      );
    default:
      return const _StatusPalette(
        label: 'Unknown',
        background: Color(0xFFF1F5F9),
        foreground: Color(0xFF64748B),
      );
  }
}

class _EmptyDoctorAppointmentsState extends StatelessWidget {
  const _EmptyDoctorAppointmentsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Color(0xFF2A85FF),
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gorulecek bir randevu yok',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni hasta talepleri geldiginde burada listelenecek.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
