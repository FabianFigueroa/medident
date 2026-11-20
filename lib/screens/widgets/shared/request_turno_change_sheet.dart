import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/turno-model.dart';
import 'package:medident/core/services/agenda-service.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';

class RequestTurnoChangeSheet extends StatefulWidget {
  final String turnoId;
  final String employeeName;
  final String employeeId;
  final List<TurnoModel> turnos;
  final String? initialTurnoId;
  final String initialType;

  const RequestTurnoChangeSheet({
    super.key,
    required this.turnoId,
    required this.employeeName,
    required this.employeeId,
    this.turnos = const [],
    this.initialTurnoId,
    this.initialType = 'novedad',
  });

  @override
  State<RequestTurnoChangeSheet> createState() => _RequestTurnoChangeSheetState();
}

class _RequestTurnoChangeSheetState extends State<RequestTurnoChangeSheet> {
  static const _types = [
    ('novedad', 'Novedad', Icons.report_problem_outlined),
    ('cambio_horario', 'Cambio de horario', Icons.schedule),
    ('cambio_turno', 'Cambio de turno', Icons.swap_horiz),
    ('intercambio', 'Intercambiar turno', Icons.people_alt_outlined),
  ];

  late String _type;
  late String _turnoId;
  final _detailsCtrl = TextEditingController();
  final _targetNameCtrl = TextEditingController();
  final _targetUidCtrl = TextEditingController();
  final _targetTurnoCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  DateTime? _requestedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _turnoId = widget.initialTurnoId?.isNotEmpty == true
        ? widget.initialTurnoId!
        : widget.turnoId;
    final selected = _selectedTurno;
    if (selected != null) {
      _startCtrl.text = selected.startTime;
      _endCtrl.text = selected.endTime;
    }
  }

  TurnoModel? get _selectedTurno {
    if (widget.turnos.isEmpty) return null;
    for (final t in widget.turnos) {
      if (t.id == _turnoId) return t;
    }
    return widget.turnos.first;
  }

  bool get _needsTarget =>
      _type == 'cambio_turno' || _type == 'intercambio';

  bool get _needsSchedule => _type == 'cambio_horario';

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _targetNameCtrl.dispose();
    _targetUidCtrl.dispose();
    _targetTurnoCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _requestedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Fecha solicitada',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) setState(() => _requestedDate = picked);
  }

  Future<void> _submitRequest() async {
    if (_detailsCtrl.text.trim().isEmpty) {
      _snack('Describe el motivo o detalle de la solicitud');
      return;
    }
    if (_needsTarget &&
        _targetUidCtrl.text.trim().isEmpty &&
        _targetNameCtrl.text.trim().isEmpty) {
      _snack('Ingresa el UID o el nombre del empleado implicado');
      return;
    }
    if (_turnoId.isEmpty) {
      _snack('Selecciona el turno que quieres gestionar');
      return;
    }

    final clinicId = context.read<AuthenticateProvider>().user?.clinicId;
    setState(() => _saving = true);
    try {
      await AgendaService().requestTurnoChange(
        turnoId: _turnoId,
        employeeId: widget.employeeId,
        employeeName: widget.employeeName,
        type: _type,
        details: _detailsCtrl.text.trim(),
        clinicId: clinicId,
        targetEmployeeId: _targetUidCtrl.text.trim().isEmpty
            ? null
            : _targetUidCtrl.text.trim(),
        targetEmployeeName: _targetNameCtrl.text.trim().isEmpty
            ? null
            : _targetNameCtrl.text.trim(),
        targetTurnoId: _targetTurnoCtrl.text.trim().isEmpty
            ? null
            : _targetTurnoCtrl.text.trim(),
        requestedDate: _needsSchedule ? _requestedDate : null,
        requestedStartTime: _needsSchedule ? _startCtrl.text.trim() : null,
        requestedEndTime: _needsSchedule ? _endCtrl.text.trim() : null,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada. La clínica la revisará.'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('No se pudo enviar: $e');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Solicitud de turno',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Novedad, cambio de horario, cambio de turno o intercambio.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.person_outline,
                    size: 16, color: Color(0xFF4F46E5)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Solicitante: ${widget.employeeName} (${widget.employeeId})',
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4338CA)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((item) {
                final selected = _type == item.$1;
                return _TypeChip(
                  label: item.$2,
                  icon: item.$3,
                  isSelected: selected,
                  onTap: () => setState(() => _type = item.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            if (widget.turnos.isNotEmpty) ...[
              const _FieldLabel('Turno a gestionar'),
              DropdownButtonFormField<String>(
                initialValue: _selectedTurno?.id,
                isExpanded: true,
                decoration: _inputDecoration(),
                items: widget.turnos
                    .map((t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(
                            '${t.displayDate} · ${t.startTime} - ${t.endTime}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final match =
                      widget.turnos.where((t) => t.id == id).firstOrNull;
                  setState(() {
                    _turnoId = id;
                    if (match != null) {
                      _startCtrl.text = match.startTime;
                      _endCtrl.text = match.endTime;
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
            ],
            if (_needsSchedule) ...[
              const _FieldLabel('Nuevo horario solicitado'),
              Row(children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: _inputDecoration(
                          icon: Icons.calendar_today_outlined),
                      child: Text(
                        _requestedDate == null
                            ? 'Seleccionar fecha'
                            : '${_requestedDate!.day.toString().padLeft(2, '0')}/${_requestedDate!.month.toString().padLeft(2, '0')}/${_requestedDate!.year}',
                        style: TextStyle(
                            fontSize: 13,
                            color: _requestedDate == null
                                ? Colors.grey[500]
                                : const Color(0xFF1A1A1A)),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _startCtrl,
                    decoration: _inputDecoration(
                        hint: 'Hora inicio (HH:MM)',
                        icon: Icons.access_time),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _endCtrl,
                    decoration: _inputDecoration(
                        hint: 'Hora fin (HH:MM)', icon: Icons.access_time),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
            ],
            if (_needsTarget) ...[
              const _FieldLabel('Empleado implicado'),
              TextField(
                controller: _targetNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                    hint: 'Nombre del compañero/a',
                    icon: Icons.person_outline),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _targetUidCtrl,
                decoration: _inputDecoration(
                    hint: 'UID del compañero/a (opcional si diste el nombre)',
                    icon: Icons.badge_outlined),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _targetTurnoCtrl,
                decoration: _inputDecoration(
                    hint: 'UID de su turno a intercambiar (opcional)',
                    icon: Icons.event_note_outlined),
              ),
              const SizedBox(height: 14),
            ],
            const _FieldLabel('Detalle de la solicitud'),
            TextField(
              controller: _detailsCtrl,
              maxLines: 4,
              decoration: _inputDecoration(
                hint: _type == 'novedad'
                    ? 'Describe la novedad del día...'
                    : 'Explica el cambio que necesitas y el motivo...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_outlined, size: 18),
                label: Text(_saving ? 'Enviando...' : 'Enviar solicitud',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      prefixIcon:
          icon != null ? Icon(icon, size: 18, color: Colors.grey[500]) : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600])),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  isSelected ? const Color(0xFF4F46E5) : Colors.transparent),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 16,
              color: isSelected ? const Color(0xFF4F46E5) : Colors.grey),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : Colors.grey[700],
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
