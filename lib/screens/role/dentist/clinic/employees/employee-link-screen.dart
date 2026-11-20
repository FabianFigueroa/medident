import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/enums/user-gender.dart';
import 'package:medident/core/models/employee-model.dart';
import 'package:medident/core/services/clinic-service.dart';
import 'package:medident/core/services/employee-link-service.dart';
import 'package:medident/core/services/employees/employees-service.dart';

/// Pantalla para vincular empleados a la clínica.
///
/// - "Vincular cuenta": busca cuentas registradas y permite enviar una
///   solicitud o vincular directamente.
/// - "Crear empleado": registra a alguien sin cuenta y lo vincula de una vez.
class EmployeeLinkScreen extends StatefulWidget {
  final String clinicId;
  final String ownerId;
  final String ownerName;
  final String? clinicName;
  final VoidCallback? onChanged;

  const EmployeeLinkScreen({
    super.key,
    required this.clinicId,
    required this.ownerId,
    required this.ownerName,
    this.clinicName,
    this.onChanged,
  });

  @override
  State<EmployeeLinkScreen> createState() => _EmployeeLinkScreenState();
}

class _EmployeeLinkScreenState extends State<EmployeeLinkScreen> {
  static const _accent = Color(0xFFF59E0B);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFC);

  final EmployeeLinkService _service = EmployeeLinkService();
  final EmployeesService _employeesService = EmployeesService();
  final TextEditingController _searchCtrl = TextEditingController();

  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;
  bool _hasSearched = false;
  int _mode = 0;
  String _clinicName = '';

  @override
  void initState() {
    super.initState();
    _clinicName = widget.clinicName ?? '';
    if (_clinicName.isEmpty) {
      ClinicService().getClinic(widget.clinicId).then((clinic) {
        if (!mounted || clinic == null) return;
        setState(() => _clinicName = clinic.name);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() => _searching = true);
    final results = await _service.searchAccounts(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
      _hasSearched = true;
    });
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? const Color(0xFFDC2626) : _accent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0.4,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Equipo de la clínica',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              _clinicName.isNotEmpty ? _clinicName : 'Vinculación de empleados',
              style: const TextStyle(fontSize: 12, color: _muted),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _modeSwitcher(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _mode == 0
                  ? _buildLinkTab()
                  : _mode == 1
                      ? _buildCreateTab()
                      : _buildTeamTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeSwitcher() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _modeButton(0, 'Vincular', Icons.link_rounded),
            _modeButton(1, 'Crear', Icons.person_add_alt_1_rounded),
            _modeButton(2, 'Equipo', Icons.groups_rounded),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(int index, String label, IconData icon) {
    final active = _mode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: active ? _accent : _muted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? _text : _muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Vincular cuenta existente ─────────────────────────────────
  Widget _buildLinkTab() {
    return ListView(
      key: const ValueKey('link'),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Buscar una cuenta registrada',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _text)),
              const SizedBox(height: 4),
              const Text(
                'Verifica que la persona ya tenga cuenta en Medident por nombre, correo o teléfono.',
                style: TextStyle(fontSize: 12.5, color: _muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: _runSearch,
                style: const TextStyle(fontSize: 14, color: _text),
                decoration: InputDecoration(
                  hintText: 'Ej: ana@correo.com o Ana Pérez',
                  hintStyle: const TextStyle(fontSize: 13, color: _muted),
                  prefixIcon:
                      const Icon(Icons.search, size: 20, color: _accent),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _accent),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _accent, width: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (!_hasSearched && !_searching)
          _emptyHint(
            Icons.manage_search_rounded,
            'Escribe para buscar una cuenta',
            'Solo podrás enviar la solicitud si la cuenta existe.',
          )
        else if (_hasSearched && _results.isEmpty)
          _emptyHint(
            Icons.person_off_outlined,
            'No se encontró esa cuenta',
            'Si la persona aún no está registrada, usa la pestaña "Crear empleado".',
          )
        else
          ..._results.map(_accountTile),
      ],
    );
  }

  Widget _accountTile(Map<String, dynamic> account) {
    final name = (account['fullName'] ?? 'Sin nombre').toString();
    final email = (account['email'] ?? '').toString();
    final clinicId = account['clinicId'] as String?;
    final alreadyHere = clinicId == widget.clinicId;
    final photo = (account['imageUrl'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: alreadyHere ? null : () => _openAccountActions(account),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _accent.withOpacity(0.12),
                  backgroundImage:
                      photo.isNotEmpty ? NetworkImage(photo) : null,
                  child: photo.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              color: _accent, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _text)),
                      Text(
                        email.isNotEmpty ? email : (account['role'] ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: _muted),
                      ),
                    ],
                  ),
                ),
                if (alreadyHere)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Ya vinculado',
                        style: TextStyle(
                            fontSize: 10.5,
                            color: _accent,
                            fontWeight: FontWeight.w600)),
                  )
                else
                  const Icon(Icons.chevron_right, color: _muted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAccountActions(Map<String, dynamic> account) async {
    final name = (account['fullName'] ?? 'Sin nombre').toString();
    final email = (account['email'] ?? '').toString();
    final otherClinic = account['clinicId'] as String?;
    String position = 'medico_general';
    bool working = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          Future<void> submit(bool sendRequest) async {
            setSheet(() => working = true);
            try {
              if (sendRequest) {
                await _service.sendLinkRequest(
                  clinicId: widget.clinicId,
                  clinicName: _clinicName,
                  ownerId: widget.ownerId,
                  ownerName: widget.ownerName,
                  userId: account['id'] as String,
                  userName: name,
                  userEmail: email,
                  userPhoto: (account['imageUrl'] ?? '').toString(),
                  position: position,
                );
              } else {
                await _service.linkDirectly(
                  clinicId: widget.clinicId,
                  clinicName: _clinicName,
                  ownerId: widget.ownerId,
                  ownerName: widget.ownerName,
                  userId: account['id'] as String,
                  userName: name,
                  userPhoto: (account['imageUrl'] ?? '').toString(),
                  position: position,
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
              widget.onChanged?.call();
              _snack(sendRequest
                  ? 'Solicitud enviada a $name.'
                  : '$name vinculado a la clínica.');
            } catch (e) {
              setSheet(() => working = false);
              _snack('$e', error: true);
            }
          }

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3))),
                ),
                const SizedBox(height: 18),
                Text(name,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _text)),
                if (email.isNotEmpty)
                  Text(email,
                      style:
                          const TextStyle(fontSize: 12.5, color: _muted)),
                if (otherClinic != null && otherClinic.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: _accent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta cuenta ya pertenece a otra clínica. Al vincularla se moverá a la tuya.',
                            style: TextStyle(fontSize: 11.5, color: _muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: position,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 14, color: _text),
                  decoration: _decoration('Cargo en la clínica',
                      Icons.work_outline),
                  items: EmployeePositions.all
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(EmployeePositions.displayName(p),
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setSheet(() => position = v);
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: working ? null : () => submit(true),
                    icon: const Icon(Icons.send_rounded, size: 17),
                    label: const Text('Enviar solicitud'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: working ? null : () => submit(false),
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('Vincular directamente'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _text,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                if (working)
                  const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _accent),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Equipo actual (permisos) ─────────────────────────────────
  Widget _buildTeamTab() {
    return StreamBuilder<QuerySnapshot>(
      key: const ValueKey('team'),
      stream: FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('employees')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) {
          return _emptyHint(
            Icons.groups_outlined,
            'Aún no hay empleados',
            'Vincula o crea empleados para gestionar su agenda.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final uid = docs[i].id;
            final name = (data['userName'] ?? data['fullName'] ?? 'Empleado')
                .toString();
            final position = EmployeePositions.displayName(
                (data['position'] ?? 'medico_general').toString());
            final active = data['isActive'] as bool? ?? true;
            final canManage = data['canManageAgenda'] as bool? ?? false;
            final photo = (data['userPhoto'] ?? '').toString();
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _accent.withOpacity(0.12),
                        backgroundImage:
                            photo.isNotEmpty ? NetworkImage(photo) : null,
                        child: photo.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    color: _accent, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _text)),
                            Text(position,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: _muted)),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: active,
                        activeColor: _accent,
                        onChanged: (v) => _setActive(uid, v),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.event_note_outlined,
                          size: 18, color: _muted),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Puede gestionar la agenda',
                          style: TextStyle(fontSize: 12.5, color: _text),
                        ),
                      ),
                      Switch.adaptive(
                        value: canManage,
                        activeColor: _accent,
                        onChanged: (v) => _setAgendaPermission(uid, v),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setActive(String uid, bool value) async {
    try {
      await _employeesService.toggleEmployeeActive(
        clinicId: widget.clinicId,
        uid: uid,
        isActive: value,
      );
    } catch (e) {
      _snack('No se pudo actualizar: $e', error: true);
    }
  }

  Future<void> _setAgendaPermission(String uid, bool value) async {
    try {
      await _employeesService.setAgendaPermission(
        clinicId: widget.clinicId,
        uid: uid,
        canManageAgenda: value,
      );
    } catch (e) {
      _snack('No se pudo actualizar: $e', error: true);
    }
  }

  // ── Crear empleado sin cuenta ─────────────────────────────────
  Widget _buildCreateTab() {
    return _CreateEmployeeForm(
      key: const ValueKey('create'),
      clinicId: widget.clinicId,
      clinicName: _clinicName,
      ownerId: widget.ownerId,
      ownerName: widget.ownerName,
      service: _service,
      onCreated: () {
        widget.onChanged?.call();
        if (mounted) Navigator.pop(context, true);
      },
      onSnack: _snack,
    );
  }

  static InputDecoration _decoration(String label, IconData icon) {
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

  Widget _emptyHint(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _muted)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _muted)),
        ],
      ),
    );
  }
}

