import 'package:auto_route/auto_route.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_messages.dart';
import '../../../core/router/app_router.gr.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import 'widgets/premium_button.dart';
import 'widgets/premium_text_field.dart';
import 'widgets/social_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _farmStreetController = TextEditingController();
  final _farmStreetNumberController = TextEditingController();

  AuthFlowIntent? _flow;
  String? _logoPath;
  String? _farmCountry;
  String? _farmState;
  String? _farmCity;

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
    _farmCountry = null;
    _farmState = null;
    _farmCity = null;
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
    setState(() {
      _flow = null;
      _logoPath = null;
      _clearFarmerDraft();
    });
  }

  void _sendSms(BuildContext context) {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showAppSnackBar(context, 'Telefon numarası girin');
      return;
    }

    final flow = _flow;
    if (flow == null) return;

    switch (flow) {
      case AuthFlowIntent.login:
        context.read<AuthBloc>().add(
          AuthPhoneRequested(phone, intent: AuthFlowIntent.login),
        );
      case AuthFlowIntent.registerConsumer:
        final name = _fullNameController.text.trim();
        if (name.isEmpty) {
          showAppSnackBar(context, 'Ad soyad girin');
          return;
        }
        context.read<AuthBloc>().add(
          AuthPhoneRequested(
            phone,
            intent: AuthFlowIntent.registerConsumer,
            fullName: name,
          ),
        );
      case AuthFlowIntent.registerFarmer:
        final farmName = _farmNameController.text.trim();
        final country = _farmCountry?.trim() ?? '';
        final state = _farmState?.trim() ?? '';
        final city = _farmCity?.trim() ?? '';
        final postal = _postalCodeController.text.trim();
        final street = _farmStreetController.text.trim();
        final streetNo = _farmStreetNumberController.text.trim();
        if (farmName.isEmpty ||
            country.isEmpty ||
            state.isEmpty ||
            city.isEmpty ||
            postal.isEmpty) {
          showAppSnackBar(
            context,
            'Çiftlik adı, ülke, eyalet, şehir ve posta kodu zorunludur',
          );
          return;
        }
        if (street.isEmpty || streetNo.isEmpty) {
          showAppSnackBar(context, 'Cadde ve bina/kapı numarası zorunludur');
          return;
        }
        context.read<AuthBloc>().add(
          AuthPhoneRequested(
            phone,
            intent: AuthFlowIntent.registerFarmer,
            farmName: farmName,
            farmCountry: country,
            farmState: state,
            farmCity: city,
            farmPostalCode: postal,
            farmStreet: street,
            farmStreetNumber: streetNo,
            logoLocalPath: _logoPath,
          ),
        );
    }
  }

  Widget _buildHub(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.account_circle_rounded,
          size: 72,
          color: Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        Text(
          'Hoş Geldiniz',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Hesabınıza giriş yapın veya yeni bir hesap oluşturun.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        PremiumButton(
          text: 'Giriş Yap',
          onPressed: () => setState(() => _flow = AuthFlowIntent.login),
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        PremiumButton(
          text: 'Müşteri Olarak Kayıt Ol',
          onPressed: () =>
              setState(() => _flow = AuthFlowIntent.registerConsumer),
          isPrimary: false,
        ),
        const SizedBox(height: 12),
        PremiumButton(
          text: 'Çiftlik Sahibi Olarak Kayıt Ol',
          onPressed: () =>
              setState(() => _flow = AuthFlowIntent.registerFarmer),
          isPrimary: false,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Veya',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        SocialButton(
          text: 'Vipps ile giriş',
          assetPath: 'assets/vipps_icon.png',
          color: const Color(0xFFFF5900),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthVippsLoginRequested());
          },
        ),
        const SizedBox(height: 12),
        SocialButton(
          text: 'Google ile giriş',
          assetPath: 'assets/google_icon.png',
          color: const Color(0xFF4285F4),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
          },
        ),
      ],
    );
  }

  Widget _buildPhoneStep(BuildContext context, AuthState state) {
    final loading = state.status == AuthStatus.verifyingPhone;
    final flow = _flow!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          flow == AuthFlowIntent.login
              ? Icons.login_rounded
              : Icons.person_add_rounded,
          size: 64,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        Text(
          flow == AuthFlowIntent.login ? 'Giriş Yap' : 'Kayıt Ol',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (flow == AuthFlowIntent.registerConsumer) ...[
          PremiumTextField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            label: 'Ad Soyad',
          ),
          const SizedBox(height: 16),
        ],
        if (flow == AuthFlowIntent.registerFarmer) ...[
          PremiumTextField(
            controller: _farmNameController,
            label: 'Çiftlik Adı',
          ),
          const SizedBox(height: 16),
          Container(
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
              onCountryChanged: (value) {
                setState(() => _farmCountry = value);
              },
              onStateChanged: (value) {
                setState(() => _farmState = value);
              },
              onCityChanged: (value) {
                setState(() => _farmCity = value);
              },
            ),
          ),
          const SizedBox(height: 16),
          PremiumTextField(
            controller: _postalCodeController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            label: 'Posta Kodu',
          ),
          const SizedBox(height: 16),
          PremiumTextField(
            controller: _farmStreetController,
            textCapitalization: TextCapitalization.words,
            label: 'Cadde',
          ),
          const SizedBox(height: 16),
          PremiumTextField(
            controller: _farmStreetNumberController,
            label: 'Bina / Kapı Numarası',
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickLogo,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(Icons.image_outlined, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _logoPath == null
                          ? 'Logo ekle (isteğe bağlı)'
                          : 'Logo seçildi',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  if (_logoPath != null)
                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        PremiumTextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          label: 'Telefon',
          hint: '+47XXXXXXXX',
        ),
        const SizedBox(height: 32),
        PremiumButton(
          text: 'SMS Kodu Gönder',
          isLoading: loading,
          onPressed: () => _sendSms(context),
        ),
      ],
    );
  }

  Widget _buildCodeStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.message_outlined, size: 64, color: Color(0xFF4CAF50)),
        const SizedBox(height: 16),
        Text(
          'SMS Doğrulama',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Telefonunuza gönderilen 6 haneli kodu girin',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        PremiumTextField(
          controller: _codeController,
          label: 'Doğrulama Kodu',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 32),
        PremiumButton(
          text: 'Doğrula ve Tamamla',
          onPressed: () {
            context.read<AuthBloc>().add(
              AuthSmsCodeSubmitted(_codeController.text),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSignedIn(BuildContext context, AuthState state) {
    final profile = state.profile!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.person, size: 48, color: Color(0xFF4CAF50)),
        ),
        const SizedBox(height: 16),
        Text(
          profile.displayLabel,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            profile.phone ?? '',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (profile.role == UserRole.farmer) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storefront, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Text(
                      'Çiftlik Bilgileri',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (profile.farmLocationSummary != null)
                  Text(
                    profile.farmLocationSummary!,
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      height: 1.5,
                    ),
                  ),
                if (profile.logoUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(profile.logoUrl!, height: 80),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          PremiumButton(
            text: 'Çiftçi Paneli',
            onPressed: () {
              context.router.push(const FarmerDashboardRoute());
            },
          ),
          const SizedBox(height: 12),
        ],
        PremiumButton(
          text: 'Çıkış Yap',
          isPrimary: false,
          onPressed: () {
            context.read<AuthBloc>().add(const AuthSignOutRequested());
            setState(() {
              _flow = null;
              _logoPath = null;
              _clearFarmerDraft();
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_flow != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _cancelFlow,
                child: const Text(
                  'İptal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F8FD), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state.status == AuthStatus.failure &&
                        state.errorMessage != null) {
                      showAppSnackBar(
                        context,
                        state.errorMessage!,
                        isError: true,
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == AuthStatus.authenticated &&
                        state.profile != null) {
                      return _buildSignedIn(context, state);
                    }

                    if (_flow == null) {
                      return _buildHub(context);
                    }

                    if (state.status == AuthStatus.codeSent) {
                      return _buildCodeStep(context);
                    }

                    return _buildPhoneStep(context, state);
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
