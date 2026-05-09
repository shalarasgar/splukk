import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:splukk/core/app_messages.dart';
import 'package:splukk/core/di/dependencies.dart';
import 'package:splukk/core/l10n/language_picker_sheet.dart';
import 'package:splukk/core/l10n/locale_keys.dart';
import 'package:splukk/core/services/media_picker_service.dart';
import 'package:splukk/core/widgets/premium_button.dart';
import 'package:splukk/core/widgets/premium_button.dart';
import 'package:splukk/core/widgets/premium_text_field.dart';
import 'package:splukk/features/auth/domain/auth_domain.dart';
import 'package:splukk/features/auth/presentation/auth_bloc.dart';
import 'package:splukk/features/auth/presentation/phone_auth_cubit/phone_auth_cubit.dart';
import 'package:splukk/features/auth/presentation/phone_auth_cubit/phone_auth_state.dart';

const _kGreen = Color(0xFF4CAF50);
const _kGreenDark = Color(0xFF388E3C);
const _kTextPrim = Color(0xFF1E293B);
const _kTextSec = Color(0xFF64748B);

class AuthWizardWidget extends StatefulWidget {
  const AuthWizardWidget({super.key});

  @override
  State<AuthWizardWidget> createState() => _AuthWizardWidgetState();
}

