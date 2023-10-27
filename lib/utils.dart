import 'package:nuthoughts/constants.dart' as constants;

String getRelativeTimeFromUTCTime(int time) {
  DateTime now = DateTime.now();
  int diff = now.millisecondsSinceEpoch - time;

  String value = "never";
  if (diff < constants.millisMinute) {
    value = "just now";
  } else if (diff < 2 * constants.millisMinute) {
    value = "1 minute ago";
  } else if (diff < 5 * constants.millisMinute) {
    value = "${(diff ~/ constants.millisMinute)} minutes ago";
  } else if (diff < constants.millisHour) {
    value = "${(diff ~/ (constants.millisMinute * 5)) * 5} minutes ago";
  } else if (diff < constants.millisHour * 2) {
    value = "${(diff ~/ constants.millisHour)} hour ago";
  } else if (diff < constants.millisDay) {
    value = "${(diff ~/ constants.millisHour)} hours ago";
  } else if (diff >= constants.millisDay) {
    value = "${(diff ~/ constants.millisDay)} days ago";
  }
  return value;
}
