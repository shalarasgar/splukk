import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../l10n/locale_keys.dart';

/// Переводит error-коды из AuthBloc в локализованные строки.
///
/// AuthBloc эмитит коды (e.g. 'AUTH_NO_ACCOUNT'), а Presentation-слой
/// вызывает этот helper для получения строки на языке пользователя.
/// Это соблюдает принцип: BLoC не знает о UI, UI отвечает за перевод.
String resolveAuthErrorMessage(String errorCode, BuildContext context) {
  switch (errorCode) {
    case 'AUTH_FARM_REQUIRED':
      return LocaleKeys.auth_error_farm_required.tr(context: context);
    case 'AUTH_STREET_REQUIRED':
      return LocaleKeys.auth_error_street_required.tr(context: context);
    case 'AUTH_FARM_LOCATION_REQUIRED':
      return LocaleKeys.auth_error_farm_location_required.tr(context: context);
    case 'AUTH_ADDRESS_NOT_FOUND':
      return LocaleKeys.auth_error_address_not_found.tr(context: context);
    case 'AUTH_NO_ACCOUNT':
      return LocaleKeys.auth_error_no_account.tr(context: context);
    case 'AUTH_VERIFICATION_ID_MISSING':
      return LocaleKeys.auth_error_verification_id_missing.tr(context: context);
    case 'AUTH_NAME_REQUIRED':
      return LocaleKeys.auth_error_name_empty.tr(context: context);
    case 'AUTH_FARM_ADDRESS_INCOMPLETE':
      return LocaleKeys.auth_error_farm_address_incomplete.tr(context: context);
    default:
      // Если это не известный код — возвращаем как есть (например, системные ошибки)
      return errorCode;
  }
}
