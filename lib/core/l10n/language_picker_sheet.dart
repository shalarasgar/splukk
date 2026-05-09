import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_keys.dart';

/// Данные о языке
class _LangOption {
  final Locale locale;
  final String flag;
  final String name;
  final String nativeName;

  const _LangOption({
    required this.locale,
    required this.flag,
    required this.name,
    required this.nativeName,
  });
}

const _languages = [
  _LangOption(
    locale: Locale('en'),
    flag: '🇬🇧',
    name: 'English',
    nativeName: 'English',
  ),
  _LangOption(
    locale: Locale('no'),
    flag: '🇳🇴',
    name: 'Norwegian',
    nativeName: 'Norsk',
  ),
  _LangOption(
    locale: Locale('tr'),
    flag: '🇹🇷',
    name: 'Turkish',
    nativeName: 'Türkçe',
  ),
];

/// Показывает красивый BottomSheet для выбора языка.
/// [onChanged] вызывается после смены языка (опционально).
Future<void> showLanguagePickerSheet(
  BuildContext context, {
  VoidCallback? onChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LanguagePickerSheet(onChanged: onChanged),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  final VoidCallback? onChanged;
  const _LanguagePickerSheet({this.onChanged});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Color(0xFF007AFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  LocaleKeys.profile_language.tr(context: context),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Divider ───────────────────────────────────────────────────────
          Divider(color: Colors.grey.shade100, height: 24),

          // ── Language options ──────────────────────────────────────────────
          ...List.generate(_languages.length, (i) {
            final lang = _languages[i];
            final isSelected = currentLocale.languageCode == lang.locale.languageCode;
            final isLast = i == _languages.length - 1;

            return Column(
              children: [
                _LanguageTile(
                  lang: lang,
                  isSelected: isSelected,
                  onTap: () async {
                    if (!isSelected) {
                      await context.setLocale(lang.locale);
                      onChanged?.call();
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                if (!isLast)
                  Divider(
                    color: Colors.grey.shade100,
                    height: 1,
                    indent: 72,
                    endIndent: 24,
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final _LangOption lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF007AFF);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? selectedColor.withOpacity(0.2) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Text(lang.flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            // Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? selectedColor : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    lang.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: selectedColor,
                      size: 22,
                      key: ValueKey('check'),
                    )
                  : const SizedBox(width: 22, key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}
