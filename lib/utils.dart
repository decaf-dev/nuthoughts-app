const millisMinute = 1000 * 60;
const millisHour = millisMinute * 60;
const millisDay = millisHour * 24;

String getRelativeTimeFromUTCTime(int time) {
  DateTime now = DateTime.now();
  int diff = now.millisecondsSinceEpoch - time;

  String value = "never";
  if (diff < millisMinute) {
    value = "just now";
  } else if (diff < 2 * millisMinute) {
    value = "1 minute ago";
  } else if (diff < 5 * millisMinute) {
    value = "${(diff ~/ millisMinute)} minutes ago";
  } else if (diff < millisHour) {
    value = "${(diff ~/ (millisMinute * 5)) * 5} minutes ago";
  } else if (diff < millisHour * 2) {
    value = "${(diff ~/ millisHour)} hour ago";
  } else if (diff < millisDay) {
    value = "${(diff ~/ millisHour)} hours ago";
  } else if (diff >= millisDay) {
    value = "${(diff ~/ millisDay)} days ago";
  }
  return value;
}
