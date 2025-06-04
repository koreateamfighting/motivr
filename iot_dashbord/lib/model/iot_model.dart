class IotItem {
  final String id;
  final String type;
  final String location;
  final String status;
  final String battery;
  final String lastUpdated;
  final dynamic x;
  final dynamic y;
  final dynamic z;
  final String incline;
  final String batteryInfo;
  final String download;

  IotItem({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.battery,
    required this.lastUpdated,
    required this.x,
    required this.y,
    required this.z,
    required this.incline,
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
      x: json['x'],
      y: json['y'],
      z: json['z'],
      incline: json['incline'],
      batteryInfo: json['batteryInfo'],
      download: json['download'],
    );
  }
}
