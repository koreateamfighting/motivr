// cctv_model.dart
class CctvItem {
  final int id;
  final String camId;
  final String location;
  final bool isConnected;
  final String eventState;
  final double imageAnalysis;
  final String streamUrl;
  final DateTime lastRecorded;
  final String recordPath;

  CctvItem({
    required this.id,
    required this.camId,
    required this.location,
    required this.isConnected,
    required this.eventState,
    required this.imageAnalysis,
    required this.streamUrl,
    required this.lastRecorded,
    required this.recordPath,
  });

  factory CctvItem.fromJson(Map<String, dynamic> json) {
    return CctvItem(
      id: json['Id'],
      camId: json['CamID'],
      location: json['Location'] ?? '',
      isConnected: json['IsConnected'] == true,
      eventState: json['EventState'] ?? '',
      imageAnalysis: (json['ImageAnalysis'] ?? 0).toDouble(),
      streamUrl: json['StreamURL'] ?? '',
      lastRecorded: DateTime.parse(json['LastRecorded']),
      recordPath: json['RecordPath'] ?? '',
    );
  }
}
