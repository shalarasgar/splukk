import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splukk/core/di/dependencies.dart';
import 'package:splukk/core/services/media_picker_service.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/l10n/locale_keys.dart';
import 'package:splukk/core/widgets/premium_button.dart';
import 'package:splukk/core/widgets/premium_text_field.dart';

import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../../core/utils/auth_error_resolver.dart';

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
    final path = await sl<MediaPickerService>().pickImage();
    if (path != null) {
      setState(() => _localLogoPath = path);
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
            SnackBar(
              content: Text(
                LocaleKeys.edit_profile_success.tr(context: context),
              ),
            ),
          );
          context.router.back();
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resolveAuthErrorMessage(
                  state.errorMessage ?? LocaleKeys.edit_profile_error,
                  context,
                ),
              ),
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
          title: Text(
            LocaleKeys.edit_profile_title.tr(context: context),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _save,
              child: Text(
                LocaleKeys.edit_profile_save.tr(context: context),
                style: const TextStyle(
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
                            ? Image.file(
                                File(_localLogoPath!),
                                fit: BoxFit.cover,
                              )
                            : (widget.profile.logoUrl != null
                                  ? Image.network(
                                      widget.profile.logoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey.shade400,
                                    )),
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
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form
              _buildSectionTitle(
                LocaleKeys.edit_profile_section_basic.tr(context: context),
              ),
              PremiumTextField(
                controller: _nameController,
                label: isFarmer
                    ? LocaleKeys.edit_profile_farm_name.tr(context: context)
                    : LocaleKeys.edit_profile_full_name.tr(context: context),
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                controller: _bioController,
                label: isFarmer
                    ? LocaleKeys.edit_profile_farm_desc.tr(context: context)
                    : LocaleKeys.edit_profile_about_me.tr(context: context),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(
                LocaleKeys.edit_profile_section_contact.tr(context: context),
              ),
              PremiumTextField(
                controller: _altPhoneController,
                label: LocaleKeys.edit_profile_alt_phone.tr(context: context),
                keyboardType: TextInputType.phone,
                hint: LocaleKeys.auth_phone_hint.tr(context: context),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(
                LocaleKeys.edit_profile_section_social.tr(context: context),
              ),
              PremiumTextField(
                controller: _instaController,
                label: LocaleKeys.edit_profile_insta.tr(context: context),
                hint: '@username',
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                controller: _fbController,
                label: LocaleKeys.edit_profile_fb.tr(context: context),
              ),
              const SizedBox(height: 24),

              if (isFarmer) ...[
                _buildSectionTitle(
                  LocaleKeys.edit_profile_section_payment.tr(context: context),
                ),
                PremiumTextField(
                  controller: _ibanController,
                  label: LocaleKeys.edit_profile_iban.tr(context: context),
                  hint: 'NOXX XXXX XXXXXXX',
                ),
                const SizedBox(height: 32),
              ],

              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return PremiumButton(
                    text: LocaleKeys.edit_profile_save_changes.tr(
                      context: context,
                    ),
                    isLoading: state.status == AuthStatus.updating,
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
