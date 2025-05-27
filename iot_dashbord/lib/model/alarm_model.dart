class Alarm {
  final String timestamp;
  final String level;
  final String sensorId;
  final String message;

  Alarm({
    required this.timestamp,
    required this.level,
    required this.sensorId,
    required this.message,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      timestamp: json['timestamp'],
      level: json['level'],
      sensorId: json['sensor_id'],
      message: json['message'],
    );
  }
}
