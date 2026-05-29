import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/main_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+222');
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController(text: 'Genel');
  final _experienceController = TextEditingController(text: '3');
  String _selectedRole = 'patient';

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<MainProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await provider.login(
        phoneNumber: _phoneController.text.trim(),
        fullName: _nameController.text.trim(),
        role: _selectedRole,
        specialty: _selectedRole == 'doctor'
            ? _specialtyController.text.trim()
            : null,
        experienceYears: _selectedRole == 'doctor'
            ? int.tryParse(_experienceController.text.trim())
            : null,
      );

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Giris basarili. Hasta paneline yonlendiriliyorsun.'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEAF4FF),
              Color(0xFFF9FCFF),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Consumer<MainProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A85FF),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x332A85FF),
                                blurRadius: 28,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Guvende hissettiren online saglik deneyimi',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10233F),
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Telefon numaran ile hizli giris yap, uygun doktorlari gor ve randevunu aninda olustur.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF59708E),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x140F172A),
                                blurRadius: 40,
                                offset: Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedRole == 'doctor' ? 'Doktor Girisi' : 'Hasta Girisi',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF10233F),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ChoiceChip(
                                        label: const Text('Hasta'),
                                        selected: _selectedRole == 'patient',
                                        onSelected: (_) => setState(() {
                                          _selectedRole = 'patient';
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ChoiceChip(
                                        label: const Text('Doktor'),
                                        selected: _selectedRole == 'doctor',
                                        onSelected: (_) => setState(() {
                                          _selectedRole = 'doctor';
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Mauritania formatinda numara kullan: +222XXXXXXXX',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF70849E),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefon numarasi',
                                    hintText: '+22220000011',
                                    prefixIcon: Icon(Icons.phone_rounded),
                                  ),
                                  validator: (value) {
                                    final input = value?.trim() ?? '';
                                    final regex = RegExp(r'^\+222\d{8}$');

                                    if (input.isEmpty) {
                                      return 'Telefon numarasi bos birakilamaz.';
                                    }

                                    if (!regex.hasMatch(input)) {
                                      return 'Format +222 ile baslamali ve 8 rakam icermeli.';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Ad soyad',
                                    hintText: 'Opsiyonel, ilk kayitta kullanilir',
                                    prefixIcon: Icon(Icons.person_rounded),
                                  ),
                                ),
                                if (_selectedRole == 'doctor') ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _specialtyController,
                                    textCapitalization: TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Brans',
                                      hintText: 'Ornek: Dahiliye, Kardiyoloji',
                                      prefixIcon: Icon(Icons.work_rounded),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _experienceController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Deneyim yili',
                                      hintText: 'Ornek: 3',
                                      prefixIcon: Icon(Icons.timeline_rounded),
                                    ),
                                    validator: (value) {
                                      if (_selectedRole == 'doctor') {
                                        final parsed = int.tryParse(value?.trim() ?? '');
                                        if (parsed == null || parsed <= 0) {
                                          return 'Lütfen gecerli bir deneyim yili girin.';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: provider.isAuthenticating
                                        ? null
                                        : _submit,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      child: provider.isAuthenticating
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text('Giris Yap'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
