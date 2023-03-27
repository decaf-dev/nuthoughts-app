import "package:get/get.dart";

class SyncTime {
  final _minute = 1000 * 60;
  final _hour = 1000 * 60 * 60;
  final _day = 1000 * 60 * 60 * 24;

  final _lastSyncTime = 0.obs;
  final syncString = 'never'.obs;

  void updateSyncTime() {
    _lastSyncTime.value = DateTime.now().millisecondsSinceEpoch;
  }

  void refreshSyncDisplay() {
    String value = "never";
    if (_lastSyncTime.value != 0) {
      DateTime now = DateTime.now();
      int diff = now.millisecondsSinceEpoch - _lastSyncTime.value;
      if (diff < _minute) {
        value = "just now";
      } else if (diff < 2 * _minute) {
        value = "1 minute ago";
      } else if (diff < 5 * _minute) {
        value = "${(diff ~/ (_minute))} minutes ago";
      } else if (diff < _hour) {
        value = "${(diff ~/ (_minute * 5))} minutes ago";
      } else if (diff < _day) {
        value = "${(diff ~/ _hour)} hours ago";
      } else if (diff >= _day) {
        value = "${(diff ~/ _day)} days ago";
      }
    }
    syncString.value = value;
  }
}
