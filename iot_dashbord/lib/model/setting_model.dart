class SiteSetting {
  final String title;
  final String logoUrl;

  SiteSetting({required this.title, required this.logoUrl});

  factory SiteSetting.fromJson(Map<String, dynamic> json) {
    return SiteSetting(
      title: json['Title'] ?? '',
      logoUrl: json['LogoUrl'] ?? '',
    );
  }
}

class SettingUploadResult {
  final bool success;
  final String message;

  SettingUploadResult({required this.success, required this.message});
}
