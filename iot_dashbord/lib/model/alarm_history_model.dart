class AlarmHistory {
  final int? id;
  final String deviceId;
  final DateTime timestamp;
  final String event;
  final String? log;
  final String? label;
  final double? latitude;
  final double? longitude;
  final String type; // 'iot' 또는 'cctv'

  AlarmHistory({
    this.id,
    required this.deviceId,
    required this.timestamp,
    required this.event,
    this.log,
    this.label,
    this.latitude,
    this.longitude,
    required this.type,
  });

  factory AlarmHistory.fromJson(Map<String, dynamic> json) {
    return AlarmHistory(
      id: json['Id'],
      deviceId: json['DeviceID'] ?? '',
      timestamp: DateTime.parse(json['Timestamp']),
      event: json['Event'] ?? '',
      log: json['Log'],
      label: json['Label'],
      latitude: (json['Latitude'] is num) ? (json['Latitude'] as num).toDouble() : null,
      longitude: (json['Longitude'] is num) ? (json['Longitude'] as num).toDouble() : null,
      type: json['Type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'Id': id, // ⬅️ id 포함 (있을 때만 전송)
      'DeviceID': deviceId,
      'Timestamp': timestamp.toIso8601String(),
      'Event': event,
      'Log': log,
      'Label': label,
      'Latitude': latitude,
      'Longitude': longitude,
      'Type': type,
    };
  }
  AlarmHistory copyWith({
    int? id,
    String? deviceId,
    DateTime? timestamp,
    String? event,
    String? log,
    String? label,
    double? latitude,
    double? longitude,
    String? type,
  }) {
    return AlarmHistory(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      event: event ?? this.event,
      log: log ?? this.log,
      label: label ?? this.label,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
    );
  }
}
