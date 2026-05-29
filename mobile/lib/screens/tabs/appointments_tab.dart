import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment_model.dart';
import '../../providers/main_provider.dart';
import '../video_call_screen.dart';

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: provider.fetchAppointments,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  Text(
                    'Randevularim',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF10233F),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tum gorusmelerini, durumlarini ve goruntulu baglantiya hazir randevularini bu alandan yonetebilirsin.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 22),
                  if (provider.isLoadingAppointments &&
                      provider.appointments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.appointments.isEmpty)
                    const _EmptyAppointmentsState()
                  else
                    ...provider.appointments.map(
                      (appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AppointmentTile(appointment: appointment),
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

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final canJoinCall =
        appointment.status == 'completed' || appointment.status == 'paid';
    final statusStyle = _statusPalette(appointment.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canJoinCall
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoCallScreen(appointment: appointment),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(20),
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
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF2A85FF),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName ?? 'Doktor bilgisi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF10233F),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        appointment.specialty ?? 'Brans bilgisi yok',
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
                      if (canJoinCall) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.videocam_rounded,
                              size: 16,
                              color: Color(0xFF2A85FF),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Goruntulu gorusmeye katil',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF2A85FF),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ],
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
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
          ),
        ),
      ),
    );
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

class _EmptyAppointmentsState extends StatelessWidget {
  const _EmptyAppointmentsState();

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
              Icons.event_busy_rounded,
              color: Color(0xFF2A85FF),
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Henuz randevu olusturmadin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anasayfa sekmesinden bir doktor secerek ilk gorusmeni hemen planlayabilirsin.',
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
