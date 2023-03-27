import "package:get/get.dart";

class SyncTime {
  Rx<int> time = 0.obs;

  void updateSyncTime() {
    time.value = DateTime.now().millisecondsSinceEpoch;
  }

  String getSyncTimeString() {
    if (time.value != 0) {
      DateTime now = DateTime.now();
      int diff = now.millisecondsSinceEpoch - time.value;
      if (diff < 1000 * 60 * 60) {
        return "${(diff ~/ (1000 * 60))} minutes ago";
      } else {
        return "${(diff ~/ (1000 * 60 * 60))} hours ago";
      }
    }
    return "never";
  }
}
