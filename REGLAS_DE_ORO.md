# Reglas de oro - Medident

Este documento centraliza las reglas de negocio no negociables del proyecto. Toda funcionalidad nueva debe respetarlas.

## Regla de oro 1 - Perfil de usuario y perfil de clínica son entidades separadas

**Enunciado**

EL USUARIO CON ROLE DENTIST O DOCTOR, CUANDO CREA UNA CLÍNICA, ESTA PASA A SER UNA ESPECIE DE OTRO USUARIO TIPO CLÍNICA VINCULADO Y ADMINISTRADO POR ESE USUARIO QUE LA CREÓ. ESTO SIGNIFICA QUE EL PERFIL DEL USUARIO ES UNO Y EL PERFIL DE LA CLÍNICA SE MANEJA SOLO EN LA SECCIÓN "CLINIC". TODO LO QUE SE HAGA DESDE AHÍ POR EL USUARIO QUE LA CREÓ SALDRÁ A TODOS PERO COMO CLÍNICA, YA NO SE CARGA NADA DEL USUARIO, NADA DE LO QUE ÉL SUBE. SOLO AHÍ SE CARGARÁN Y SUBIRÁN COSAS DE LA CLÍNICA. ESO SIGNIFICA QUE EL NOMBRE Y EL CÓDIGO QR DE LA CLÍNICA DEBEN SALIR CON SU INFORMACIÓN.

**Interpretación operativa**

1. El usuario `dentist` o `doctor` conserva su perfil personal (nombre, foto, publicaciones personales, etc.).
2. Al crear una clínica, se crea un documento en la colección `clinics` cuyo `ownerId` es el usuario creador. El usuario queda vinculado con `clinicId` e `isClinicOwner = true`.
3. La clínica se comporta como una identidad pública independiente. El perfil de la clínica se administra únicamente desde la sección **Clinic / Clínica**.
4. Todo contenido creado desde la sección Clinic (posts, historias clínicas, promociones, tratamientos, turnos, pacientes, eventos, reels, etc.) se publica con la identidad de la clínica: `sourceType = 'clinic'`, `sourceId = clinicId`, `sourceName = clinic.name`, `sourcePhoto = clinic.logoUrl`. Nunca se debe mostrar el nombre o la foto personal del usuario como autor de ese contenido.
5. Las publicaciones personales del usuario se siguen mostrando con su identidad personal (`sourceType = 'user'`).
6. El nombre visible y el código QR de la clínica se generan con los datos de la clínica (`name`, `logoUrl`, `apiKey`). No se reutilizan el nombre, la foto ni el código del usuario.
7. Las promociones y contenido de la clínica no deben mezclarse con promociones personales del dueño. Las consultas de contenido de clínica filtran por `clinicId` / `sourceType = 'clinic'`.
8. El campo `createdByUserId` o `authorUserId` se conserva únicamente como dato de auditoría interno, nunca como identidad visible.

**Implementación de referencia**

- Modelo: `lib/core/models/clinic-model.dart`
- Servicio: `lib/core/services/clinic-service.dart`
- Provider: `lib/core/providers/dentist/dentist-clinic-provider.dart`
- Creación de clínica: `lib/screens/role/dentist/clinic/onboarding/create-clinic-screen.dart`
- QR de la clínica: `lib/screens/role/dentist/clinic/onboarding/clinic-created-screen.dart` y `lib/screens/role/dentist/clinic/widgets/clinic-qr-sheet.dart`
- Publicación como clínica: `lib/screens/widgets/new-post/create_newposts_widget.dart`
- Cabecera de la clínica: `lib/screens/role/dentist/clinic/widgets/clinic_header_widget.dart`
- Seeder de datos demo: `lib/core/data/firebase_seeder.dart`

**Criterios de aceptación**

- Al publicar desde Clinic, el autor visible es el nombre de la clínica y el avatar es el logo de la clínica.
- El perfil personal del usuario no cambia ni se duplica al crear la clínica.
- El QR y el código de la clínica corresponden al documento `clinics/{clinicId}` y son visibles para el propietario dentro de la sección Clinic.
- Ninguna consulta de contenido de clínica devuelve publicaciones o promociones personales del usuario creador.
