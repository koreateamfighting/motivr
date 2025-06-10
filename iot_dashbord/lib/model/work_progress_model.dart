// models/work_progress.dart
class WorkProgress {
  final double progress;
  WorkProgress({required this.progress});

  factory WorkProgress.fromJson(Map<String, dynamic> json) {
    return WorkProgress(progress: json['progress'] * 1.0);
  }
}
