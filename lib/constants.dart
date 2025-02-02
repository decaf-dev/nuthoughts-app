const ipAddressKey = "ip-address";
const portKey = "port";
const textKey = "text";

const millisMinute = 1000 * 60;
const millisHour = millisMinute * 60;
const millisDay = millisHour * 24;

enum HistoryLogEvent {
  editThought,
  addThought,
  deleteThought,
}

const defaultIpAddress = 'localhost';
const defaultPort = '8123';
