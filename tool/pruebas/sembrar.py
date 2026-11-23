# -*- coding: utf-8 -*-
"""Datos de prueba del plan de pruebas de MEDIDENT, SOLO para Firebase Emulator Suite.

Escribe en los emuladores locales (Auth 127.0.0.1:9099, Firestore 127.0.0.1:8080).
Nunca apunta al Firebase real. Uso:
  python sembrar.py base                   # clínica, cuentas, tratamiento, vínculo del empleado
  python sembrar.py caso CP-04             # documentos sembrados que pide un caso
  python sembrar.py ver users/<uid>        # muestra un documento
  python sembrar.py listar turnos [campo=valor ...]
  python sembrar.py borrar <ruta>
"""
import json, sys, urllib.request, urllib.error
from datetime import datetime, timedelta, timezone

PROYECTO = 'ips-medident'
AUTH = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1'
FS = f'http://127.0.0.1:8080/v1/projects/{PROYECTO}/databases/(default)/documents'
BOGOTA = timezone(timedelta(hours=-5))
CLAVE = 'Medident#2026'          # contraseña de prueba común (solo emulador)
CLINICA_ID = 'clinica_prueba'

CUENTAS = {
    'odontologo': dict(email='odontologo.prueba@medident-test.com', fullName='Odontólogo Prueba', role='dentist', isClinicOwner=True),
    'paciente':   dict(email='paciente.prueba@medident-test.com',   fullName='Paciente Prueba Uno', role='patient', isClinicOwner=False),
    'empleado':   dict(email='empleado.prueba@medident-test.com',   fullName='Empleado Prueba',     role='employee', isClinicOwner=False),
}


def _req(method, url, body=None, headers=None):
    data = json.dumps(body).encode() if body is not None else None
    h = {'Content-Type': 'application/json', 'Authorization': 'Bearer owner'}
    h.update(headers or {})
    r = urllib.request.Request(url, data=data, method=method, headers=h)
    try:
        with urllib.request.urlopen(r) as resp:
            txt = resp.read().decode()
            return json.loads(txt) if txt else {}
    except urllib.error.HTTPError as e:
        raise RuntimeError(f'{method} {url}: {e.code} {e.read().decode()[:300]}')


