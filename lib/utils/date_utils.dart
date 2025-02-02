import 'package:intl/intl.dart';

formatTimeAsString(int time) {
  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);

  final DateFormat timeFormatter =
      DateFormat('h:mm a'); // 12-hour format with AM/PM

  final int differenceInDays = dateTime.difference(DateTime.now()).inDays;

  if (differenceInDays == 0) {
    // Same day => "5:00 pm"
    return "Today at ${timeFormatter.format(dateTime).toLowerCase()}";
  } else if (differenceInDays == 1) {
    // Yesterday => "Yesterday at 5:00 pm"
    return "Yesterday at ${timeFormatter.format(dateTime).toLowerCase()}";
  } else if (differenceInDays < 7) {
    // Within last 7 days => "Tuesday 5:00 pm"
    final DateFormat weekdayFormatter = DateFormat('EEEE'); // e.g. "Tuesday"
    return "${weekdayFormatter.format(dateTime)} ${timeFormatter.format(dateTime).toLowerCase()}";
  } else {
    // Older => "1/20/25 5:00 pm"
    final DateFormat fullFormatter = DateFormat('M/d/yy h:mm a');
    return fullFormatter.format(dateTime).toLowerCase();
  }
}
