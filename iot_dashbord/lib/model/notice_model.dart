class Notice {
  final int id;
  final String content;
  final String createdAt;

  Notice({
    required this.id,
    required this.content,
    required this.createdAt,
  });
  // ✅ 여기에 copyWith 추가
  Notice copyWith({
    int? id,
    String? content,
    String? createdAt,

  }) {
    return Notice(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt:createdAt ?? this.createdAt,

    );
  }
  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }
}
