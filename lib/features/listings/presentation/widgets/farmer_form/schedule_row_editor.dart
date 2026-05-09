import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/l10n/locale_keys.dart';
import 'farmer_form_models.dart';

class ScheduleRowEditor extends StatelessWidget {
  const ScheduleRowEditor({
    super.key,
    required this.row,
    required this.onRemove,
    required this.onChanged,
  });

  final ScheduleDraft row;
  final Future<void> Function() onRemove;
  final VoidCallback onChanged;

  static DateTime _nextOccurrenceOfWeekday(int weekday, DateTime from) {
    var d = DateTime(from.year, from.month, from.day);
    for (var i = 0; i < 8; i++) {
      if (d.weekday == weekday) return d;
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  Future<void> _pickWeekdayFromCalendar(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = today.add(const Duration(days: 365 * 3));
    var initial =
        row.calendarAnchor ?? _nextOccurrenceOfWeekday(row.weekday, now);
    initial = DateTime(initial.year, initial.month, initial.day);
    if (initial.isBefore(today)) {
      initial = _nextOccurrenceOfWeekday(row.weekday, now);
    }
    if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: lastDate,
      helpText: LocaleKeys.farmer_listing_form_new_title.tr(
        context: context,
      ), // Or some other appropriate key
    );
    if (picked == null || !context.mounted) return;
    final day = DateTime(picked.year, picked.month, picked.day);
    row.weekday = picked.weekday;
    row.calendarAnchor = day;
    onChanged();
  }

  String _weekdayName(int w, String locale) {
    final now = DateTime.now();
    final date = now.add(Duration(days: w - now.weekday));
    return DateFormat.EEEE(locale).format(date);
  }

  String _fmtPaddedDate(DateTime d) => DateFormat('dd.MM.yyyy').format(d);

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final initial = isStart ? row.start : row.end;
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t == null) return;
    if (isStart) {
      row.start = t;
    } else {
      row.end = t;
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final dayLabel = row.calendarAnchor != null
        ? '${_fmtPaddedDate(row.calendarAnchor!)} · ${_weekdayName(row.weekday, locale)}'
        : _weekdayName(row.weekday, locale);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: LocaleKeys.my_picks_date.tr(context: context),
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    child: InkWell(
                      onTap: () => _pickWeekdayFromCalendar(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dayLabel,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              LocaleKeys.farmer_listing_form_calendar.tr(
                                context: context,
                              ),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove(),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(context, true),
                    child: Text(
                      '${LocaleKeys.my_picks_time.tr(context: context)} (Start) ${_fmt(row.start)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(context, false),
                    child: Text(
                      '${LocaleKeys.my_picks_time.tr(context: context)} (End) ${_fmt(row.end)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: row.capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: LocaleKeys.farmer_listing_form_capacity.tr(
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
