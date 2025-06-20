class IotItem {
  final String id;
  final String type;
  final String location;
  final String status;
  final String battery;
  final String lastUpdated;
  final String X_MM;
  final String Y_MM;
  final String Z_MM;
  final String X_Deg;
  final String Y_Deg;
  final String Z_Deg;
  final String batteryInfo;
  final String download;

  IotItem({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.battery,
    required this.lastUpdated,
    required this.X_MM,
    required this.Y_MM,
    required this.Z_MM,
    required this.X_Deg,
    required this.Y_Deg,
    required this.Z_Deg,

    required this.batteryInfo,
    required this.download,
  });

  factory IotItem.fromJson(Map<String, dynamic> json) {
    return IotItem(
      id: json['id'],
      type: json['type'],
      location: json['location'],
      status: json['status'],
      battery: json['battery'],
      lastUpdated: json['lastUpdated'],
      X_MM: json['X(mm)'].toString(),
      Y_MM: json['Y(mm)'].toString(),
      Z_MM: json['Z(mm)'].toString(),
      X_Deg: json['X_Deg'].toString(),
      Y_Deg: json['Y_Deg'].toString(),
      Z_Deg: json['Z_Deg'].toString(),
      batteryInfo: json['batteryInfo'],
      download: json['download'],
    );
  }

}
