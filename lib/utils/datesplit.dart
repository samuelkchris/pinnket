import 'dart:async';

import 'package:intl/intl.dart';

Map<String, dynamic> splitDate(String dateStr) {
  List<String> dateParts = dateStr.split('-');
  if (dateParts.length != 3) {
    return {"error": "Invalid Date Format"};
  }

  int year = int.tryParse(dateParts[0]) ?? 0;
  int month = int.tryParse(dateParts[1]) ?? 0;
  int day = int.tryParse(dateParts[2]) ?? 0;

  String monthName = '';
  switch (month) {
    case 1:
      monthName = 'January';
      break;
    case 2:
      monthName = 'February';
      break;
    case 3:
      monthName = 'March';
      break;
    case 4:
      monthName = 'April';
      break;
    case 5:
      monthName = 'May';
      break;
    case 6:
      monthName = 'June';
      break;
    case 7:
      monthName = 'July';
      break;
    case 8:
      monthName = 'August';
      break;
    case 9:
      monthName = 'September';
      break;
    case 10:
      monthName = 'October';
      break;
    case 11:
      monthName = 'November';
      break;
    case 12:
      monthName = 'December';
      break;
    default:
      return {"error": "Invalid Month"};
  }

  Map<String, dynamic> result = {
    "year": year,
    "month": monthName,
    "day": day,
  };

  return result;
}

String formatDateString(String dateString) {
  try {
    final DateTime dateTime = DateTime.parse(dateString);
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return dateFormatter.format(dateTime);
  } catch (e) {
    return 'Invalid Date';
  }
}

String extractDateFromString(String dateString) {
  try {
    final DateTime dateTime = DateTime.parse(dateString);
    final formattedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final dateFormatter = DateFormat('yyyy-MM-dd');

    return dateFormatter.format(formattedDate);
  } catch (e) {
    return 'Invalid Date';
  }
}

String extractDateTimeFromString(String dateString) {
  try {
    final DateTime dateTime = DateTime.parse(dateString);
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return dateFormatter.format(dateTime);
  } catch (e) {
    return 'Invalid Date';
  }
}

class EventCountdown {
  late DateTime eventDate;
  Timer? _timer;
  Function(String)? onUpdate;

  EventCountdown(String eventDateString, {this.onUpdate}) {
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    eventDate = DateTime.parse(eventDateString);
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      Duration remaining = eventDate.difference(now);

      if (remaining.isNegative) {
        print("Event Started");
        _timer?.cancel();
      } else {
        String remainingTime = getRemainingTime(remaining);
        print(remainingTime);
        onUpdate?.call(remainingTime);
      }
    });
  }

  void stopCountdown() {
    _timer?.cancel();
  }

  String getRemainingTime(Duration remaining) {
    int days = remaining.inDays;
    int hours = remaining.inHours.remainder(24);
    int minutes = remaining.inMinutes.remainder(60);
    int seconds = remaining.inSeconds.remainder(60);
    return "$days days, $hours hours, $minutes minutes, $seconds seconds";
  }
}

String extractDateFromDateTime(DateTime dateTime) {
  try {
    final formattedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final dateFormatter = DateFormat('yyyy-MM-dd');

    return dateFormatter.format(formattedDate);
  } catch (e) {
    return 'Invalid Date';
  }
}

String trimDataUriPrefix(String dataUri) {
  const prefix = "data:image/png;base64,";
  if (dataUri.startsWith(prefix)) {
    return dataUri.substring(prefix.length);
  }
  return dataUri;
}

String extractTimeFromString(String dateString) {
  final time = dateString.substring(11, 16);
  return time;
}

String formatDateRange(String startDate, String endDate) {
  DateTime startDateTime = DateTime.parse(startDate);
  DateTime endDateTime = DateTime.parse(endDate);

  if (startDateTime.day == endDateTime.day &&
      startDateTime.month == endDateTime.month &&
      startDateTime.year == endDateTime.year) {
    // If the dates are equal, return the formatted start date
    return DateFormat.yMMMMd().format(startDateTime);
  } else {
    // If the dates are not equal, return the formatted date range
    return "${DateFormat.yMMMMd().format(startDateTime)} - ${DateFormat.yMMMMd().format(endDateTime)}";
  }
}
