import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../marketplace_cubit.dart';
import '../marketplace_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/l10n/locale_keys.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Генерируем список дат на ближайшие 2 недели
    final dates = List.generate(14, (i) => today.add(Duration(days: i)));

    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              LocaleKeys.marketplace_plan_visit.tr(context: context),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: dates.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return BlocBuilder<MarketplaceCubit, MarketplaceState>(
                    builder: (context, state) {
                      final isSelected = state.selectedDate == null;
                      return GestureDetector(
                        onTap: () => context
                            .read<MarketplaceCubit>()
                            .updateSelectedDate(null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2B8C5F)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey[200]!,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2B8C5F,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            LocaleKeys.common_all.tr(context: context),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                final date = dates[index - 1];
                return BlocBuilder<MarketplaceCubit, MarketplaceState>(
                  builder: (context, state) {
                    final isSelected = DateUtils.isSameDay(
                      date,
                      state.selectedDate,
                    );

                    return GestureDetector(
                      onTap: () => context
                          .read<MarketplaceCubit>()
                          .updateSelectedDate(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2B8C5F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[200]!,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2B8C5F,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _weekdayAbbr(date.weekday, context.locale.languageCode),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey[500],
                              ),
                            ),
                            Text(
                              '${date.day}',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayAbbr(int wd, String locale) {
    final now = DateTime.now();
    final date = now.add(Duration(days: wd - now.weekday));
    return DateFormat.E(locale).format(date);
  }
}
