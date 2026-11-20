import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:medident/core/enums/user-gender.dart';
import 'package:medident/core/services/patient-service.dart';

/// Formulario clínico completo para registrar un paciente nuevo dentro de la
/// clínica. Guarda datos personales en `users` y datos clínicos en
/// `patient_profiles`.
class CreatePatientScreen extends StatefulWidget {
  final String clinicId;
  final String? createdBy;
  final VoidCallback? onCreated;

  const CreatePatientScreen({
    super.key,
    required this.clinicId,
    this.createdBy,
    this.onCreated,
  });

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  static const _accent = Color(0xFF0EA5A4);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFC);

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _documentCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _referredByCtrl = TextEditingController();
  final _insuranceIdCtrl = TextEditingController();
  final _insuranceOtherCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  UserGender? _gender;
  DateTime? _birthDate;
  String? _maritalStatus;
  String? _education;
  String? _bloodType;
  String? _insuranceProvider;
  String? _smoker;
  String? _alcohol;
  final Set<String> _conditions = {};
  bool _saving = false;

  static const _maritalOptions = [
    'Soltero(a)',
    'Casado(a)',
    'Unión libre',
    'Divorciado(a)',
    'Viudo(a)',
  ];
  static const _educationOptions = [
    'Primaria',
    'Secundaria',
    'Bachillerato',
    'Técnico',
    'Universitario',
    'Posgrado',
  ];
  static const _bloodOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  static const _insuranceOptions = [
    'Ninguno',
    'Seguro Social',
    'Salud Total',
    'Nueva EPS',
    'Sura',
    'Compensar',
    'Colsanitas',
    'Coomeva',
    'Otro',
  ];
  static const _smokerOptions = ['No', 'Sí', 'Exfumador'];
  static const _alcoholOptions = ['No', 'Ocasional', 'Frecuente'];
  static const _conditionOptions = [
    'Ninguno',
    'Diabetes',
    'Hipertensión',
    'Asma',
    'Alergias',
    'Cardiopatías',
    'Epilepsia',
    'Tiroides',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _documentCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _occupationCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _referredByCtrl.dispose();
    _insuranceIdCtrl.dispose();
    _insuranceOtherCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicationsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _accent,
              onPrimary: Colors.white,
              onSurface: _text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Seleccionar fecha';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  List<String> _split(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _toggleCondition(String value) {
    setState(() {
      if (value == 'Ninguno') {
        _conditions
          ..clear()
          ..add('Ninguno');
        return;
      }
      _conditions.remove('Ninguno');
      if (!_conditions.add(value)) {
        _conditions.remove(value);
      }
    });
  }

  Future<void> _save() async {
    if (widget.clinicId.isEmpty) {
      _snack('No hay una clínica cargada. Intenta de nuevo.', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      _snack('Selecciona el sexo del paciente.', isError: true);
      return;
    }
    if (_birthDate == null) {
      _snack('Selecciona la fecha de nacimiento.', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final insurance = _insuranceProvider == 'Otro'
          ? _insuranceOtherCtrl.text.trim()
          : _insuranceProvider;
      final patientCode = PatientService.generatePatientCode();
      await PatientService().createPatient(
        clinicId: widget.clinicId,
        fullName: _nameCtrl.text.trim(),
        patientCode: patientCode,
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        gender: _gender!.name,
        birthDate: _birthDate,
        address: _addressCtrl.text.trim(),
        documentId: _documentCtrl.text.trim(),
        maritalStatus: _maritalStatus,
        occupation: _occupationCtrl.text.trim(),
        education: _education,
        smoker: _smoker,
        alcohol: _alcohol,
        emergencyContactName: _emergencyNameCtrl.text.trim(),
        emergencyContactPhone: _emergencyPhoneCtrl.text.trim(),
        referredBy: _referredByCtrl.text.trim(),
        bloodType: _bloodType,
        allergies: _split(_allergiesCtrl.text),
        medications: _split(_medicationsCtrl.text),
        medicalHistory:
            _conditions.where((e) => e != 'Ninguno').toList(),
        dentalHistory: const [],
        insuranceProvider: insurance,
        insuranceId: _insuranceIdCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
      widget.onCreated?.call();
      if (mounted) {
        await _showCreatedQr(_nameCtrl.text.trim(), patientCode);
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _snack('No se pudo registrar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showCreatedQr(String name, String patientCode) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Paciente registrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 42),
            const SizedBox(height: 8),
            Text(name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: QrImageView(
                data: patientCode,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(patientCode,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: _accent)),
            const SizedBox(height: 6),
            const Text(
              'Este es el QR del paciente. Puedes escanearlo al agendar una cita.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: _muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Listo'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFDC2626) : _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0.4,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nuevo paciente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('Ficha clínica completa',
                style: TextStyle(fontSize: 12, color: _muted)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottom),
          children: [
            _sectionCard(
              title: 'Identidad',
              icon: Icons.person_outline,
              children: [
                _genderSelector(),
                const SizedBox(height: 16),
                _field(
                  controller: _nameCtrl,
                  label: 'Nombre completo',
                  icon: Icons.badge_outlined,
                  required: true,
                ),
                _field(
                  controller: _documentCtrl,
                  label: 'Documento / Cédula',
                  icon: Icons.credit_card_outlined,
                ),
                _dateField(),
                _dropdown(
                  label: 'Estado civil',
                  icon: Icons.favorite_border,
                  value: _maritalStatus,
                  items: _maritalOptions,
                  onChanged: (v) => setState(() => _maritalStatus = v),
                ),
                _field(
                  controller: _occupationCtrl,
                  label: 'Ocupación',
                  icon: Icons.work_outline,
                ),
                _dropdown(
                  label: 'Escolaridad',
                  icon: Icons.school_outlined,
                  value: _education,
                  items: _educationOptions,
                  onChanged: (v) => setState(() => _education = v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Contacto',
              icon: Icons.phone_outlined,
              children: [
                _field(
                  controller: _phoneCtrl,
                  label: 'Teléfono',
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                  required: true,
                ),
                _field(
                  controller: _emailCtrl,
                  label: 'Correo electrónico',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                ),
                _field(
                  controller: _addressCtrl,
                  label: 'Dirección',
                  icon: Icons.location_on_outlined,
                ),
                _field(
                  controller: _emergencyNameCtrl,
                  label: 'Contacto de emergencia',
                  icon: Icons.contact_emergency_outlined,
                ),
                _field(
                  controller: _emergencyPhoneCtrl,
                  label: 'Teléfono de emergencia',
                  icon: Icons.phone_in_talk_outlined,
                  keyboardType: TextInputType.phone,
                ),
                _field(
                  controller: _referredByCtrl,
                  label: 'Referido por',
                  icon: Icons.share_outlined,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Información clínica',
              icon: Icons.medical_information_outlined,
              children: [
                _dropdown(
                  label: 'Tipo de sangre',
                  icon: Icons.bloodtype_outlined,
                  value: _bloodType,
                  items: _bloodOptions,
                  onChanged: (v) => setState(() => _bloodType = v),
                ),
                _dropdown(
                  label: 'Aseguradora / EPS',
                  icon: Icons.health_and_safety_outlined,
                  value: _insuranceProvider,
                  items: _insuranceOptions,
                  onChanged: (v) => setState(() => _insuranceProvider = v),
                ),
                if (_insuranceProvider == 'Otro')
                  _field(
                    controller: _insuranceOtherCtrl,
                    label: 'Nombre de la aseguradora',
                    icon: Icons.edit_outlined,
                  ),
                _field(
                  controller: _insuranceIdCtrl,
                  label: 'Número de afiliación',
                  icon: Icons.numbers_outlined,
                ),
                _dropdown(
                  label: '¿Fuma?',
                  icon: Icons.smoking_rooms_outlined,
                  value: _smoker,
                  items: _smokerOptions,
                  onChanged: (v) => setState(() => _smoker = v),
                ),
                _dropdown(
                  label: '¿Consume alcohol?',
                  icon: Icons.local_bar_outlined,
                  value: _alcohol,
                  items: _alcoholOptions,
                  onChanged: (v) => setState(() => _alcohol = v),
                ),
                const SizedBox(height: 4),
                const Text('Antecedentes médicos',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _muted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _conditionOptions.map((c) {
                    final selected = _conditions.contains(c);
                    return FilterChip(
                      label: Text(c),
                      selected: selected,
                      onSelected: (_) => _toggleCondition(c),
                      selectedColor: _accent.withOpacity(0.15),
                      checkmarkColor: _accent,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selected ? _accent : _muted,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: selected
                            ? _accent.withOpacity(0.4)
                            : const Color(0xFFE2E8F0),
                      ),
                      backgroundColor: Colors.white,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _allergiesCtrl,
                  label: 'Alergias (separadas por coma)',
                  icon: Icons.warning_amber_outlined,
                ),
                _field(
                  controller: _medicationsCtrl,
                  label: 'Medicamentos (separados por coma)',
                  icon: Icons.medication_outlined,
                ),
                _field(
                  controller: _notesCtrl,
                  label: 'Notas del paciente',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _accent.withOpacity(0.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.4),
                      )
                    : const Text('Registrar paciente',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 16, color: _accent),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _text)),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _genderSelector() {
    return Row(
      children: [
        Expanded(
          child: _genderCard(
            gender: UserGender.femenino,
            icon: Icons.female_rounded,
            label: 'Femenino',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _genderCard(
            gender: UserGender.masculino,
            icon: Icons.male_rounded,
            label: 'Masculino',
          ),
        ),
      ],
    );
  }

  Widget _genderCard({
    required UserGender gender,
    required IconData icon,
    required String label,
  }) {
    final selected = _gender == gender;
    return GestureDetector(
      onTap: () => setState(() => _gender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [_accent, _accent.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _accent : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  selected ? Colors.white.withOpacity(0.22) : Colors.white,
              child: Icon(icon,
                  size: 30, color: selected ? Colors.white : _muted),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: _text),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null
            : null,
        decoration: _decoration(label, icon),
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _pickBirthDate,
        child: InputDecorator(
          decoration: _decoration('Fecha de nacimiento', Icons.cake_outlined)
              .copyWith(
            suffixIcon:
                const Icon(Icons.calendar_today_outlined, size: 18, color: _muted),
          ),
          child: Text(
            _fmtDate(_birthDate),
            style: TextStyle(
              fontSize: 14,
              color: _birthDate == null ? _muted : _text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.expand_more, color: _muted, size: 20),
        style: const TextStyle(fontSize: 14, color: _text),
        decoration: _decoration(label, icon),
        items: items
            .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: _muted),
      prefixIcon: Icon(icon, size: 19, color: _accent.withOpacity(0.8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.4),
      ),
    );
  }
}
