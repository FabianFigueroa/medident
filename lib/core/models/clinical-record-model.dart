class ClinicalRecord {
  final String id;
  final String patientId;
  final String dentistName;
  final DateTime date;
  final String? diagnosis;
  final String? treatment;
  final String? procedure;
  final String? notes;
  final List<String> attachments;
  final String? odontogramId;

  ClinicalRecord({
    required this.id,
    required this.patientId,
    required this.dentistName,
    required this.date,
    this.diagnosis,
    this.treatment,
    this.procedure,
    this.notes,
    this.attachments = const [],
    this.odontogramId,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'dentistName': dentistName,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'treatment': treatment,
      'procedure': procedure,
      'notes': notes,
      'attachments': attachments,
      'odontogramId': odontogramId,
    };
  }

  factory ClinicalRecord.fromMap(Map<String, dynamic> map, String id) {
    return ClinicalRecord(
      id: id,
      patientId: map['patientId'] ?? '',
      dentistName: map['dentistName'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      diagnosis: map['diagnosis'],
      treatment: map['treatment'],
      procedure: map['procedure'],
      notes: map['notes'],
      attachments: map['attachments'] != null ? List<String>.from(map['attachments']) : [],
      odontogramId: map['odontogramId'],
    );
  }
}