def a_valor(v):
    if v is None: return {'nullValue': None}
    if isinstance(v, bool): return {'booleanValue': v}
    if isinstance(v, int): return {'integerValue': str(v)}
    if isinstance(v, float): return {'doubleValue': v}
    if isinstance(v, datetime): return {'timestampValue': v.astimezone(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%fZ')}
    if isinstance(v, (list, tuple)): return {'arrayValue': {'values': [a_valor(x) for x in v]}}
    if isinstance(v, dict): return {'mapValue': {'fields': {k: a_valor(x) for k, x in v.items()}}}
    return {'stringValue': str(v)}


def de_valor(v):
    (t, x), = v.items()
    if t == 'mapValue': return {k: de_valor(y) for k, y in x.get('fields', {}).items()}
    if t == 'arrayValue': return [de_valor(y) for y in x.get('values', [])]
    if t == 'integerValue': return int(x)
    if t == 'timestampValue':
        return datetime.fromisoformat(x.replace('Z', '+00:00')).astimezone(BOGOTA).strftime('%Y-%m-%d %H:%M:%S (Bogotá)')
    return x


def poner(ruta, campos):
    _req('PATCH', f'{FS}/{ruta}', {'fields': {k: a_valor(v) for k, v in campos.items()}})


def ver(ruta):
    d = _req('GET', f'{FS}/{ruta}')
    return {k: de_valor(v) for k, v in d.get('fields', {}).items()}


def listar(coleccion, **filtros):
    out, token = [], None
    while True:
        url = f'{FS}/{coleccion}?pageSize=300' + (f'&pageToken={token}' if token else '')
        d = _req('GET', url)
        for doc in d.get('documents', []):
            campos = {k: de_valor(v) for k, v in doc.get('fields', {}).items()}
            if all(str(campos.get(k)) == v for k, v in filtros.items()):
                out.append((doc['name'].split('/documents/')[1], campos))
        token = d.get('nextPageToken')
        if not token:
            return out


def borrar(ruta):
    _req('DELETE', f'{FS}/{ruta}')


def uid_de(email):
    try:
        r = _req('POST', f'{AUTH}/accounts:signUp?key=demo', {'email': email, 'password': CLAVE, 'returnSecureToken': True})
    except RuntimeError as e:
        if 'EMAIL_EXISTS' not in str(e):
            raise
        r = _req('POST', f'{AUTH}/accounts:signInWithPassword?key=demo', {'email': email, 'password': CLAVE, 'returnSecureToken': True})
    return r['localId']


def uids():
    return {k: uid_de(c['email']) for k, c in CUENTAS.items()}


def dia(n, hora=12):
    hoy = datetime.now(BOGOTA)
    return datetime(hoy.year, hoy.month, hoy.day, hora, 0, tzinfo=BOGOTA) + timedelta(days=n)


def base():
    u = uids()
    ahora = datetime.now(timezone.utc)
    for k, c in CUENTAS.items():
        poner(f'users/{u[k]}', dict(uid=u[k], email=c['email'], fullName=c['fullName'], role=c['role'],
                                    isClinicOwner=c['isClinicOwner'], clinicId=CLINICA_ID, isActive=True,
                                    gender='femenino', birthDate=datetime(2000, 3, 15, tzinfo=BOGOTA),
                                    createdAt=ahora, updatedAt=ahora))
    poner(f'clinics/{CLINICA_ID}', dict(name='Clínica Prueba', ownerId=u['odontologo'], nit='900000000-1',
                                        address='Montería, Córdoba', isActive=True, apiKey='PRUEBA',
                                        employeeIds=[u['empleado']], createdAt=ahora, updatedAt=ahora))
    poner(f'clinics/{CLINICA_ID}/employees/{u["empleado"]}', dict(uid=u['empleado'], fullName='Empleado Prueba',
                                        position='Auxiliar', isActive=True, hasSecurityAccess=False,
                                        canManageAgenda=False, updatedAt=ahora))
    poner('treatments/trat_limpieza', dict(name='Limpieza dental', description='Profilaxis', price=80000,
                                           durationMinutes=30, isActive=True, clinicId=CLINICA_ID,
                                           category='general', createdAt=ahora))
    print(json.dumps(u, indent=2))


def turno(doc_id, u, n, inicio='08:00', fin='17:00', employee_id=None, nombre='Empleado Prueba', status='scheduled'):
    poner(f'turnos/{doc_id}', dict(clinicId=CLINICA_ID, dentistId=u['odontologo'],
                                   employeeId=employee_id or u['empleado'], employeeName=nombre,
                                   date=dia(n), startTime=inicio, endTime=fin, status=status,
                                   attendanceStatus='pending', reminderWeekSent=False, reminderDaySent=False,
                                   createdAt=datetime.now(timezone.utc)))


def caso(cp):
    u = uids()
    ahora = datetime.now(timezone.utc)
    if cp == 'CP-04':
        poner('appointments/cp04_cita', dict(clinicId=CLINICA_ID, patientId='paciente_prueba_dos', patientName='Paciente Prueba Dos',
              dentistId=u['odontologo'], dentistName='Odontólogo Prueba', treatmentName='Limpieza dental',
              date=dia(8), timeSlot='11:00', status='pending', createdAt=ahora))
    elif cp == 'CP-06':
        poner('appointments/cp06_cita_previa', dict(clinicId=CLINICA_ID, patientId='paciente_prueba_dos', patientName='Paciente Prueba Dos',
              dentistId=u['odontologo'], dentistName='Odontólogo Prueba', treatmentName='Limpieza dental',
              date=dia(7), timeSlot='10:00', status='confirmed', createdAt=ahora))
    elif cp == 'CP-08':
        turno('cp08_turno', u, 0)
    elif cp == 'CP-10':
        turno('cp10_propio', u, 2, '08:00', '12:00')
        turno('cp10_ajeno', u, 2, '13:00', '17:00', employee_id='otro_empleado_cp10', nombre='Otro Empleado')
    elif cp == 'CP-11':
        turno('cp11_dia7', u, 7)
        turno('cp11_dia8', u, 8)
    elif cp == 'CP-12':
        turno('cp12_turno', u, 3)
    elif cp == 'CP-13':
        turno('cp13_turno', u, 5)
    elif cp == 'CP-13-solicitud':
        turno('cp13_turno', u, 5)
        poner('turno_requests/cp13_solicitud', dict(turnoId='cp13_turno', employeeId=u['empleado'],
              employeeName='Empleado Prueba', type='cambio_horario', details='Tengo control medico en la manana',
              status='pending', requestedDate=dia(5, 0), requestedStartTime='10:00', requestedEndTime='19:00',
              clinicId=CLINICA_ID, createdAt=ahora))
    else:
        raise SystemExit(f'Caso sin datos sembrados: {cp}')
    print('sembrado', cp)


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[0] == 'base': base()
    elif a[0] == 'caso': caso(a[1])
    elif a[0] == 'ver': print(json.dumps(ver(a[1]), indent=2, ensure_ascii=False))
    elif a[0] == 'listar':
        f = dict(x.split('=', 1) for x in a[2:])
        for ruta, campos in listar(a[1], **f):
            print(ruta, json.dumps(campos, ensure_ascii=False))
    elif a[0] == 'borrar': borrar(a[1]); print('borrado', a[1])
    elif a[0] == 'uids': print(json.dumps(uids(), indent=2))
