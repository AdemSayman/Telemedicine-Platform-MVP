import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/main_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                Text(
                  'Profilim',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF10233F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(24),
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
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEAF3FF),
                          border: Border.all(
                            color: const Color(0xFFD8E8FF),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 46,
                          color: Color(0xFF2A85FF),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        user?.fullName ?? 'Hasta',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF10233F),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.phoneNumber ?? '-',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Container(
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
                    children: const [
                      _ProfileMenuTile(
                        icon: Icons.badge_rounded,
                        title: 'Kisisel Bilgilerim',
                        subtitle: 'Kimlik ve iletisim detaylarini gor',
                      ),
                      Divider(height: 1, indent: 20, endIndent: 20),
                      _ProfileMenuTile(
                        icon: Icons.monitor_heart_rounded,
                        title: 'Saglik Gecmisim',
                        subtitle: 'Gecmis gorusme ve ozet kayitlari incele',
                      ),
                      Divider(height: 1, indent: 20, endIndent: 20),
                      _ProfileMenuTile(
                        icon: Icons.notifications_active_rounded,
                        title: 'Bildirim Ayarlari',
                        subtitle: 'Hatirlatici ve uygulama bildirimlerini yonet',
                      ),
                      Divider(height: 1, indent: 20, endIndent: 20),
                      _ProfileMenuTile(
                        icon: Icons.support_agent_rounded,
                        title: 'Destek & Yardim',
                        subtitle: 'Canli destek ve sik sorulan sorular',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oturum Islemleri',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF7F1D1D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guvenli cikis yaptiginda aktif hasta oturumun temizlenir ve giris ekranina donersin.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9F1239),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _logout(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE15C64),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Cikis Yap'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout(BuildContext context) {
    final provider = context.read<MainProvider>();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    provider.clearSession();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Oturum kapatildi. Giris ekranina yonlendiriliyorsun.'),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF2A85FF)),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFF10233F),
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
