import 'package:flutter/material.dart';

import '../../models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availabilityBackground = doctor.isAvailable
        ? const Color(0xFFE6F6EE)
        : const Color(0xFFFBE7E9);
    final availabilityText = doctor.isAvailable
        ? const Color(0xFF237A52)
        : const Color(0xFFAA4E59);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF2A85FF),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.user.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10233F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialty,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5D7290),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: availabilityBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      doctor.isAvailable ? 'Musait' : 'Dolu',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: availabilityText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 18,
                      color: Color(0xFF2A85FF),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${doctor.experienceYears} yil deneyim',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF364A63),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    size: 18,
                    color: Color(0xFF2A85FF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    doctor.user.phoneNumber,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF364A63),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: doctor.isAvailable
                      ? const Color(0xFF2A85FF)
                      : const Color(0xFFCBD7E6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  doctor.isAvailable
                      ? 'Randevu simule et'
                      : 'Su an uygun degil',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
