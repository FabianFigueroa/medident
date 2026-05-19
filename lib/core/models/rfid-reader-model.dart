class RfidReaderModel {
  final String readerId;
  final String id;
  final String location;
  final bool hasCamera;
  final String? cameraId;
  final bool isOnline;
  final bool isActive;
  final String? ipAddress;
  final DateTime? lastScan;
  final String type;

  const RfidReaderModel({
    required this.readerId,
    String? id,
    required this.location,
    this.hasCamera = false,
    this.cameraId,
    this.isOnline = false,
    bool? isActive,
    this.ipAddress,
    this.lastScan,
    this.type = 'entrance',
  })  : id = id ?? readerId,
        isActive = isActive ?? isOnline;

  factory RfidReaderModel.fromMap(Map<String, dynamic> map) {
    return RfidReaderModel(
      readerId: map['readerId'] ?? '',
      location: map['location'] ?? '',
      hasCamera: map['hasCamera'] ?? false,
      cameraId: map['cameraId'],
      isOnline: map['isOnline'] ?? false,
      ipAddress: map['ipAddress'],
      lastScan: map['lastScan'] is DateTime
          ? map['lastScan']
          : null,
      type: map['type'] ?? 'entrance',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'readerId': readerId,
      'location': location,
      'hasCamera': hasCamera,
      'cameraId': cameraId,
      'isOnline': isOnline,
      'ipAddress': ipAddress,
      'lastScan': lastScan,
      'type': type,
    };
  }

  RfidReaderModel copyWith({
    String? readerId,
    String? id,
    String? location,
    bool? hasCamera,
    String? cameraId,
    bool? isOnline,
    bool? isActive,
    String? ipAddress,
    DateTime? lastScan,
    String? type,
  }) {
    return RfidReaderModel(
      readerId: readerId ?? this.readerId,
      location: location ?? this.location,
      hasCamera: hasCamera ?? this.hasCamera,
      cameraId: cameraId ?? this.cameraId,
      isOnline: isOnline ?? this.isOnline,
      isActive: isActive ?? this.isActive,
      ipAddress: ipAddress ?? this.ipAddress,
      lastScan: lastScan ?? this.lastScan,
      type: type ?? this.type,
    );
  }
}
