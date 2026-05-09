import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splukk/core/app_messages.dart';
import 'package:splukk/core/l10n/language_picker_sheet.dart';
import 'package:splukk/core/l10n/locale_keys.dart';
import 'package:splukk/core/utils/exit_dialog.dart';
import 'package:splukk/core/utils/auth_error_resolver.dart';

import '../../shell/presentation/main_shell_page.dart';
import '../../../core/router/app_router.gr.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../auth/presentation/widgets/auth_wizard_widget.dart';
import 'widgets/settings_tile.dart';

// ─── Light palette ──────────────────────────────────────────────────────────
const _kBg = Color(0xFFF8FAFC);
const _kCard = Colors.white;
const _kGreen = Color(0xFF4CAF50);
const _kGreenDark = Color(0xFF388E3C);
const _kTextPrim = Color(0xFF1E293B);
const _kTextSec = Color(0xFF64748B);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void dispose() {
    super.dispose();
  }





  // ─── SIGNED IN VIEW ───────────────────────────────────────────────────────
  Widget _buildSignedIn(BuildContext context, AuthState state) {
    final profile = state.profile!;
    final isFarmer = profile.role == UserRole.farmer;
    final name = profile.displayLabel;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Avatar header ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isFarmer
                            ? [const Color(0xFFFF9800), const Color(0xFFE65100)]
                            : [_kGreen, _kGreenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isFarmer ? const Color(0xFFFF9800) : _kGreen)
                              .withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: profile.logoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              profile.logoUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
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
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isFarmer ? const Color(0xFFFF9800) : _kGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: _kCard, width: 2.5),
                      ),
                      child: Icon(
                        isFarmer
                            ? Icons.agriculture_rounded
                            : Icons.person_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: _kTextPrim,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.phone,
                style: const TextStyle(
                  color: _kTextSec,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _kTextSec,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isFarmer ? const Color(0xFFFF9800) : _kGreen)
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isFarmer ? const Color(0xFFFF9800) : _kGreen)
                        .withOpacity(0.2),
                  ),
                ),
                child: Text(
                  isFarmer
                      ? LocaleKeys.profile_farmer_badge.tr(context: context)
                      : LocaleKeys.profile_consumer_badge.tr(context: context),
                  style: TextStyle(
                    color: isFarmer ? const Color(0xFFE65100) : _kGreenDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Farmer section ─────────────────────────────────────────────────
        if (isFarmer) ...[
          SettingsSection(
            tiles: [
              if (profile.farmLocationSummary != null)
                SettingsTile(
                  icon: Icons.location_on_rounded,
                  label: profile.farmLocationSummary!,
                  iconColor: const Color(0xFF007AFF),
                  showDivider: profile.alternativePhone != null,
                  onTap: () {},
                ),
              if (profile.alternativePhone != null &&
                  profile.alternativePhone!.isNotEmpty)
                SettingsTile(
                  icon: Icons.phone_android_rounded,
                  label: profile.alternativePhone!,
                  iconColor: const Color(0xFF34C759),
                  showDivider: false,
                  onTap: () {},
                ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsSection(
            tiles: [
              SettingsTile(
                icon: Icons.dashboard_rounded,
                label: LocaleKeys.profile_farmer_dashboard.tr(context: context),
                iconColor: const Color(0xFFFF9500),
                onTap: () => context.router.push(const FarmerDashboardRoute()),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // ── Account section ────────────────────────────────────────────────
        SettingsSection(
          header: LocaleKeys.profile_section_account.tr(context: context),
          tiles: [
            SettingsTile(
              icon: Icons.notifications_rounded,
              label: LocaleKeys.profile_notifications.tr(context: context),
              iconColor: const Color(0xFFFF3B30),
              onTap: () => showAppSnackBar(context, LocaleKeys.profile_coming_soon.tr(context: context)),
            ),
            SettingsTile(
              icon: Icons.lock_rounded,
              label: LocaleKeys.profile_security.tr(context: context),
              iconColor: const Color(0xFF34C759),
              onTap: () => showAppSnackBar(context, LocaleKeys.profile_coming_soon.tr(context: context)),
            ),
            SettingsTile(
              icon: Icons.privacy_tip_rounded,
              label: LocaleKeys.profile_privacy.tr(context: context),
              iconColor: const Color(0xFF5AC8FA),
              showDivider: false,
              onTap: () => showAppSnackBar(context, LocaleKeys.profile_coming_soon.tr(context: context)),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Content section ────────────────────────────────────────────────
        SettingsSection(
          header: LocaleKeys.profile_section_content.tr(context: context),
          tiles: [
            SettingsTile(
              icon: Icons.favorite_rounded,
              label: LocaleKeys.profile_favorites.tr(context: context),
              iconColor: const Color(0xFFFF2D55),
              onTap: () => showAppSnackBar(context, LocaleKeys.profile_coming_soon.tr(context: context)),
            ),
            SettingsTile(
              icon: Icons.photo_library_rounded,
              label: LocaleKeys.profile_media.tr(context: context),
              iconColor: const Color(0xFF5856D6),
              showDivider: false,
              onTap: () => showAppSnackBar(context, LocaleKeys.profile_coming_soon.tr(context: context)),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── App section ────────────────────────────────────────────────────
        SettingsSection(
          header: LocaleKeys.profile_section_app.tr(context: context),
          tiles: [
            SettingsTile(
              icon: Icons.palette_rounded,
              label: LocaleKeys.profile_appearance.tr(context: context),
              iconColor: const Color(0xFFAF52DE),
              onTap: () => showAppSnackBar(context, LocaleKeys.profile_coming_soon.tr(context: context)),
            ),
            SettingsTile(
              icon: Icons.language_rounded,
              label: LocaleKeys.profile_language.tr(context: context),
              iconColor: const Color(0xFF007AFF),
              onTap: () => showLanguagePickerSheet(context),
            ),
            SettingsTile(
              icon: Icons.help_rounded,
              label: LocaleKeys.profile_help.tr(context: context),
              iconColor: const Color(0xFFFF9500),
              onTap: () => showAppSnackBar(context, LocaleKeys.profile_coming_soon.tr(context: context)),
            ),
            SettingsTile(
              icon: Icons.info_rounded,
              label: LocaleKeys.profile_about.tr(context: context),
              iconColor: const Color(0xFF8E8E93),
              showDivider: false,
              onTap: () => showAppSnackBar(context, 'Splukk v1.0'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Logout ─────────────────────────────────────────────────────────
        SettingsSection(
          tiles: [
            SettingsTile(
              icon: Icons.logout_rounded,
              label: LocaleKeys.profile_logout.tr(context: context),
              iconColor: const Color(0xFFFF3B30),
              showDivider: false,
              trailing: const SizedBox.shrink(),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      LocaleKeys.profile_logout_confirm_title.tr(context: context),
                      style: const TextStyle(
                        color: _kTextPrim,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      LocaleKeys.profile_logout_confirm_body.tr(context: context),
                      style: const TextStyle(color: _kTextSec),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          LocaleKeys.profile_cancel.tr(context: context),
                          style: const TextStyle(
                            color: _kTextSec,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          LocaleKeys.profile_logout.tr(context: context),
                          style: const TextStyle(
                            color: Color(0xFFFF3B30),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.nav_profile.tr(context: context),
          style: const TextStyle(
            color: _kTextPrim,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leadingWidth: 80,
        leading: null,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.authenticated &&
                  state.profile != null) {
                return IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: _kGreen,
                    size: 24,
                  ),
                  onPressed: () {
                    context.router.push(
                      EditProfileRoute(profile: state.profile!),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Builder(
        builder: (ctx) {
          final isActive = ActiveTabProvider.of(ctx) == 2;
          return PopScope(
            canPop: !isActive,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || !isActive) return;
              if (didPop || !isActive) return;
              final exit = await showExitConfirmationDialog(ctx);
              if (exit && ctx.mounted) SystemNavigator.pop();
            },
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (ctx, state) {
                if (state.status == AuthStatus.failure &&
                    state.errorMessage != null) {
                  final msg = resolveAuthErrorMessage(state.errorMessage!, ctx);
                  showAppSnackBar(ctx, msg, isError: true);
                }
              },
              builder: (ctx, state) {
                Widget body;
                if (state.status == AuthStatus.authenticated &&
                    state.profile != null) {
                  body = _buildSignedIn(ctx, state);
                } else {
                  body = const AuthWizardWidget();
                }
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child:
                        (state.status == AuthStatus.authenticated &&
                            state.profile != null)
                        ? body
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: _kCard,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 30,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: body,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
