class DateFormatter {
  DateFormatter._();

  static const _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];
  static const _monthsFull = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  static const _weekdays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
  static const _weekdaysShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  static String toDisplay(DateTime date) =>
      '${_pad(date.day)}/${_pad(date.month)}/${date.year}';

  static String toDisplayDateTime(DateTime date) =>
      '${toDisplay(date)} ${_pad(date.hour)}:${_pad(date.minute)}';

  static String toDayMonth(DateTime date) =>
      '${_pad(date.day)} ${_months[date.month - 1]}';

  static String toDayMonthYear(DateTime date) =>
      '${_pad(date.day)} de ${_monthsFull[date.month - 1]} de ${date.year}';

  static String toWeekday(DateTime date) => _weekdays[date.weekday - 1];
  static String toWeekdayShort(DateTime date) => _weekdaysShort[date.weekday - 1];

  static String toMonthYear(DateTime date) =>
      '${_monthsFull[date.month - 1].replaceFirst(date.month == 1 || date.month == 8 ? 'e' : '', date.month == 1 || date.month == 8 ? 'E' : '')} ${date.year}';

  static String toDb(DateTime date) =>
      '${date.year}-${_pad(date.month)}-${_pad(date.day)}';

  static String toDbDateTime(DateTime date) =>
      '${toDb(date)} ${_pad(date.hour)}:${_pad(date.minute)}:${_pad(date.second)}';

  static DateTime fromDb(String dateStr) => DateTime.parse(dateStr);

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Mañana';
    if (diff == -1) return 'Ayer';
    if (diff > 1 && diff <= 7) return 'En $diff días';
    if (diff < -1 && diff >= -7) return 'Hace ${diff.abs()} días';
    return toDayMonth(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isPast(DateTime date) => date.isBefore(DateTime.now());
  static bool isFuture(DateTime date) => date.isAfter(DateTime.now());

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
