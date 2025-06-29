class Alarm {
  final int id; // 🔹 추가된 필드
  final String timestamp;
  final String level;
  final String message;

  Alarm({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw Exception('Alarm.fromJson 오류: id가 null입니다. JSON: $json');
    }

    return Alarm(
      id: json['id'] as int,
      timestamp: json['timestamp'] ?? '',
      level: json['level'] ?? '',
      message: json['message'] ?? '',
    );
  }


  // ✅ copyWith 메서드 추가
  Alarm copyWith({
    int? id,
    String? timestamp,
    String? level,
    String? message,
  }) {
    return Alarm(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      message: message ?? this.message,
    );
  }

  // ✅ (선택) toJson도 필요한 경우
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'level': level,
      'message': message,
    };
  }
}
