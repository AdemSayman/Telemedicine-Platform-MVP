import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../providers/main_provider.dart';
import 'widgets/doctor_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MainProvider>();
      provider.refreshHomeData().catchError((_) {});
    });
  }

  Future<void> _handleDoctorTap(DoctorModel doctor) async {
    final provider = context.read<MainProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!doctor.isAvailable) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${doctor.user.fullName} su anda yeni randevu kabul etmiyor.',
          ),
        ),
      );
      return;
    }

    final shouldBook = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final scheduledAt = _nextAppointmentDate(doctor.id);

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7E4F2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                'Randevu simulasyonu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF10233F),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                '${doctor.user.fullName} icin olusturulacak ilk uygun slot:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5D7290),
                    ),
              ),
              const SizedBox(height: 18),
              _InfoTile(
                icon: Icons.calendar_month_rounded,
                title: _formatAppointmentDate(scheduledAt, longMonth: true),
                subtitle: doctor.specialty,
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.verified_user_rounded,
                title: 'Durum: pending',
                subtitle: 'Backend tarafinda POST /appointments cagrilacak',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Vazgec'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Randevu Al'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (shouldBook != true) {
      return;
    }

    try {
      final appointment = await provider.bookAppointment(doctor);

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Randevu olusturuldu. Kod: #${appointment.id}, durum: ${appointment.status}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  DateTime _nextAppointmentDate(int doctorId) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day + 1,
      10 + (doctorId % 5),
    );
  }

  String _formatAppointmentDate(
    DateTime date, {
    bool longMonth = false,
  }) {
    const shortMonths = [
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
    const longMonths = [
      'Ocak',
      'Subat',
      'Mart',
      'Nisan',
      'Mayis',
      'Haziran',
      'Temmuz',
      'Agustos',
      'Eylul',
      'Ekim',
      'Kasim',
      'Aralik',
    ];

    final monthNames = longMonth ? longMonths : shortMonths;
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day ${monthNames[date.month - 1]} ${date.year}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FC),
          appBar: AppBar(
            title: const Text('Telemedicine Mobile'),
            actions: [
              IconButton(
                tooltip: 'Yenile',
                onPressed: provider.isBusy
                    ? null
                    : () => provider.refreshHomeData().catchError((_) {}),
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                tooltip: 'Cikis yap',
                onPressed: provider.clearSession,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: provider.refreshHomeData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2A85FF),
                        Color(0xFF6AB1FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332A85FF),
                        blurRadius: 28,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hos geldin ${user?.fullName ?? ''}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Bugun uygun doktorlari inceleyip yeni bir gorusme planlayabilirsin.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFEAF4FF),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _StatChip(
                            label: '${provider.doctors.length} doktor',
                            icon: Icons.groups_rounded,
                          ),
                          _StatChip(
                            label: '${provider.appointments.length} randevu',
                            icon: Icons.calendar_today_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Doktorlar',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10233F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Backend\'den gelen gercek liste asagida yer aliyor.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5D7290),
                  ),
                ),
                const SizedBox(height: 18),
                if (provider.isLoadingDoctors && provider.doctors.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (provider.doctors.isEmpty)
                  const _EmptyState(
                    title: 'Doktor listesi bos',
                    subtitle: 'Backend tarafindan henuz doktor verisi donmedi.',
                  )
                else
                  ...provider.doctors.map(
                    (doctor) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DoctorCard(
                        doctor: doctor,
                        onTap: provider.isBookingAppointment
                            ? () {}
                            : () => _handleDoctorTap(doctor),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Randevularim',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10233F),
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.isLoadingAppointments &&
                    provider.appointments.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (provider.appointments.isEmpty)
                  const _EmptyState(
                    title: 'Henuz randevu yok',
                    subtitle: 'Bir doktor kartina dokunarak ilk randevunu olustur.',
                  )
                else
                  ...provider.appointments.map(
                    (appointment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AppointmentCard(appointment: appointment),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (appointment.status) {
      'paid' => const Color(0xFF1AA06D),
      'completed' => const Color(0xFF2A85FF),
      'cancelled' => const Color(0xFFE15C64),
      _ => const Color(0xFFF59E0B),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.doctorName ?? 'Doktor bilgisi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10233F),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(31),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  appointment.status,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            appointment.specialty ?? 'Brans bilgisi yok',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5D7290),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: Color(0xFF2A85FF),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _formatCompactDate(appointment.appointmentDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF364A63),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.payments_rounded,
                color: Color(0xFF2A85FF),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                appointment.paymentStatus ? 'Odeme onayli' : 'Odeme bekliyor',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF364A63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCompactDate(DateTime date) {
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

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2A85FF).withAlpha(31),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2A85FF)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10233F),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5D7290),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2A85FF).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF2A85FF),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10233F),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5D7290),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
