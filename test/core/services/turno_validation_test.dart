import 'package:flutter_test/flutter_test.dart';
import 'package:medident/core/services/clinic-service.dart';

void main() {
  group('validateTurno (RN-19 y RN-20)', () {
    test('acepta un turno de un empleado registrado con fin posterior al inicio', () {
      expect(validateTurno(employeeId: 'uid_empleado', startTime: '08:00', endTime: '17:00'), isNull);
    });

    test('rechaza fin igual al inicio (límite inválido)', () {
      expect(validateTurno(employeeId: 'uid_empleado', startTime: '08:00', endTime: '08:00'),
          'La hora de fin debe ser posterior a la de inicio.');
    });

    test('acepta fin un minuto después del inicio (límite válido)', () {
      expect(validateTurno(employeeId: 'uid_empleado', startTime: '08:00', endTime: '08:01'), isNull);
    });

    test('rechaza fin anterior al inicio', () {
      expect(validateTurno(employeeId: 'uid_empleado', startTime: '17:00', endTime: '08:00'),
          'La hora de fin debe ser posterior a la de inicio.');
    });

    test('rechaza un turno sin empleado registrado', () {
      expect(validateTurno(employeeId: null, startTime: '08:00', endTime: '17:00'),
          'Elige un empleado registrado de la clínica.');
      expect(validateTurno(employeeId: 'manual_123', startTime: '08:00', endTime: '17:00'),
          'Elige un empleado registrado de la clínica.');
    });

    test('rechaza horas mal formadas', () {
      expect(validateTurno(employeeId: 'uid_empleado', startTime: '8', endTime: '25:00'),
          'Las horas deben tener el formato HH:MM.');
    });
  });

  group('validateHorario (solicitud de cambio de horario)', () {
    test('acepta 10:00 a 19:00', () {
      expect(validateHorario('10:00', '19:00'), isNull);
    });
    test('rechaza texto libre en la hora', () {
      expect(validateHorario('o en la manana', '19:00'), 'Las horas deben tener el formato HH:MM.');
    });
    test('rechaza fin igual al inicio', () {
      expect(validateHorario('10:00', '10:00'), 'La hora de fin debe ser posterior a la de inicio.');
    });
  });

  test('SlotTakenException explica qué franja está ocupada', () {
    expect(const SlotTakenException('10:00').message,
        'La franja de las 10:00 ya está ocupada para ese profesional. Elige otra hora.');
  });
}
