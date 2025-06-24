class Duty {
  final int id;
  final String dutyName;
  final DateTime startDate;
  final DateTime endDate;
  final int progress;

  Duty({
    required this.id,
    required this.dutyName,
    required this.startDate,
    required this.endDate,
    required this.progress,
  });

  factory Duty.fromJson(Map<String, dynamic> json) {
    return Duty(
      id: json['Id'],
      dutyName: json['DutyName'],
      startDate: DateTime.parse(json['StartDate']),
      endDate: DateTime.parse(json['EndDate']),
      progress: json['Progress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'DutyName': dutyName,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'Progress': progress,
    };
  }
}
