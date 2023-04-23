import "dart:async";

import "package:get/get.dart";
import "package:nuthoughts/utils.dart";

class SyncTime {
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
    if (_lastSyncTime.value != 0) {
      syncString.value = getRelativeTimeFromUTCTime(_lastSyncTime.value);
    }
  }
}
