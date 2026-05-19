# Medident

Multiplataforma dental y m�dica.

## Descripci�n

Medident es una aplicacion multiplataforma desarrollada en Flutter para la gestion de consultorios dentales y medicos. 
Incluye modulos de autenticacion, historias clinicas, odontogramas, agenda de citas, gestion de pacientes, 
y un asistente virtual inteligente llamado Valeria.

## Caracter�sticas

- **Autenticaci�n**: Registro e inicio de sesi�n con email/contrase�a y Google Sign-In
- **Roles de usuario**: Administrador, Odont�logo, Doctor, Empleado, Paciente
- **Gesti�n de pacientes**: Fichas cl�nicas, historial de tratamientos, odontogramas
- **Agenda de citas**: Programaci�n y seguimiento de turnos
- **Asistente Valeria**: Asistente virtual con IA (modelo local + Grok API)
- **Responsive Design**: Adaptable a mobile, tablet y desktop
- **Notificaciones Push**: Integraci�n con Firebase Cloud Messaging
- **Mapas y entregas**: Seguimiento de entregas con OSRM

## Tecnologias

- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore, Storage, Realtime DB, Messaging)
- **Estado**: Provider + ChangeNotifier
- **IA Local**: Motor NLP con similitud coseno (ValeriaEngine)
- **IA Cloud**: Grok API (xAI) / Gemini (Cloud Functions)
- **Mapas**: FlutterMap + OSRM
- **Animaciones**: Rive, Lottie

## Estructura del proyecto

`
lib/
+-- main.dart                    # Entry point
+-- main_export.dart             # Barrel export
+-- core/
�   +-- auth/                    # Auth gate
�   +-- ia/                      # Valeria engine, knowledge, config
�   +-- enums/                   # Enumeraciones (g�nero, auth state)
�   +-- models/                  # Modelos de datos
�   +-- providers/               # Providers (ChangeNotifiers)
�   +-- services/                # Servicios Firebase, APIs
�   +-- utils/                   # Constantes, helpers, navegaci�n
+-- screens/
�   +-- splash/                  # Pantalla de carga
�   +-- onboarding/              # Onboarding tutorial
�   +-- login/                   # Sign in / Sign up
�   +-- role/                    # Screens por rol
�   +-- settings/                # Ajustes de cuenta
�   +-- reels/                   # Videos educativos
�   +-- widgets/                 # Widgets reutilizables
+-- ia/
�   +-- valeria.dart             # Asistente Valeria widget
+-- scripts/                     # Scripts de seed para Firebase
`

## Configuraci�n

1. Clonar el repositorio
2. Crear proyecto en Firebase Console
3. Descargar google-services.json (Android) y GoogleService-Info.plist (iOS)
4. Configurar irebase_options.dart con las credenciales del proyecto
5. Ejecutar lutter pub get
6. Ejecutar lutter run

## Firebase App IDs

| Platform | App ID |
|----------|--------|
| Web      | 1:435865924056:web:07b721ee76d40b056282ad |
| Android  | 1:435865924056:android:f75f0e860880f4296282ad |
| iOS      | 1:435865924056:ios:ac3dfd486d843c5e6282ad |
| macOS    | 1:435865924056:ios:ac3dfd486d843c5e6282ad |
| Windows  | 1:435865924056:web:373480380257c5816282ad |

## Licencia

Proyecto privado - IPS Medident