class _CreateEmployeeForm extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final String ownerId;
  final String ownerName;
  final EmployeeLinkService service;
  final VoidCallback onCreated;
  final void Function(String msg, {bool error}) onSnack;

  const _CreateEmployeeForm({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.ownerId,
    required this.ownerName,
    required this.service,
    required this.onCreated,
    required this.onSnack,
  });

  @override
  State<_CreateEmployeeForm> createState() => _CreateEmployeeFormState();
}

class _CreateEmployeeFormState extends State<_CreateEmployeeForm> {
  static const _accent = Color(0xFFF59E0B);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _position = 'medico_general';
  String _contractType = 'Indefinido';
  UserGender? _gender;
  DateTime? _birthDate;
  DateTime? _hiredAt;
  bool _saving = false;

  static const _contracts = [
    'Indefinido',
    'Término fijo',
    'Prestación de servicios',
    'Aprendiz',
    'Temporal',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _salaryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Seleccionar fecha';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  Future<DateTime?> _pickDate(DateTime? initial) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year + 2),
      helpText: 'Seleccionar fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.service.createAndLinkEmployee(
        clinicId: widget.clinicId,
        clinicName: widget.clinicName,
        ownerId: widget.ownerId,
        fullName: _nameCtrl.text.trim(),
        position: _position,
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        gender: _gender?.name,
        birthDate: _birthDate,
        address: _addressCtrl.text.trim(),
        contractType: _contractType,
        hiredAt: _hiredAt,
        salary: num.tryParse(_salaryCtrl.text.trim()),
        notes: _notesCtrl.text.trim(),
      );
      widget.onCreated();
    } catch (e) {
      widget.onSnack('No se pudo crear: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label, IconData icon) {
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottom),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datos del empleado',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _text)),
                const SizedBox(height: 4),
                const Text(
                  'Se creará su registro y quedará vinculado automáticamente a tu clínica.',
                  style: TextStyle(fontSize: 12.5, color: _muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _genderCard(
                          UserGender.femenino, Icons.female_rounded, 'Femenino'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _genderCard(
                          UserGender.masculino, Icons.male_rounded, 'Masculino'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(fontSize: 14, color: _text),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Campo requerido'
                      : null,
                  decoration: _dec('Nombre completo', Icons.badge_outlined),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14, color: _text),
                  decoration:
                      _dec('Correo electrónico', Icons.alternate_email),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 14, color: _text),
                  decoration:
                      _dec('Teléfono', Icons.phone_outlined),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _position,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 14, color: _text),
                  decoration: _dec('Cargo', Icons.work_outline),
                  items: EmployeePositions.all
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(EmployeePositions.displayName(p),
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _position = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _contractType,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 14, color: _text),
                  decoration:
                      _dec('Tipo de contrato', Icons.description_outlined),
                  items: _contracts
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _contractType = v);
                  },
                ),
                const SizedBox(height: 12),
                _dateTile(
                  label: 'Fecha de nacimiento',
                  icon: Icons.cake_outlined,
                  value: _birthDate,
                  onTap: () async {
                    final d = await _pickDate(_birthDate);
                    if (d != null) setState(() => _birthDate = d);
                  },
                ),
                const SizedBox(height: 12),
                _dateTile(
                  label: 'Fecha de contratación',
                  icon: Icons.event_available_outlined,
                  value: _hiredAt,
                  onTap: () async {
                    final d = await _pickDate(_hiredAt);
                    if (d != null) setState(() => _hiredAt = d);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressCtrl,
                  style: const TextStyle(fontSize: 14, color: _text),
                  decoration:
                      _dec('Dirección', Icons.location_on_outlined),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14, color: _text),
                  decoration: _dec('Salario', Icons.payments_outlined),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14, color: _text),
                  decoration: _dec('Notas', Icons.notes_outlined),
                ),
              ],
            ),
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
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.4),
                    )
                  : const Text('Crear y vincular empleado',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderCard(UserGender gender, IconData icon, String label) {
    final selected = _gender == gender;
    return GestureDetector(
      onTap: () => setState(() => _gender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accent : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _accent : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  selected ? Colors.white.withOpacity(0.25) : Colors.white,
              child:
                  Icon(icon, size: 22, color: selected ? Colors.white : _muted),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _muted)),
          ],
        ),
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required IconData icon,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: _dec(label, icon).copyWith(
          suffixIcon: const Icon(Icons.calendar_today_outlined,
              size: 18, color: _muted),
        ),
        child: Text(
          _fmt(value),
          style: TextStyle(
              fontSize: 14, color: value == null ? _muted : _text),
        ),
      ),
    );
  }
}
