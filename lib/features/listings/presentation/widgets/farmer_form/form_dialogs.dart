import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/l10n/locale_keys.dart';

class FarmerFormDialogs {
  /// Shows a confirmation dialog before deleting a schedule row.
  /// Returns [true] if the user confirms the deletion.
  static Future<bool> showConfirmDeleteSchedule(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          LocaleKeys.farmer_listing_form_confirm_delete_title.tr(
            context: context,
          ),
        ),
        content: Text(
          LocaleKeys.farmer_listing_form_confirm_delete_body.tr(
            context: context,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              LocaleKeys.farmer_listing_form_cancel.tr(context: context),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              LocaleKeys.farmer_listing_form_delete.tr(context: context),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  /// Shows a dialog explaining that the user needs to set up a farm location in their profile.
  /// Returns [true] if the user chooses to navigate to their profile.
  static Future<bool> showLocationRequired(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          LocaleKeys.farmer_listing_form_error_location_required.tr(
            context: context,
          ),
        ),
        content: Text(
          LocaleKeys.farmer_listing_form_error_location_required_desc.tr(
            context: context,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(LocaleKeys.common_cancel.tr(context: context)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(LocaleKeys.nav_profile.tr(context: context)),
          ),
        ],
      ),
    );
    return result == true;
  }
}
