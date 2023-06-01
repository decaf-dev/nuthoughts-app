import 'dart:math';

import 'package:nuthoughts/constants.dart';

String getRelativeTimeFromUTCTime(int time) {
  DateTime now = DateTime.now();
  int diff = now.millisecondsSinceEpoch - time;

  String value = "never";
  if (diff < Constants.millisMinute) {
    value = "just now";
  } else if (diff < 2 * Constants.millisMinute) {
    value = "1 minute ago";
  } else if (diff < 5 * Constants.millisMinute) {
    value = "${(diff ~/ Constants.millisMinute)} minutes ago";
  } else if (diff < Constants.millisHour) {
    value = "${(diff ~/ (Constants.millisMinute * 5)) * 5} minutes ago";
  } else if (diff < Constants.millisHour * 2) {
    value = "${(diff ~/ Constants.millisHour)} hour ago";
  } else if (diff < Constants.millisDay) {
    value = "${(diff ~/ Constants.millisHour)} hours ago";
  } else if (diff >= Constants.millisDay) {
    value = "${(diff ~/ Constants.millisDay)} days ago";
  }
  return value;
}

int generateRandomUUID() {
  Random random = Random.secure();
  String uuid = '';

  for (int i = 0; i < 32; i++) {
    int randomNumber =
        random.nextInt(10); // Generates a random number between 0 and 9
    uuid += randomNumber.toString();
  }

  return int.parse(uuid);
}