class _AuthWizardWidgetState extends State<AuthWizardWidget> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _farmNameController = TextEditingController();
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
    final path = await sl<MediaPickerService>().pickImage();
    if (path != null) setState(() => _logoPath = path);
  }

  void _cancelFlow() {
    context.read<PhoneAuthCubit>().reset();
    setState(() {
      _flow = null;
      _logoPath = null;
      _clearFarmerDraft();
    });
  }

  void _sendSms(BuildContext ctx) {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showAppSnackBar(ctx, LocaleKeys.auth_error_phone_empty.tr(context: ctx));
      return;
    }
    final flow = _flow;
    if (flow == null) return;

    ctx.read<PhoneAuthCubit>().submitPhoneNumber(
          phoneNumber: phone,
          intent: flow,
          fullName: _fullNameController.text,
          farmName: _farmNameController.text,
          farmCountry: _farmCountry,
          farmState: _farmState,
          farmCity: _farmCity,
          farmPostalCode: _postalCodeController.text,
          farmStreet: _farmStreetController.text,
          farmStreetNumber: _farmStreetNumberController.text,
          logoLocalPath: _logoPath,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PhoneAuthCubit>(),
      child: BlocConsumer<PhoneAuthCubit, PhoneAuthState>(
        listener: (context, state) {
          if (state.status == PhoneAuthStatus.failure && state.errorMessage != null) {
            final msg = state.errorMessage!; // TODO: Use error resolver
            showAppSnackBar(context, msg, isError: true);
          }
        },
        builder: (context, state) {
          if (_flow == null) {
            return _buildHub(context);
          }
          if (state.status == PhoneAuthStatus.codeSent) {
            return _buildCodeStep(context);
          }
          return _buildPhoneStep(context, state);
        },
      ),
    );
  }

  Widget _buildHub(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_kGreen, _kGreenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          LocaleKeys.auth_welcome.tr(context: context),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _kTextPrim,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.auth_welcome_subtitle.tr(context: context),
          textAlign: TextAlign.center,
          style: const TextStyle(color: _kTextSec, fontSize: 15),
        ),
        const SizedBox(height: 32),
        _hubButton(
          Icons.login_rounded,
          LocaleKeys.auth_login.tr(context: context),
          _kGreen,
          () => setState(() => _flow = AuthFlowIntent.login),
        ),
        const SizedBox(height: 12),
        _hubButton(
          Icons.person_add_rounded,
          LocaleKeys.auth_register_consumer.tr(context: context),
          const Color(0xFF2196F3),
          () => setState(() => _flow = AuthFlowIntent.registerConsumer),
        ),
        const SizedBox(height: 12),
        _hubButton(
          Icons.agriculture_rounded,
          LocaleKeys.auth_register_farmer.tr(context: context),
          const Color(0xFFFF9800),
          () => setState(() => _flow = AuthFlowIntent.registerFarmer),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => showLanguagePickerSheet(context),
          icon: const Icon(Icons.language_rounded, size: 18),
          label: Text(LocaleKeys.profile_language.tr(context: context)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF007AFF),
            side: const BorderSide(color: Color(0xFF007AFF), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _hubButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
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
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep(BuildContext context, PhoneAuthState state) {
    final loading = state.status == PhoneAuthStatus.loading;
    final flow = _flow!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kTextPrim,
                size: 20,
              ),
              onPressed: _cancelFlow,
            ),
            Text(
              flow == AuthFlowIntent.login
                  ? LocaleKeys.auth_login.tr(context: context)
                  : LocaleKeys.auth_register.tr(context: context),
              style: const TextStyle(
                color: _kTextPrim,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (flow == AuthFlowIntent.registerConsumer) ...[
          PremiumTextField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            label: LocaleKeys.auth_full_name.tr(context: context),
          ),
          const SizedBox(height: 16),
        ],
        if (flow == AuthFlowIntent.registerFarmer) ...[
          PremiumTextField(
            controller: _farmNameController,
            label: LocaleKeys.auth_farm_name.tr(context: context),
          ),
          const SizedBox(height: 16),
          _locationPicker(),
          const SizedBox(height: 16),
          PremiumTextField(
            controller: _postalCodeController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            label: LocaleKeys.auth_postal_code.tr(context: context),
          ),
          const SizedBox(height: 16),
          PremiumTextField(
            controller: _farmStreetController,
            textCapitalization: TextCapitalization.words,
            label: LocaleKeys.auth_street.tr(context: context),
          ),
          const SizedBox(height: 16),
          PremiumTextField(
            controller: _farmStreetNumberController,
            label: LocaleKeys.auth_building_number.tr(context: context),
          ),
          const SizedBox(height: 16),
          _logoPicker(),
          const SizedBox(height: 16),
        ],
        PremiumTextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          label: LocaleKeys.auth_phone_label.tr(context: context),
          hint: LocaleKeys.auth_phone_hint.tr(context: context),
        ),
        const SizedBox(height: 32),
        PremiumButton(
          text: LocaleKeys.auth_send_sms.tr(context: context),
          isLoading: loading,
          onPressed: () => _sendSms(context),
        ),
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
        countryDropdownLabel: LocaleKeys.location_country.tr(context: context),
        stateDropdownLabel: LocaleKeys.location_state.tr(context: context),
        cityDropdownLabel: LocaleKeys.location_city.tr(context: context),
        countrySearchPlaceholder: LocaleKeys.location_search_country.tr(context: context),
        stateSearchPlaceholder: LocaleKeys.location_search_state.tr(context: context),
        citySearchPlaceholder: LocaleKeys.location_search_city.tr(context: context),
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
        child: Row(
          children: [
            Icon(
              Icons.image_outlined,
              color: _logoPath != null ? _kGreen : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _logoPath == null
                    ? LocaleKeys.auth_logo_add.tr(context: context)
                    : LocaleKeys.auth_logo_selected.tr(context: context),
                style: TextStyle(
                  color: _logoPath != null ? _kGreen : Colors.grey.shade700,
                ),
              ),
            ),
            if (_logoPath != null)
              const Icon(Icons.check_circle, color: _kGreen, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeStep(BuildContext context) {
    final loading = context.watch<PhoneAuthCubit>().state.status == PhoneAuthStatus.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kTextPrim,
                size: 20,
              ),
              onPressed: _cancelFlow,
            ),
            Text(
              LocaleKeys.auth_sms_verification.tr(context: context),
              style: const TextStyle(
                color: _kTextPrim,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          LocaleKeys.auth_sms_instructions.tr(context: context),
          style: const TextStyle(color: _kTextSec, fontSize: 15),
        ),
        const SizedBox(height: 32),
        PremiumTextField(
          controller: _codeController,
          label: LocaleKeys.auth_verification_code.tr(context: context),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 32),
        PremiumButton(
          text: LocaleKeys.auth_verify_complete.tr(context: context),
          isLoading: loading,
          onPressed: () {
            context.read<PhoneAuthCubit>().submitSmsCode(_codeController.text);
          },
        ),
      ],
    );
  }
}
