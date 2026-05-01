import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ?? const Color(0xFF4CAF50);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (badge != null) ...[badge!, const SizedBox(width: 6)],
                  trailing ??
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: 66,
                endIndent: 0,
                color: Colors.grey.shade100,
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.tiles, this.header});

  final List<Widget> tiles;
  final String? header;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(left: 18, bottom: 8, top: 4),
            child: Text(
              header!.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: tiles),
          ),
        ),
      ],
    );
  }
}
