import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/main_provider.dart';
import 'tabs/doctor_appointments_tab.dart';
import 'tabs/doctor_home_tab.dart';
import 'tabs/doctor_patients_tab.dart';
import 'tabs/doctor_profile_tab.dart';

class DoctorMainScreen extends StatefulWidget {
  const DoctorMainScreen({super.key});

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
  int _selectedIndex = 0;

  static const _tabTitles = [
    'Genel Bakış',
    'Randevu Yönetimi',
    'Hastalarım',
    'Profilim',
  ];

  static const _tabIcons = [
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.people_rounded,
    Icons.settings_rounded,
  ];

  static const _tabs = [
    DoctorHomeTab(),
    DoctorAppointmentsTab(),
    DoctorPatientsTab(),
    DoctorProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();
    final currentTitle = _tabTitles[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(currentTitle),
        backgroundColor: const Color(0xFFF4F7FA),
        foregroundColor: const Color(0xFF10233F),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF2A85FF),
            onPressed: provider.refreshHomeData,
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2A85FF),
          unselectedItemColor: const Color(0xFF8B95A1),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: List.generate(
            _tabTitles.length,
            (index) => BottomNavigationBarItem(
              icon: Icon(_tabIcons[index]),
              label: _tabTitles[index],
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
