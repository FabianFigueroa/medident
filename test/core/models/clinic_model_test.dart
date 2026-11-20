import 'package:flutter_test/flutter_test.dart';
import 'package:medident/core/models/clinic-model.dart';

void main() {
  group('ClinicModel', () {
    final map = <String, dynamic>{
      'name': 'Clínica Medident',
      'ownerId': 'user-1',
      'nit': '900123456-7',
      'address': 'Calle 1',
      'phone': '3000000000',
      'email': 'clinica@medident.com',
      'logoUrl': 'https://example.com/logo.png',
      'primaryColor': '#0EA5A4',
      'apiKey': 'CLINIC-KEY-1',
      'employeeIds': ['user-1', 'user-2'],
      'isActive': true,
      'description': 'Odontología',
    };

    test('fromMap conserva la identidad propia de la clínica', () {
      final clinic = ClinicModel.fromMap(map, 'clinic-1');

      expect(clinic.id, 'clinic-1');
      expect(clinic.name, 'Clínica Medident');
      expect(clinic.ownerId, 'user-1');
      expect(clinic.apiKey, 'CLINIC-KEY-1');
      expect(clinic.logoUrl, 'https://example.com/logo.png');
      expect(clinic.employeeIds, ['user-1', 'user-2']);
      expect(clinic.isActive, isTrue);
    });

    test('fromMap usa valores por defecto seguros', () {
      final clinic = ClinicModel.fromMap(<String, dynamic>{}, 'clinic-2');

      expect(clinic.name, '');
      expect(clinic.ownerId, '');
      expect(clinic.nit, '');
      expect(clinic.apiKey, '');
      expect(clinic.employeeIds, isEmpty);
      expect(clinic.isActive, isTrue);
    });

    test('copyWith actualiza solo los campos indicados', () {
      final clinic = ClinicModel.fromMap(map, 'clinic-1');
      final updated = clinic.copyWith(name: 'Nueva Clínica');

      expect(updated.name, 'Nueva Clínica');
      expect(updated.ownerId, clinic.ownerId);
      expect(updated.apiKey, clinic.apiKey);
      expect(updated.logoUrl, clinic.logoUrl);
    });

    test('toMap no incluye el id pero sí apiKey y ownerId', () {
      final clinic = ClinicModel.fromMap(map, 'clinic-1');
      final data = clinic.toMap();

      expect(data.containsKey('id'), isFalse);
      expect(data['apiKey'], 'CLINIC-KEY-1');
      expect(data['ownerId'], 'user-1');
      expect(data['name'], 'Clínica Medident');
    });
  });
}
