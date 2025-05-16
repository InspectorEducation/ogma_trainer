import 'package:intl/intl.dart';

String getTime(int totalMinutes) {
  int hour = (totalMinutes ~/ 60) % 24; // 0-23
  // int minute = totalMinutes % 60; // No se usa en tu UI actual, pero podrías
  String period = hour < 12 ? 'AM' : 'PM';
  if (hour == 0) { // Medianoche
    hour = 12;
  } else if (hour > 12) {
    hour -= 12;
  }
  return "${hour.toString().padLeft(2, '0')}:00 $period";
}

String getStringDateToOtherFormate(String dateStr,
    {String inputFormatStr = "dd/MM/yyyy hh:mm aa",
    String outFormatStr = "hh:mm a"}) {
  var format = DateFormat(outFormatStr);
  return format.format(stringToDate(dateStr, formatStr: inputFormatStr));
}

DateTime stringToDate(String dateStr, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.parse(dateStr);
}

DateTime dateToStartDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String dateToString(DateTime date, {String formatStr = "dd/MM/yyyy hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(date);
}

String getDayTitle(String dateStr, {String formatStr = "dd/MM/yyyy hh:mm a"} ) {
  var date = stringToDate(dateStr, formatStr: formatStr);

  if (date.isToday) {
    return "HOY";
  } else if (date.isTomorrow) {
    return "Mañana";
  } else if (date.isYesterday) {
    return "Ayer";
  } else {
    var outFormat = DateFormat("E");
    return outFormat.format(date) ;
  }
}

extension DateHelpers on DateTime {
  bool get isToday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 0;
  }

  bool get isYesterday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == -1;
  }

  bool get isTomorrow {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 1;
  }
}
