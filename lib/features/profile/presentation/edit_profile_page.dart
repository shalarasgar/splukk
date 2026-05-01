import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_text_field.dart';

@RoutePage()
class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _altPhoneController;
  late TextEditingController _instaController;
  late TextEditingController _fbController;
  late TextEditingController _ibanController;

  String? _localLogoPath;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(
      text: p.role == UserRole.farmer ? p.farmName : p.fullName,
    );
    _bioController = TextEditingController(text: p.bio);
    _altPhoneController = TextEditingController(text: p.alternativePhone);
    _instaController = TextEditingController(text: p.socialInstagram);
    _fbController = TextEditingController(text: p.socialFacebook);
    _ibanController = TextEditingController(text: p.bankIban);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _altPhoneController.dispose();
    _instaController.dispose();
    _fbController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _localLogoPath = image.path);
    }
  }

  void _save() {
    final p = widget.profile;
    final isFarmer = p.role == UserRole.farmer;

    final updatedProfile = p.copyWith(
      fullName: isFarmer ? null : _nameController.text.trim(),
      farmName: isFarmer ? _nameController.text.trim() : null,
      bio: _bioController.text.trim(),
      alternativePhone: _altPhoneController.text.trim(),
      socialInstagram: _instaController.text.trim(),
      socialFacebook: _fbController.text.trim(),
      bankIban: _ibanController.text.trim(),
    );

    context.read<AuthBloc>().add(
      AuthProfileUpdated(updatedProfile, logoLocalPath: _localLogoPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFarmer = widget.profile.role == UserRole.farmer;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil başarıyla güncellendi')),
          );
          context.router.back();
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => context.router.back(),
          ),
          title: const Text(
            'Profili Düzenle',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                'Kaydet',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar edit
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _localLogoPath != null
                            ? Image.file(File(_localLogoPath!), fit: BoxFit.cover)
                            : (widget.profile.logoUrl != null
                                ? Image.network(widget.profile.logoUrl!,
                                    fit: BoxFit.cover)
                                : Icon(Icons.person,
                                    size: 60, color: Colors.grey.shade400)),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4CAF50),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form
              _buildSectionTitle('Temel Bilgiler'),
              PremiumTextField(
                controller: _nameController,
                label: isFarmer ? 'Çiftlik Adı' : 'Ad Soyad',
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                controller: _bioController,
                label: isFarmer ? 'Çiftlik Açıklaması' : 'Hakkımda',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('İletişim'),
              PremiumTextField(
                controller: _altPhoneController,
                label: 'Ek Telefon Numarası',
                keyboardType: TextInputType.phone,
                hint: '+47XXXXXXXX',
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Sosyal Medya'),
              PremiumTextField(
                controller: _instaController,
                label: 'Instagram Kullanıcı Adı',
                hint: '@kullaniciadi',
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                controller: _fbController,
                label: 'Facebook Sayfa Linki',
              ),
              const SizedBox(height: 24),

              if (isFarmer) ...[
                _buildSectionTitle('Ödeme Bilgileri'),
                PremiumTextField(
                  controller: _ibanController,
                  label: 'IBAN',
                  hint: 'NOXX XXXX XXXXXXX',
                ),
                const SizedBox(height: 32),
              ],

              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return PremiumButton(
                    text: 'Değişiklikleri Kaydet',
                    isLoading: state.status == AuthStatus.verifyingPhone,
                    onPressed: _save,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
