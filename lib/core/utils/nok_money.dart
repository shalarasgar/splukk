/// Norwegian krone (NOK) — store as øre (integer) to avoid float drift.
/// Display/input: "12,50" or "12.50" kr → 1250 øre.
library;

int? parseNokToOre(String input) {
  var s = input.trim().replaceAll(' ', '').replaceAll('kr', '');
  if (s.isEmpty) return null;
  s = s.replaceAll(',', '.');
  final parts = s.split('.');
  if (parts.length > 2) return null;
  final whole = int.tryParse(parts.first);
  if (whole == null) return null;
  if (parts.length == 1) return whole * 100;
  final frac = parts[1].padRight(2, '0').substring(0, 2);
  final cents = int.tryParse(frac);
  if (cents == null) return null;
  final sign = whole < 0 ? -1 : 1;
  return sign * (whole.abs() * 100 + cents);
}

String formatOreAsNokKr(int ore) {
  final neg = ore < 0;
  final v = ore.abs();
  final kr = v ~/ 100;
  final o = v % 100;
  final s = '${neg ? '-' : ''}$kr,${o.toString().padLeft(2, '0')} kr';
  return s;
}
