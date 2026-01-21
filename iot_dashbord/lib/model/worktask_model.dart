class WorkTask {
  final int id;
  final String title;
  final int progress;
  final String? startDate;
  final String? endDate;

  WorkTask({
    required this.id,
    required this.title,
    required this.progress,
    this.startDate,
    this.endDate,
  });

  // ✅ 여기에 copyWith 추가
  WorkTask copyWith({
    int? id,
    String? title,
    int? progress,
    String? startDate,
    String? endDate,
  }) {
    return WorkTask(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  factory WorkTask.fromJson(Map<String, dynamic> json) {
    return WorkTask(
      id: json['id'],
      title: json['title'],
      progress: json['progress'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'progress': progress,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
