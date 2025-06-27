class AlarmHistory {
  final String deviceId;
  final DateTime timestamp;
  final String event;
  final String? log;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String type; // 'iot' 또는 'cctv'

  AlarmHistory({
    required this.deviceId,
    required this.timestamp,
    required this.event,
    this.log,
    this.location,
    this.latitude,
    this.longitude,
    required this.type,
  });

  factory AlarmHistory.fromJson(Map<String, dynamic> json) {
    return AlarmHistory(
      deviceId: json['DeviceID'] ?? '',
      timestamp: DateTime.parse(json['Timestamp']),
      event: json['Event'] ?? '',
      log: json['Log'],
      location: json['Location'],
      latitude: (json['Latitude'] is num) ? (json['Latitude'] as num).toDouble() : null,
      longitude: (json['Longitude'] is num) ? (json['Longitude'] as num).toDouble() : null,
      type: json['Type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DeviceID': deviceId,
      'Timestamp': timestamp.toIso8601String(),
      'Event': event,
      'Log': log,
      'Location': location,
      'Latitude': latitude,
      'Longitude': longitude,
      'Type': type,
    };
  }
}
