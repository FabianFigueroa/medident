class UserLightModel {
  final String id;
  final String name;
  final String fullName;
  final String? photoURL;
  final String role;
  final String? clinicId;
  final bool isActive;

  const UserLightModel({
    required this.id,
    required this.name,
    required this.fullName,
    this.photoURL,
    required this.role,
    this.clinicId,
    this.isActive = true,
  });

  factory UserLightModel.fromJson(Map<String, dynamic> map, String id) {
    final fullName = (map['fullName'] ?? map['name'] ?? '').toString();
    return UserLightModel(
      id: id,
      name: (map['name'] ?? fullName).toString(),
      fullName: fullName,
      photoURL: map['photoURL'] ?? map['imageUrl'],
      role: map['role'] ?? 'client',
      clinicId: map['clinicId'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'photoURL': photoURL,
      'role': role,
      'clinicId': clinicId,
      'isActive': isActive,
    };
  }
}
