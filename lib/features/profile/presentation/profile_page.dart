import 'package:auto_route/auto_route.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_messages.dart';
import '../../../core/router/app_router.gr.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';

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
          showAppSnackBar(
            context,
            'Cadde ve bina/kapı numarası zorunludur',
          );
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hesap',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Telefon numaranız ile giriş yapın veya yeni hesap oluşturun.',
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _flow = AuthFlowIntent.login),
          child: const Text('Giriş yap'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () =>
              setState(() => _flow = AuthFlowIntent.registerConsumer),
          child: const Text('Müşteri olarak kayıt ol'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => setState(() => _flow = AuthFlowIntent.registerFarmer),
          child: const Text('Çiftlik sahibi olarak kayıt ol'),
        ),
      ],
    );
  }

  Widget _buildPhoneStep(BuildContext context, AuthState state) {
    final loading = state.status == AuthStatus.verifyingPhone;
    final flow = _flow!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (flow == AuthFlowIntent.registerConsumer) ...[
          TextField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Ad soyad',
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (flow == AuthFlowIntent.registerFarmer) ...[
          TextField(
            controller: _farmNameController,
            decoration: const InputDecoration(
              labelText: 'Çiftlik adı',
            ),
          ),
          const SizedBox(height: 12),
          CSCPicker(
            layout: Layout.vertical,
            flagState: CountryFlag.DISABLE,
            defaultCountry: CscCountry.Norway,
            countryDropdownLabel: 'Ülke',
            stateDropdownLabel: 'Eyalet',
            cityDropdownLabel: 'Şehir',
            countrySearchPlaceholder: 'Ülke ara',
            stateSearchPlaceholder: 'Eyalet ara',
            citySearchPlaceholder: 'Şehir ara',
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
          const SizedBox(height: 12),
          TextField(
            controller: _postalCodeController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Posta kodu',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _farmStreetController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Cadde',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _farmStreetNumberController,
            decoration: const InputDecoration(
              labelText: 'Bina / kapı numarası',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              _logoPath == null ? 'Logo ekle (isteğe bağlı)' : 'Logo seçildi',
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefon',
            hintText: '+47XXXXXXXX',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: loading ? null : () => _sendSms(context),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SMS kodu gönder'),
        ),
      ],
    );
  }

  Widget _buildCodeStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('SMS ile gelen kodu girin'),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Doğrulama kodu',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context
                  .read<AuthBloc>()
                  .add(AuthSmsCodeSubmitted(_codeController.text));
            },
            child: const Text('Doğrula ve tamamla'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedIn(BuildContext context, AuthState state) {
    final profile = state.profile!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          profile.displayLabel,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text('Telefon: ${profile.phone}'),
        if (profile.role == UserRole.farmer) ...[
          const SizedBox(height: 16),
          if (profile.farmLocationSummary != null)
            Text('Adres: ${profile.farmLocationSummary}'),
          if (profile.logoUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(profile.logoUrl!, height: 96),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.router.push(const FarmerDashboardRoute());
            },
            child: const Text('Çiftçi paneli'),
          ),
        ],
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {
            context.read<AuthBloc>().add(const AuthSignOutRequested());
            setState(() {
              _flow = null;
              _logoPath = null;
              _clearFarmerDraft();
            });
          },
          child: const Text('Çıkış yap'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (_flow != null)
            TextButton(
              onPressed: _cancelFlow,
              child: const Text('İptal'),
            ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure && state.errorMessage != null) {
            showAppSnackBar(context, state.errorMessage!, isError: true);
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
    );
  }
}
