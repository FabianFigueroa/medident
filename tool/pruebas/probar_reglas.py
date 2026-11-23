# -*- coding: utf-8 -*-
"""Pruebas de las reglas de Firestore (firestore.rules) contra Firebase Emulator Suite.

Cada caso inicia sesión con una cuenta de prueba del emulador, intenta una
operación por la API REST con el token de esa cuenta y compara el resultado
(permitido o denegado) con lo esperado. Nunca toca el Firebase real.

Requisitos: emuladores arriba (tool/pruebas/emuladores.ps1) con firebase.json
apuntando a firestore.rules, y datos base (python sembrar.py base).
Uso: python -X utf8 tool/pruebas/probar_reglas.py
"""
import json, sys, urllib.request, urllib.error
from datetime import datetime, timedelta, timezone
import sembrar as s

PADRE = f'projects/{s.PROYECTO}/databases/(default)/documents'
BASE = f'http://127.0.0.1:8080/v1/{PADRE}'
INTRUSO = 'intruso.prueba@medident-test.com'


def token(email):
    cuerpo = {'email': email, 'password': s.CLAVE, 'returnSecureToken': True}
    ok, r = llamar(None, 'POST', f'{s.AUTH}/accounts:signInWithPassword?key=demo', cuerpo)
    if not ok:
        ok, r = llamar(None, 'POST', f'{s.AUTH}/accounts:signUp?key=demo', cuerpo)
    return r['idToken'], r['localId']


def llamar(tok, method, url, body=None):
    data = json.dumps(body).encode() if body is not None else None
    h = {'Content-Type': 'application/json'}
    if tok:
        h['Authorization'] = 'Bearer ' + tok
    req = urllib.request.Request(url, data=data, method=method, headers=h)
    try:
        with urllib.request.urlopen(req) as resp:
            txt = resp.read().decode()
            return True, (json.loads(txt) if txt else {})
    except urllib.error.HTTPError as e:
        return False, e.read().decode()[:200]


def campos(d):
    return {'fields': {k: s.a_valor(v) for k, v in d.items()}}


def crear(tok, col, doc_id, datos):
    return llamar(tok, 'POST', f'{BASE}/{col}?documentId={doc_id}', campos(datos))


def actualizar(tok, ruta, datos):
    mask = '&'.join(f'updateMask.fieldPaths={k}' for k in datos)
    return llamar(tok, 'PATCH', f'{BASE}/{ruta}?{mask}', campos(datos))


def leer(tok, ruta):
    return llamar(tok, 'GET', f'{BASE}/{ruta}')


def consultar(tok, col, campo, valor):
    q = {'structuredQuery': {'from': [{'collectionId': col}], 'where': {'fieldFilter': {
        'field': {'fieldPath': campo}, 'op': 'EQUAL', 'value': s.a_valor(valor)}}}}
    ok, r = llamar(tok, 'POST', f'{BASE}:runQuery', q)
    if ok and isinstance(r, list) and r and 'error' in r[0]:
        return False, r[0]['error']
    return ok, r


def confirmar(tok, escrituras):
    return llamar(tok, 'POST', f'{BASE}:commit', {'writes': escrituras})


def escritura(ruta, datos):
    return {'update': {'name': f'{PADRE}/{ruta}', **campos(datos)}}


