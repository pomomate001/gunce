import 'package:intl/intl.dart';

int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Lower-cases with Turkish rules and strips diacritics, so "Gunluk" finds "Günlük"
/// and "istanbul" finds "İSTANBUL".
String foldText(String s) {
  final b = StringBuffer();
  for (final ch in s.runes) {
    final c = String.fromCharCode(ch);
    b.write(switch (c) {
      'I' || 'ı' || 'İ' => 'i',
      'Ğ' || 'ğ' => 'g',
      'Ş' || 'ş' => 's',
      'Ç' || 'ç' => 'c',
      'Ö' || 'ö' => 'o',
      'Ü' || 'ü' => 'u',
      'Â' || 'â' => 'a',
      'Î' || 'î' => 'i',
      'Û' || 'û' => 'u',
      _ => c.toLowerCase(),
    });
  }
  return b.toString();
}

int wordCount(String s) => RegExp(r'[\p{L}\p{N}]+', unicode: true).allMatches(s).length;

/// Date helpers bound to the active locale.
class Dates {
  Dates(this.locale);
  final String locale;

  String monthYear(DateTime d) => _cap(DateFormat.yMMMM(locale).format(d));
  String month(DateTime d) => _cap(DateFormat.MMMM(locale).format(d));
  String monthShort(DateTime d) => _cap(DateFormat.MMM(locale).format(d));
  String weekday(DateTime d) => _cap(DateFormat.EEEE(locale).format(d));
  String weekdayShort(DateTime d) => _cap(DateFormat.E(locale).format(d));
  String dayMonth(DateTime d) => DateFormat.MMMMd(locale).format(d);
  String full(DateTime d) => DateFormat.yMMMMEEEEd(locale).format(d);
  String time(DateTime d) => DateFormat.Hm(locale).format(d);

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

String formatDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
