class Alarm {
  final String timestamp;
  final String level;
  final String message;

  Alarm({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      timestamp: json['timestamp'],
      level: json['level'],
      message: json['message'],
    );
  }
}
