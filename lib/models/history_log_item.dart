import 'package:nuthoughts/constants.dart';

class HistoryLogItem {
  //-1 because sqlite doesn't allow null values
  int id = -1;
  final HistoryLogEvent eventType;
  final String payload;
  late int createdOn;

  HistoryLogItem(this.eventType, this.payload) {
    createdOn = DateTime.now().millisecondsSinceEpoch;
  }

  HistoryLogItem.fromDatabase(Map<String, dynamic> map)
      : id = map['id'],
        createdOn = map['createdOn'],
        eventType = HistoryLogEvent.values.byName(map['eventType']),
        payload = map['payload'];

  @override
  String toString() {
    return 'HistoryLogItem{id: $id, createdOn: $createdOn, eventType: $eventType, payload: $payload}';
  }
}
