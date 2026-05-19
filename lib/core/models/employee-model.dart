import 'package:cloud_firestore/cloud_firestore.dart';

/// Cargos disponibles dentro de una clínica
class EmployeePositions {
  static const List<String> all = [
    'jefe_de_clinica',
    'odontologo_planta',
    'medico_turno',
    'limpiadora',
    'higienista',
    'recepcionista',
    'endodoncista',
    'bacteriologo',
    'asesor',
    'medico_general',
    'cardiologo',
    'intensivista',
    'psiquiatra',
    'cirujano_oral',
    'ortodoncista',
    'anestesiologo',
    'auxiliar_odontologia',
    'enfermero',
    'director_medico',
    'coordinador',
  ];

  static String displayName(String position) {
    switch (position) {
      case 'jefe_de_clinica': return 'Jefe de Clínica';
      case 'odontologo_planta': return 'Odontólogo de Planta';
      case 'medico_turno': return 'Médico de Turno';
      case 'limpiadora': return 'Limpiadora';
      case 'higienista': return 'Higienista';
      case 'recepcionista': return 'Recepcionista';
      case 'endodoncista': return 'Endodoncista';
      case 'bacteriologo': return 'Bacteriólogo';
      case 'asesor': return 'Asesor';
      case 'medico_general': return 'Médico General';
      case 'cardiologo': return 'Cardiólogo';
      case 'intensivista': return 'Intensivista';
      case 'psiquiatra': return 'Psiquiatra';
      case 'cirujano_oral': return 'Cirujano Oral';
      case 'ortodoncista': return 'Ortodoncista';
      case 'anestesiologo': return 'Anestesiólogo';
      case 'auxiliar_odontologia': return 'Auxiliar de Odontología';
      case 'enfermero': return 'Enfermero';
      case 'director_medico': return 'Director Médico';
      case 'coordinador': return 'Coordinador';
      default: return position;
    }
  }
}

class EmployeeModel {
  final String uid;
  final String fullName;
  final String? imageUrl;
  final String position;
  final bool isActive;
  final bool hasSecurityAccess;
  final String? rfidUid;
  final String? contractType;
  final DateTime? hiredAt;
  final num? salary;

  const EmployeeModel({
    required this.uid,
    required this.fullName,
    this.imageUrl,
    this.position = 'medico_general',
    this.isActive = true,
    this.hasSecurityAccess = false,
    this.rfidUid,
    this.contractType,
    this.hiredAt,
    this.salary,
  });

  String get positionDisplay => EmployeePositions.displayName(position);

  factory EmployeeModel.fromJson(Map<String, dynamic> map, String uid) => EmployeeModel(
    uid: uid,
    fullName: map['fullName'] as String? ?? '',
    imageUrl: map['imageUrl'] as String?,
    position: map['position'] as String? ?? 'medico_general',
    isActive: map['isActive'] as bool? ?? true,
    hasSecurityAccess: map['hasSecurityAccess'] as bool? ?? false,
    rfidUid: map['rfidUid'] as String?,
    contractType: map['contractType'] as String?,
    hiredAt: (map['hiredAt'] as Timestamp?)?.toDate(),
    salary: map['salary'] as num?,
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'fullName': fullName,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'position': position,
    'isActive': isActive,
    'hasSecurityAccess': hasSecurityAccess,
    if (rfidUid != null) 'rfidUid': rfidUid,
    if (contractType != null) 'contractType': contractType,
    if (hiredAt != null) 'hiredAt': Timestamp.fromDate(hiredAt!),
    if (salary != null) 'salary': salary,
  };

  EmployeeModel copyWith({
    String? uid,
    String? fullName,
    String? imageUrl,
    String? position,
    bool? isActive,
    bool? hasSecurityAccess,
    String? rfidUid,
    String? contractType,
    DateTime? hiredAt,
    num? salary,
  }) => EmployeeModel(
    uid: uid ?? this.uid,
    fullName: fullName ?? this.fullName,
    imageUrl: imageUrl ?? this.imageUrl,
    position: position ?? this.position,
    isActive: isActive ?? this.isActive,
    hasSecurityAccess: hasSecurityAccess ?? this.hasSecurityAccess,
    rfidUid: rfidUid ?? this.rfidUid,
    contractType: contractType ?? this.contractType,
    hiredAt: hiredAt ?? this.hiredAt,
    salary: salary ?? this.salary,
  );
}
