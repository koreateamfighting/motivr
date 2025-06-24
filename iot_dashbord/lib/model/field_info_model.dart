class FieldInfo {
  final int id;
  final String constructionType;
  final String constructionName;
  final String address;
  final String company;
  final String orderer;
  final String location;
  final String startDate;
  final String endDate;
  final String latitude;
  final String longitude;

  FieldInfo({
    required this.id,
    required this.constructionType,
    required this.constructionName,
    required this.address,
    required this.company,
    required this.orderer,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.latitude,
    required this.longitude,
  });

  factory FieldInfo.fromJson(Map<String, dynamic> json) {
    return FieldInfo(
      id: json['Id'] ?? 0,
      constructionType: json['ConstructionType'] ?? '',
      constructionName: json['ConstructionName'] ?? '',
      address: json['Address'] ?? '',
      company: json['Company'] ?? '',
      orderer: json['Orderer'] ?? '',
      location: json['Location'] ?? '',
      startDate: json['StartDate'] ?? '',
      endDate: json['EndDate'] ?? '',
      latitude: json['Latitude'] != null ? json['Latitude'].toString() : '',
      longitude: json['Longitude'] != null ? json['Longitude'].toString() : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ConstructionType': constructionType,
      'ConstructionName': constructionName,
      'Address': address,
      'Company': company,
      'Orderer': orderer,
      'Location': location,
      'StartDate': startDate,
      'EndDate': endDate,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}
