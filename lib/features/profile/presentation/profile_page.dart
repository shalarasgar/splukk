import 'package:auto_route/auto_route.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splukk/core/app_messages.dart';
import 'package:splukk/core/utils/exit_dialog.dart';

import '../../shell/presentation/main_shell_page.dart';
import '../../../core/router/app_router.gr.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_text_field.dart';
import 'widgets/settings_tile.dart';

// ─── Light palette ──────────────────────────────────────────────────────────
const _kBg         = Color(0xFFF8FAFC);
const _kCard       = Colors.white;
const _kGreen      = Color(0xFF4CAF50);
const _kGreenDark  = Color(0xFF388E3C);
const _kTextPrim   = Color(0xFF1E293B);
const _kTextSec    = Color(0xFF64748B);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _phoneController      = TextEditingController();
  final _codeController       = TextEditingController();
  final _fullNameController   = TextEditingController();
  final _farmNameController   = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _farmStreetController = TextEditingController();
  final _farmStreetNumberController = TextEditingController();

  AuthFlowIntent? _flow;
  String? _logoPath;
  String? _farmCountry, _farmState, _farmCity;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _fullNameController.dispose();
    _farmNameController.dispose();
    _postalCodeController.dispose();
    _farmStreetController.dispose();
    _farmStreetNumberController.dispose();
    super.dispose();
  }

  void _clearFarmerDraft() {
    _farmCountry = _farmState = _farmCity = null;
    _postalCodeController.clear();
    _farmStreetController.clear();
    _farmStreetNumberController.clear();
  }

  Future<void> _pickLogo() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _logoPath = file.path);
  }

  void _cancelFlow() {
    context.read<AuthBloc>().add(const AuthFlowCancelled());
    setState(() { _flow = null; _logoPath = null; _clearFarmerDraft(); });
  }

  void _sendSms(BuildContext ctx) {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) { showAppSnackBar(ctx, 'Telefon numarası girin'); return; }
    final flow = _flow; if (flow == null) return;
    switch (flow) {
      case AuthFlowIntent.login:
        ctx.read<AuthBloc>().add(AuthPhoneRequested(phone, intent: AuthFlowIntent.login));
      case AuthFlowIntent.registerConsumer:
        final name = _fullNameController.text.trim();
        if (name.isEmpty) { showAppSnackBar(ctx, 'Ad soyad girin'); return; }
        ctx.read<AuthBloc>().add(AuthPhoneRequested(phone, intent: AuthFlowIntent.registerConsumer, fullName: name));
      case AuthFlowIntent.registerFarmer:
        final farmName = _farmNameController.text.trim();
        final country  = _farmCountry?.trim() ?? '';
        final state    = _farmState?.trim()   ?? '';
        final city     = _farmCity?.trim()    ?? '';
        final postal   = _postalCodeController.text.trim();
        final street   = _farmStreetController.text.trim();
        final streetNo = _farmStreetNumberController.text.trim();
        if (farmName.isEmpty || country.isEmpty || state.isEmpty || city.isEmpty || postal.isEmpty) {
          showAppSnackBar(ctx, 'Çiftlik adı, ülke, eyalet, şehir ve posta kodu zorunludur'); return;
        }
        if (street.isEmpty || streetNo.isEmpty) {
          showAppSnackBar(ctx, 'Cadde ve bina/kapı numarası zorunludur'); return;
        }
        ctx.read<AuthBloc>().add(AuthPhoneRequested(phone,
          intent: AuthFlowIntent.registerFarmer,
          farmName: farmName, farmCountry: country, farmState: state,
          farmCity: city, farmPostalCode: postal,
          farmStreet: street, farmStreetNumber: streetNo,
          logoLocalPath: _logoPath));
    }
  }

  // ─── AUTH HUB ─────────────────────────────────────────────────────────────
  Widget _buildHub(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_kGreen, _kGreenDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: _kGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        Text('Hoş Geldiniz', textAlign: TextAlign.center,
          style: const TextStyle(color: _kTextPrim, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Hesabınıza giriş yapın veya yeni bir hesap oluşturun.', textAlign: TextAlign.center,
          style: const TextStyle(color: _kTextSec, fontSize: 15)),
        const SizedBox(height: 32),
        _hubButton(Icons.login_rounded, 'Giriş Yap', _kGreen,
          () => setState(() => _flow = AuthFlowIntent.login)),
        const SizedBox(height: 12),
        _hubButton(Icons.person_add_rounded, 'Müşteri Olarak Kayıt Ol',
          const Color(0xFF2196F3),
          () => setState(() => _flow = AuthFlowIntent.registerConsumer)),
        const SizedBox(height: 12),
        _hubButton(Icons.agriculture_rounded, 'Çiftlik Sahibi Olarak Kayıt Ol',
          const Color(0xFFFF9800),
          () => setState(() => _flow = AuthFlowIntent.registerFarmer)),
      ],
    );
  }

  Widget _hubButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label,
                style: TextStyle(color: color.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── PHONE STEP ───────────────────────────────────────────────────────────
  Widget _buildPhoneStep(BuildContext context, AuthState state) {
    final loading = state.status == AuthStatus.verifyingPhone;
    final flow = _flow!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kTextPrim, size: 20),
            onPressed: _cancelFlow,
          ),
          Text(flow == AuthFlowIntent.login ? 'Giriş Yap' : 'Kayıt Ol',
            style: const TextStyle(color: _kTextPrim, fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 24),
        if (flow == AuthFlowIntent.registerConsumer) ...[
          PremiumTextField(controller: _fullNameController, textCapitalization: TextCapitalization.words, label: 'Ad Soyad'),
          const SizedBox(height: 16),
        ],
        if (flow == AuthFlowIntent.registerFarmer) ...[
          PremiumTextField(controller: _farmNameController, label: 'Çiftlik Adı'),
          const SizedBox(height: 16),
          _locationPicker(),
          const SizedBox(height: 16),
          PremiumTextField(controller: _postalCodeController, keyboardType: TextInputType.text, textCapitalization: TextCapitalization.characters, label: 'Posta Kodu'),
          const SizedBox(height: 16),
          PremiumTextField(controller: _farmStreetController, textCapitalization: TextCapitalization.words, label: 'Cadde'),
          const SizedBox(height: 16),
          PremiumTextField(controller: _farmStreetNumberController, label: 'Bina / Kapı Numarası'),
          const SizedBox(height: 16),
          _logoPicker(),
          const SizedBox(height: 16),
        ],
        PremiumTextField(controller: _phoneController, keyboardType: TextInputType.phone, label: 'Telefon', hint: '+47XXXXXXXX'),
        const SizedBox(height: 32),
        PremiumButton(text: 'SMS Kodu Gönder', isLoading: loading, onPressed: () => _sendSms(context)),
      ],
    );
  }

  Widget _locationPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CSCPicker(
        layout: Layout.vertical,
        flagState: CountryFlag.DISABLE,
        defaultCountry: CscCountry.Norway,
        countryDropdownLabel: 'Ülke',
        stateDropdownLabel: 'Eyalet',
        cityDropdownLabel: 'Şehir',
        countrySearchPlaceholder: 'Ülke ara',
        stateSearchPlaceholder: 'Eyalet ara',
        citySearchPlaceholder: 'Şehir ara',
        dropdownDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Colors.transparent,
        ),
        disabledDropdownDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Colors.transparent,
        ),
        onCountryChanged: (v) => setState(() => _farmCountry = v),
        onStateChanged: (v) => setState(() => _farmState = v),
        onCityChanged: (v) => setState(() => _farmCity = v),
      ),
    );
  }

  Widget _logoPicker() {
    return InkWell(
      onTap: _pickLogo,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          Icon(Icons.image_outlined, color: _logoPath != null ? _kGreen : Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(
            _logoPath == null ? 'Logo ekle (isteğe bağlı)' : 'Logo seçildi ✓',
            style: TextStyle(color: _logoPath != null ? _kGreen : Colors.grey.shade700),
          )),
          if (_logoPath != null) const Icon(Icons.check_circle, color: _kGreen, size: 18),
        ]),
      ),
    );
  }

  // ─── SMS CODE STEP ────────────────────────────────────────────────────────
  Widget _buildCodeStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kTextPrim, size: 20),
            onPressed: _cancelFlow,
          ),
          const Text('SMS Doğrulama', style: TextStyle(color: _kTextPrim, fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        const Text('Telefonunuza gönderilen 6 haneli kodu girin',
          style: TextStyle(color: _kTextSec, fontSize: 15)),
        const SizedBox(height: 32),
        PremiumTextField(controller: _codeController, label: 'Doğrulama Kodu', keyboardType: TextInputType.number),
        const SizedBox(height: 32),
        PremiumButton(text: 'Doğrula ve Tamamla', onPressed: () {
          context.read<AuthBloc>().add(AuthSmsCodeSubmitted(_codeController.text));
        }),
      ],
    );
  }

  // ─── SIGNED IN VIEW ───────────────────────────────────────────────────────
  Widget _buildSignedIn(BuildContext context, AuthState state) {
    final profile  = state.profile!;
    final isFarmer = profile.role == UserRole.farmer;
    final name     = profile.displayLabel;
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(children: [
            Stack(
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isFarmer
                        ? [const Color(0xFFFF9800), const Color(0xFFE65100)]
                        : [_kGreen, _kGreenDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    boxShadow: [BoxShadow(
                      color: (isFarmer ? const Color(0xFFFF9800) : _kGreen).withOpacity(0.3),
                      blurRadius: 16, offset: const Offset(0, 6),
                    )],
                  ),
                  child: profile.logoUrl != null
                    ? ClipOval(child: Image.network(profile.logoUrl!, fit: BoxFit.cover))
                    : Center(child: Text(initials,
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isFarmer ? const Color(0xFFFF9800) : _kGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: _kCard, width: 2.5),
                    ),
                    child: Icon(
                      isFarmer ? Icons.agriculture_rounded : Icons.person_rounded,
                      size: 14, color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(name,
              style: const TextStyle(color: _kTextPrim, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(profile.phone,
              style: const TextStyle(color: _kTextSec, fontSize: 15, fontWeight: FontWeight.w500)),
            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  profile.bio!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _kTextSec, fontSize: 14, height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: (isFarmer ? const Color(0xFFFF9800) : _kGreen).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isFarmer ? const Color(0xFFFF9800) : _kGreen).withOpacity(0.2)),
              ),
              child: Text(
                isFarmer ? '🌾 Çiftçi' : '🛒 Tüketici',
                style: TextStyle(
                  color: isFarmer ? const Color(0xFFE65100) : _kGreenDark,
                  fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Farmer section ─────────────────────────────────────────────────
        if (isFarmer) ...[
          SettingsSection(tiles: [
            if (profile.farmLocationSummary != null)
              SettingsTile(
                icon: Icons.location_on_rounded,
                label: profile.farmLocationSummary!,
                iconColor: const Color(0xFF007AFF),
                showDivider: profile.alternativePhone != null,
                onTap: () {},
              ),
            if (profile.alternativePhone != null && profile.alternativePhone!.isNotEmpty)
              SettingsTile(
                icon: Icons.phone_android_rounded,
                label: profile.alternativePhone!,
                iconColor: const Color(0xFF34C759),
                showDivider: false,
                onTap: () {},
              ),
          ]),
          const SizedBox(height: 16),
          SettingsSection(tiles: [
            SettingsTile(
              icon: Icons.dashboard_rounded,
              label: 'Çiftçi Paneli',
              iconColor: const Color(0xFFFF9500),
              onTap: () => context.router.push(const FarmerDashboardRoute()),
              showDivider: false,
            ),
          ]),
          const SizedBox(height: 24),
        ],

        // ── Account section ────────────────────────────────────────────────
        SettingsSection(
          header: 'Hesap',
          tiles: [
            SettingsTile(
              icon: Icons.notifications_rounded,
              label: 'Bildirimler',
              iconColor: const Color(0xFFFF3B30),
              onTap: () => showAppSnackBar(context, 'Çok yakında!'),
            ),
            SettingsTile(
              icon: Icons.lock_rounded,
              label: 'Güvenlik',
              iconColor: const Color(0xFF34C759),
              onTap: () => showAppSnackBar(context, 'Çok yakında!'),
            ),
            SettingsTile(
              icon: Icons.privacy_tip_rounded,
              label: 'Gizlilik',
              iconColor: const Color(0xFF5AC8FA),
              showDivider: false,
              onTap: () => showAppSnackBar(context, 'Çok yakında!'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Content section ────────────────────────────────────────────────
        SettingsSection(
          header: 'İçerik',
          tiles: [
            SettingsTile(
              icon: Icons.favorite_rounded,
              label: 'Favoriler',
              iconColor: const Color(0xFFFF2D55),
              onTap: () => showAppSnackBar(context, 'Çok yakında!'),
            ),
            SettingsTile(
              icon: Icons.photo_library_rounded,
              label: 'Medya',
              iconColor: const Color(0xFF5856D6),
              showDivider: false,
              onTap: () => showAppSnackBar(context, 'Çok yakında!'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── App section ────────────────────────────────────────────────────
        SettingsSection(
          header: 'Uygulama',
          tiles: [
            SettingsTile(
              icon: Icons.palette_rounded,
              label: 'Görünüm',
              iconColor: const Color(0xFFAF52DE),
              onTap: () => showAppSnackBar(context, 'Çok yakında!'),
            ),
            SettingsTile(
              icon: Icons.language_rounded,
              label: 'Uygulama Dili',
              iconColor: const Color(0xFF007AFF),
              onTap: () => showAppSnackBar(context, 'Çok yakında!'),
            ),
            SettingsTile(
              icon: Icons.help_rounded,
              label: 'Yardım',
              iconColor: const Color(0xFFFF9500),
              onTap: () => showAppSnackBar(context, 'Çok yakında!'),
            ),
            SettingsTile(
              icon: Icons.info_rounded,
              label: 'Hakkında',
              iconColor: const Color(0xFF8E8E93),
              showDivider: false,
              onTap: () => showAppSnackBar(context, 'Splukk v1.0'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Logout ─────────────────────────────────────────────────────────
        SettingsSection(tiles: [
          SettingsTile(
            icon: Icons.logout_rounded,
            label: 'Çıkış Yap',
            iconColor: const Color(0xFFFF3B30),
            showDivider: false,
            trailing: const SizedBox.shrink(),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Çıkış Yap', style: TextStyle(color: _kTextPrim, fontWeight: FontWeight.bold)),
                  content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?', style: TextStyle(color: _kTextSec)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal', style: TextStyle(color: _kTextSec, fontWeight: FontWeight.w600))),
                    TextButton(onPressed: () => Navigator.pop(context, true),
                      child: const Text('Çıkış', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold))),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
                setState(() { _flow = null; _logoPath = null; _clearFarmerDraft(); });
              }
            },
          ),
        ]),
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
        title: const Text('Profil',
          style: TextStyle(color: _kTextPrim, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
        leadingWidth: 80,
        leading: _flow != null
            ? TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: _cancelFlow,
                child: const Text('İptal', style: TextStyle(color: _kGreen, fontWeight: FontWeight.bold, fontSize: 16)),
              )
            : null,
        actions: [
          if (_flow == null)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.edit_rounded, color: _kGreen, size: 24),
                  onPressed: () {
                    if (state.status == AuthStatus.authenticated &&
                        state.profile != null) {
                      context.router.push(EditProfileRoute(profile: state.profile!));
                    } else {
                      showAppSnackBar(context, 'Lütfen önce giriş yapın');
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: Builder(builder: (ctx) {
        final isActive = ActiveTabProvider.of(ctx) == 2;
        return PopScope(
          canPop: !isActive,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || !isActive) return;
            if (_flow != null) { _cancelFlow(); return; }
            final exit = await showExitConfirmationDialog(ctx);
            if (exit && ctx.mounted) SystemNavigator.pop();
          },
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (ctx, state) {
              if (state.status == AuthStatus.failure && state.errorMessage != null) {
                showAppSnackBar(ctx, state.errorMessage!, isError: true);
              }
            },
            builder: (ctx, state) {
              Widget body;
              if (state.status == AuthStatus.authenticated && state.profile != null) {
                body = _buildSignedIn(ctx, state);
              } else if (_flow == null) {
                body = _buildHub(ctx);
              } else if (state.status == AuthStatus.codeSent) {
                body = _buildCodeStep(ctx);
              } else {
                body = _buildPhoneStep(ctx, state);
              }
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: (state.status == AuthStatus.authenticated && state.profile != null)
                    ? body
                    : Center(child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: _kCard,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 30, offset: const Offset(0, 12),
                            )],
                          ),
                          child: body,
                        ),
                      )),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
