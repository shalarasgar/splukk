import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/locale_keys.dart';
import '../../../../core/di/dependencies.dart';
import '../../../../core/services/link_launcher_service.dart';
import '../../../auth/domain/auth_domain.dart';
import '../widgets/settings_tile.dart';
import 'public_profile_bloc.dart';

@RoutePage()
class FarmerPublicProfilePage extends StatelessWidget {
  final String farmerUid;

  const FarmerPublicProfilePage({super.key, required this.farmerUid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PublicProfileBloc>()..add(PublicProfileLoaded(farmerUid)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
            onPressed: () => context.router.back(),
          ),
          centerTitle: true,
          title: Text(
            LocaleKeys.farmer_profile_title.tr(context: context),
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<PublicProfileBloc, PublicProfileState>(
          builder: (context, state) {
            if (state.status == PublicProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
            }
            if (state.status == PublicProfileStatus.failure) {
              return Center(child: Text(state.errorMessage ?? LocaleKeys.farmer_profile_error.tr(context: context)));
            }
            if (state.status == PublicProfileStatus.success && state.profile != null) {
              return _buildProfileContent(context, state.profile!);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    final launcher = sl<LinkLauncherService>();
    const kGreen = Color(0xFF4CAF50);
    const kTextPrim = Color(0xFF1E293B);
    const kTextSec = Color(0xFF64748B);
    const kCard = Colors.white;

    final name = profile.displayLabel;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFE65100)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: profile.logoUrl != null
                      ? ClipOval(child: Image.network(profile.logoUrl!, fit: BoxFit.cover))
                      : Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    color: kTextPrim,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      profile.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kTextSec, fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Farm Details
          _buildSectionTitle(LocaleKeys.farmer_profile_info.tr(context: context)),
          SettingsSection(
            tiles: [
              if (profile.farmLocationSummary != null)
                SettingsTile(
                  icon: Icons.location_on_rounded,
                  label: profile.farmLocationSummary!,
                  iconColor: const Color(0xFF007AFF),
                  showDivider: profile.phone.isNotEmpty || profile.alternativePhone != null,
                  onTap: () {
                    // Open in maps if possible, or just ignore if it's just text
                  },
                ),
              if (profile.phone.isNotEmpty)
                SettingsTile(
                  icon: Icons.phone_rounded,
                  label: profile.phone,
                  iconColor: kGreen,
                  showDivider: profile.alternativePhone != null,
                  onTap: () => _showPhoneActions(context, profile.phone),
                ),
              if (profile.alternativePhone != null && profile.alternativePhone!.isNotEmpty)
                SettingsTile(
                  icon: Icons.phone_android_rounded,
                  label: profile.alternativePhone!,
                  iconColor: const Color(0xFF34C759),
                  showDivider: false,
                  onTap: () => _showPhoneActions(context, profile.alternativePhone!),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Social & Links
          if (profile.socialInstagram != null || profile.socialFacebook != null) ...[
            _buildSectionTitle(LocaleKeys.farmer_profile_social.tr(context: context)),
            SettingsSection(
              tiles: [
                if (profile.socialInstagram != null && profile.socialInstagram!.isNotEmpty)
                  SettingsTile(
                    icon: Icons.camera_alt_rounded,
                    label: profile.socialInstagram!,
                    iconColor: const Color(0xFFE1306C),
                    showDivider: profile.socialFacebook != null,
                    onTap: () => launcher.openInstagram(profile.socialInstagram!),
                  ),
                if (profile.socialFacebook != null && profile.socialFacebook!.isNotEmpty)
                  SettingsTile(
                    icon: Icons.facebook_rounded,
                    label: profile.socialFacebook!,
                    iconColor: const Color(0xFF1877F2),
                    showDivider: false,
                    onTap: () => launcher.openFacebook(profile.socialFacebook!),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Footer info
          Center(
            child: Text(
              LocaleKeys.farmer_profile_member.tr(context: context),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showPhoneActions(BuildContext context, String phone) {
    final launcher = sl<LinkLauncherService>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                phone,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.phone_rounded, color: Colors.green),
              title: Text(LocaleKeys.farmer_profile_call.tr(context: context)),
              onTap: () {
                Navigator.pop(context);
                launcher.makeCall(phone);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message_rounded, color: Colors.blue),
              title: Text(LocaleKeys.farmer_profile_send_sms.tr(context: context)),
              onTap: () {
                Navigator.pop(context);
                launcher.sendSms(phone);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366)),
              title: const Text('WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                launcher.openWhatsApp(phone);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