def main():
    try:
        s.ver(f'clinics/{s.CLINICA_ID}')
    except RuntimeError:
        s.base()
    u = s.uids()
    for ruta in ['appointments/reglas_cita1', 'appointments/reglas_cita2', 'appointment_slots/reglas_slot1',
                 'appointment_slots/reglas_slot2', 'turnos/reglas_turno1', 'turnos/reglas_turno2',
                 'turnos/reglas_turno3', 'turno_requests/reglas_sol1', 'turno_requests/reglas_sol2',
                 'notifications/reglas_aviso1', 'products/reglas_prod']:
        try:
            s.borrar(ruta)
        except RuntimeError:
            pass
    t_pac, _ = token('paciente.prueba@medident-test.com')
    t_odo, _ = token('odontologo.prueba@medident-test.com')
    t_emp, _ = token('empleado.prueba@medident-test.com')
    t_int, uid_int = token(INTRUSO)
    s.poner(f'users/{uid_int}', dict(uid=uid_int, email=INTRUSO, fullName='Intruso Prueba',
                                     role='patient', isClinicOwner=False, isActive=True))
    manana = datetime.now(timezone.utc) + timedelta(days=2)
    s.poner('turnos/turno_reglas', dict(clinicId=s.CLINICA_ID, dentistId=u['odontologo'],
                                        employeeId=u['empleado'], employeeName='Empleado Prueba',
                                        date=manana, startTime='08:00', endTime='17:00',
                                        status='scheduled', attendanceStatus='pending'))
    s.poner('notifications/aviso_empleado', dict(userId=u['empleado'], title='Aviso', body='x', isRead=False))
    s.poner('appointments/cita_otro_dentista', dict(dentistId='otro_dentista', patientId=u['paciente'],
                                                     status='pending', timeSlot='09:00', date=manana))

    cita = lambda pid: dict(clinicId=s.CLINICA_ID, patientId=pid, patientName='Paciente',
                            dentistId=u['odontologo'], treatmentName='Limpieza dental',
                            date=manana, timeSlot='15:00', status='pending')
    casos = [
        # (descripción, esperado, función)
        ('Paciente reserva su cita y bloquea la franja en la misma transacción', True,
         lambda: confirmar(t_pac, [escritura('appointments/reglas_cita1', cita(u['paciente'])),
                                   escritura('appointment_slots/reglas_slot1',
                                             dict(appointmentId='reglas_cita1', dentistId=u['odontologo'],
                                                  clinicId=s.CLINICA_ID, timeSlot='15:00'))])),
        ('Paciente crea una cita a nombre de otro paciente', False,
         lambda: crear(t_pac, 'appointments', 'reglas_cita2', cita(u['empleado']))),
        ('Bloqueo de franja que apunta a la cita de otro profesional', False,
         lambda: crear(t_pac, 'appointment_slots', 'reglas_slot2',
                       dict(appointmentId='cita_otro_dentista', dentistId=u['odontologo'], timeSlot='09:00'))),
        ('Odontólogo confirma la cita de su agenda', True,
         lambda: actualizar(t_odo, 'appointments/reglas_cita1', {'status': 'confirmed'})),
        ('Usuario ajeno cambia el estado de la cita', False,
         lambda: actualizar(t_int, 'appointments/reglas_cita1', {'status': 'cancelled'})),
        ('Paciente intenta cambiarse el rol a administrador', False,
         lambda: actualizar(t_pac, f'users/{u["paciente"]}', {'role': 'admin'})),
        ('Paciente actualiza su propio nombre', True,
         lambda: actualizar(t_pac, f'users/{u["paciente"]}', {'fullName': 'Ana Torres'})),
        ('Dueño de la clínica crea un turno para su empleado', True,
         lambda: crear(t_odo, 'turnos', 'reglas_turno1',
                       dict(clinicId=s.CLINICA_ID, dentistId=u['odontologo'], employeeId=u['empleado'],
                            employeeName='Empleado Prueba', date=manana, startTime='08:00',
                            endTime='12:00', status='scheduled'))),
        ('Usuario ajeno crea un turno en la clínica', False,
         lambda: crear(t_int, 'turnos', 'reglas_turno2',
                       dict(clinicId=s.CLINICA_ID, dentistId=u['odontologo'], employeeId=uid_int,
                            date=manana, startTime='08:00', endTime='12:00', status='scheduled'))),
        ('Empleado crea un turno', False,
         lambda: crear(t_emp, 'turnos', 'reglas_turno3',
                       dict(clinicId=s.CLINICA_ID, employeeId=u['empleado'], date=manana,
                            startTime='08:00', endTime='12:00', status='scheduled'))),
        ('Empleado confirma su asistencia', True,
         lambda: actualizar(t_emp, 'turnos/turno_reglas', {'attendanceStatus': 'confirmed'})),
        ('Empleado cambia la hora de su propio turno', False,
         lambda: actualizar(t_emp, 'turnos/turno_reglas', {'startTime': '10:00'})),
        ('Empleado consulta sus turnos (employeeId = él)', True,
         lambda: consultar(t_emp, 'turnos', 'employeeId', u['empleado'])),
        ('Dueño consulta los turnos de su clínica', True,
         lambda: consultar(t_odo, 'turnos', 'clinicId', s.CLINICA_ID)),
        ('Usuario ajeno consulta los turnos de la clínica', False,
         lambda: consultar(t_int, 'turnos', 'clinicId', s.CLINICA_ID)),
        ('Empleado envía una solicitud propia', True,
         lambda: crear(t_emp, 'turno_requests', 'reglas_sol1',
                       dict(turnoId='turno_reglas', employeeId=u['empleado'], employeeName='Empleado Prueba',
                            type='novelty', details='Llego tarde', status='pending', clinicId=s.CLINICA_ID))),
        ('Solicitud a nombre de otro empleado', False,
         lambda: crear(t_int, 'turno_requests', 'reglas_sol2',
                       dict(turnoId='turno_reglas', employeeId=u['empleado'], type='novelty',
                            status='pending', clinicId=s.CLINICA_ID))),
        ('Empleado aprueba su propia solicitud', False,
         lambda: actualizar(t_emp, 'turno_requests/reglas_sol1', {'status': 'approved'})),
        ('Dueño aprueba la solicitud', True,
         lambda: actualizar(t_odo, 'turno_requests/reglas_sol1', {'status': 'approved'})),
        ('Dueño deja un aviso al empleado', True,
         lambda: crear(t_odo, 'notifications', 'reglas_aviso1',
                       dict(userId=u['empleado'], title='Solicitud de Turno', body='Tu solicitud fue aprobada',
                            isRead=False))),
        ('Paciente lee un aviso de otra persona', False,
         lambda: leer(t_pac, 'notifications/aviso_empleado')),
        ('Empleado lee y marca su aviso', True,
         lambda: actualizar(t_emp, 'notifications/aviso_empleado', {'isRead': True})),
        ('Sin sesión: leer clínicas', False, lambda: leer(None, f'clinics/{s.CLINICA_ID}')),
        ('Con sesión: leer clínicas', True, lambda: leer(t_pac, f'clinics/{s.CLINICA_ID}')),
        ('Sin sesión: colección fuera del alcance (products)', False,
         lambda: crear(None, 'products', 'reglas_prod', dict(name='x'))),
    ]
    fallos = 0
    for i, (desc, esperado, f) in enumerate(casos, 1):
        ok, detalle = f()
        bien = ok == esperado
        fallos += not bien
        print(f'R-{i:02d} {"OK   " if bien else "FALLA"} esperado={"permite" if esperado else "niega"} '
              f'obtenido={"permite" if ok else "niega"} · {desc}' + ('' if bien else f' · {str(detalle)[:120]}'))
    print(f'\n{len(casos) - fallos}/{len(casos)} casos de reglas como se esperaba')
    sys.exit(1 if fallos else 0)


if __name__ == '__main__':
    main()
