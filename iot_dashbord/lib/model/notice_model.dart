class Notice {
  final int id;
  final String content;
  final String createdAt;

  Notice({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt,
    };
  }

  Notice copyWith({
    int? id,
    String? content,
    String? createdAt,
  }) {
    return Notice(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
