import "dart:async";

import "package:get/get.dart";

class SyncTime {
  final _minute = 1000 * 60;
  final _hour = 1000 * 60 * 60;
  final _day = 1000 * 60 * 60 * 24;

  final _lastSyncTime = 0.obs;
  final syncString = 'never'.obs;
  Timer? _timer;

  void updateSyncTime() {
    _lastSyncTime.value = DateTime.now().millisecondsSinceEpoch;
    restartTimer();
  }

  void restartTimer() {
    _refreshSyncDisplay();
    cancelTimer();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (Timer timer) async {
        _refreshSyncDisplay();
      },
    );
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  void dispose() {
    cancelTimer();
  }

  void _refreshSyncDisplay() {
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
        value = "${(diff ~/ (_minute * 5)) * 5} minutes ago";
      } else if (diff < _hour * 2) {
        value = "${(diff ~/ _hour)} hour ago";
      } else if (diff < _day) {
        value = "${(diff ~/ _hour)} hours ago";
      } else if (diff >= _day) {
        value = "${(diff ~/ _day)} days ago";
      }
    }
    syncString.value = value;
  }
}
