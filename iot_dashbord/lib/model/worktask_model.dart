class WorkTask {
  final int id;
  final String title;
  final int progress;
  final String? startDate;
  final String? endDate;
  final String createdAt;

  WorkTask({
    required this.id,
    required this.title,
    required this.progress,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory WorkTask.fromJson(Map<String, dynamic> json) {
    return WorkTask(
      id: json['id'],
      title: json['title'],
      progress: json['progress'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdAt: json['created_at'],
    );
  }
}
