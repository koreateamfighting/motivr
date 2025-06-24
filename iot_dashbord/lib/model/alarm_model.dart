class Alarm {
  final String timestamp;
  final String level;
  final String? sensorId; // nullable 로 변경
  final String message;

  Alarm({
    required this.timestamp,
    required this.level,
    this.sensorId, // nullable
    required this.message,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      timestamp: json['timestamp'],
      level: json['level'],
      sensorId: json['sensor_id'], // null이면 null로 처리됨
      message: json['message'],
    );
  }
}
