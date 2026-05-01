import 'package:flutter/material.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Exit App'),
      content: const Text('Do you want to exit the application?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Yes',
            style: TextStyle(
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
