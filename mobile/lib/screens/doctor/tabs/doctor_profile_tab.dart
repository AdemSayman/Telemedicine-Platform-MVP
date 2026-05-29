import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/main_provider.dart';

class DoctorProfileTab extends StatefulWidget {
  const DoctorProfileTab({super.key});

  @override
  State<DoctorProfileTab> createState() => _DoctorProfileTabState();
}

class _DoctorProfileTabState extends State<DoctorProfileTab> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _experienceController;
  late final TextEditingController _hospitalController;
  late final TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<MainProvider>();
    final currentUser = provider.currentUser;

    _nameController = TextEditingController(text: currentUser?.fullName ?? '');
    _phoneController = TextEditingController(text: currentUser?.phoneNumber ?? '');
    _specialtyController = TextEditingController(text: provider.doctorSpecialty);
    _experienceController = TextEditingController(text: provider.doctorExperienceYears.toString());
    _hospitalController = TextEditingController(text: provider.doctorHospitalName);
    _bioController = TextEditingController(text: provider.doctorBiography);

    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _specialtyController.addListener(_onFormChanged);
    _experienceController.addListener(_onFormChanged);
    _hospitalController.addListener(_onFormChanged);
    _bioController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _phoneController.removeListener(_onFormChanged);
    _specialtyController.removeListener(_onFormChanged);
    _experienceController.removeListener(_onFormChanged);
    _hospitalController.removeListener(_onFormChanged);
    _bioController.removeListener(_onFormChanged);

    _nameController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _hospitalController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();
    final currentUser = provider.currentUser;
    final isSaving = provider.isUpdatingProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Profesyonel Profil',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF10233F),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        _resetForm(provider);
                      }
                    });
                  },
                  icon: Icon(
                    _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    color: const Color(0xFF2A85FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Buradan uzmanlık bilgilerini ve ayarlarını güncelleyebilirsin.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),
            _buildEditableField(
              _nameController,
              'Ad Soyad',
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ad Soyad boş geçilemez.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              _phoneController,
              'Telefon Numarası',
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Telefon numarası zorunludur.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              _specialtyController,
              'Uzmanlık Alanı',
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              _experienceController,
              'Deneyim Yılı',
              enabled: _isEditing,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              _hospitalController,
              'Hastane Adı',
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildBioField(enabled: _isEditing),
            const SizedBox(height: 24),
            if (_hasChanges)
              FilledButton(
                onPressed: isSaving ? null : () => _saveProfile(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2A85FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Ayarları Kaydet'),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _logout(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2A85FF),
                side: const BorderSide(color: Color(0xFFBED7F5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF10233F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7FAFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBioField({bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biyografi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF10233F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bioController,
          enabled: enabled,
          maxLines: 5,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7FAFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }

  void _saveProfile(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<MainProvider>();
    final messenger = ScaffoldMessenger.of(context);

    provider.updateUserProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    ).then((_) {
      provider.updateDoctorProfile(
        specialty: _specialtyController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text.trim()) ?? provider.doctorExperienceYears,
        hospitalName: _hospitalController.text.trim(),
        biography: _bioController.text.trim(),
      );
      setState(() {
        _isEditing = false;
        _hasChanges = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi')),
      );
    }).catchError((error) {
      messenger.showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    });
  }

  void _onFormChanged() {
    if (!_isEditing) {
      return;
    }
    setState(() {
      _hasChanges = true;
    });
  }

  void _resetForm(MainProvider provider) {
    final currentUser = provider.currentUser;
    _nameController.text = currentUser?.fullName ?? '';
    _phoneController.text = currentUser?.phoneNumber ?? '';
    _specialtyController.text = provider.doctorSpecialty;
    _experienceController.text = provider.doctorExperienceYears.toString();
    _hospitalController.text = provider.doctorHospitalName;
    _bioController.text = provider.doctorBiography;
    _hasChanges = false;
  }

  void _logout(BuildContext context) {
    final provider = context.read<MainProvider>();
    provider.clearSession();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Çıkış yapıldı.')),
    );
  }
}
