import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/doctor_model.dart';
import '../../providers/main_provider.dart';
import '../widgets/doctor_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: provider.refreshHomeData,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  Container(
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
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Hos geldin ${user?.fullName ?? ''}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Doktorlarini incele, uygun saatleri degerlendir ve saglik surecini tek yerden yonet.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFFEAF4FF),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _StatsCard(
                          title: 'Toplam Doktor',
                          value: provider.doctors.length.toString(),
                          icon: Icons.medical_services_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatsCard(
                          title: 'Randevularim',
                          value: provider.appointments.length.toString(),
                          icon: Icons.fact_check_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Doktor Listesi',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10233F),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Yenile',
                        onPressed: provider.isBusy
                            ? null
                            : () => provider.refreshHomeData().catchError((_) {}),
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  Text(
                    'Gercek backend verileri ile senkronize uzman listesi.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (provider.isLoadingDoctors && provider.doctors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.doctors.isEmpty)
                    const _EmptyDoctorsState()
                  else
                    ...provider.doctors.map(
                      (doctor) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: DoctorCard(
                          doctor: doctor,
                          onTap: provider.isBookingAppointment
                              ? () {}
                              : () => _showBookingSheet(context, doctor),
                        ),
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

  Future<void> _showBookingSheet(BuildContext context, DoctorModel doctor) async {
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final scheduledAt = _nextAppointmentDate(doctor.id);

        return Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E4F2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Randevu Simulasyonu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF10233F),
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                '${doctor.user.fullName} ile ilk uygun gorusme asagidaki slot icin planlanacak.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 20),
              _SheetInfoTile(
                icon: Icons.calendar_month_rounded,
                title: _formatLongDate(scheduledAt),
                subtitle: 'Tahmini randevu tarihi',
              ),
              const SizedBox(height: 12),
              _SheetInfoTile(
                icon: Icons.medical_information_rounded,
                title: doctor.specialty,
                subtitle: '${doctor.experienceYears} yil deneyimli uzman',
              ),
              const SizedBox(height: 12),
              _SheetInfoTile(
                icon: Icons.videocam_rounded,
                title: 'Video gorusme hazir',
                subtitle: 'Backend uzerinden POST /appointments tetiklenecek',
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

      if (!context.mounted) {
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
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
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
      0,
    );
  }

  String _formatLongDate(DateTime date) {
    const months = [
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

    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
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
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF10233F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetInfoTile extends StatelessWidget {
  const _SheetInfoTile({
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
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
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
                        color: const Color(0xFF10233F),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
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

class _EmptyDoctorsState extends StatelessWidget {
  const _EmptyDoctorsState();

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
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.medical_information_rounded,
              size: 34,
              color: Color(0xFF2A85FF),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Doktor listesi su an bos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Backend tarafindan veri geldikce burada uygun uzmanlar listelenecek.',
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
