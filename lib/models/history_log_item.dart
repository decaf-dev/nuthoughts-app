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

  ///Converts a thought to a map that can be saved in the database
  Map<String, dynamic> toMap() {
    return {
      'createdOn': createdOn,
      'eventType': eventType.name,
      'payload': payload,
    };
  }

  eventTypeString() {
    if (eventType == HistoryLogEvent.addThought) {
      return "Thought Added";
    } else if (eventType == HistoryLogEvent.deleteThought) {
      return "Thought Deleted";
    } else if (eventType == HistoryLogEvent.editThought) {
      return "Thought Edited";
    } else {
      return "Unknown";
    }
  }

  @override
  String toString() {
    return 'HistoryLogItem{id: $id, createdOn: $createdOn, eventType: $eventType, payload: $payload}';
  }
}
