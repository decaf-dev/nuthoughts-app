import 'package:nuthoughts/constants.dart';

class HistoryLogItem {
  //-1 because sqlite doesn't allow null values
  int id = -1;
  final HistoryLogEvent eventType;
  final String payload;
  late int creationTime;

  HistoryLogItem(this.eventType, this.payload) {
    creationTime = DateTime.now().millisecondsSinceEpoch;
  }

  HistoryLogItem.fromDatabase(Map<String, dynamic> map)
      : id = map['id'],
        creationTime = map['creationTime'],
        eventType = HistoryLogEvent.values.byName(map['eventType']),
        payload = map['payload'];

  @override
  String toString() {
    return 'HistoryLogItem{id: $id, creationTime: $creationTime, eventType: $eventType, payload: $payload}';
  }
}
