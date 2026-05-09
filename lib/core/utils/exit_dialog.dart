import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../l10n/locale_keys.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(LocaleKeys.exit_dialog_title.tr(context: ctx)),
      content: Text(LocaleKeys.exit_dialog_body.tr(context: ctx)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            LocaleKeys.exit_dialog_stay.tr(context: ctx),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            LocaleKeys.exit_dialog_exit.tr(context: ctx),
            style: const TextStyle(
              color: Color(0xFF2B8C5F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
