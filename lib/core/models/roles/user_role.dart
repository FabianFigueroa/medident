enum UserRole {
  admin('Administrador'),
  dentist('Dentista'),
  doctor('Doctor'),
  employee('Empleado'),
  patient('Paciente'),
  delivery('Domiciliario');

  final String displayName;

  const UserRole(this.displayName);
}
