import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/core/providers/domain/appointment-provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/providers/dentist/dentist-clinic-provider.dart';
import 'package:medident/screens/widgets/shared/patient_search_sheet.dart';
import 'package:medident/screens/widgets/shared/dentist_search_sheet.dart';

class CreateAppointment_Widget extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialPatientId;
  final String? initialPatientName;
  final VoidCallback? onCreated;
  final String? clinicId;
  final String? userId;
  final String? userName;
  final String? userPhoto;
  final bool isPatientMode;

  const CreateAppointment_Widget({
    super.key,
    this.initialDate,
    this.initialPatientId,
    this.initialPatientName,
    this.onCreated,
    this.clinicId,
    this.userId,
    this.userName,
    this.userPhoto,
    this.isPatientMode = false,
  });

  @override
  State<CreateAppointment_Widget> createState() => _CreateAppointment_WidgetState();
}

class _CreateAppointment_WidgetState extends State<CreateAppointment_Widget>
    with SingleTickerProviderStateMixin {
  final _timeCtrl = TextEditingController(text: '09:00');
  late DateTime _selectedDate;
  String _patientId = '';
  String _patientName = '';
  String? _patientPhoto;
  String _clinicId = '';
  String _dentistId = '';
  String _dentistName = '';
  TreatmentModel? _selectedTreatment;
  List<TreatmentModel> _treatments = [];
  bool _treatmentsLoading = true;
  bool _saving = false;

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    if (widget.initialPatientId != null) {
      _patientId = widget.initialPatientId!;
      _patientName = widget.initialPatientName ?? '';
    }
    _clinicId = widget.clinicId ?? '';
    _dentistId = widget.userId ?? '';
    _dentistName = widget.userName ?? '';

    _animCtrl =
        AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _animCtrl.forward();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    if (_clinicId.isEmpty) {
      try {
        _clinicId = context.read<DentistClinicProvider>().clinic?.id ?? '';
      } catch (_) {}
    }
    if (_clinicId.isEmpty) {
      setState(() => _treatmentsLoading = false);
      return;
    }
    try {
      final cp = context.read<DentistClinicProvider>();
      if (cp.treatments.isEmpty) await cp.loadTreatments();
      if (mounted) setState(() {
        _treatments = cp.treatments;
        _treatmentsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _treatmentsLoading = false);
    }
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_clinicId.isEmpty) {
      try {
        _clinicId = context.read<DentistClinicProvider>().clinic?.id ?? '';
      } catch (_) {}
    }
    if (widget.isPatientMode) {
      if (_patientId.isEmpty) {
        try {
          final user = context.read<AuthenticateProvider>().user;
          _patientId = user?.uid ?? '';
          _patientName = user?.fullName ?? '';
        } catch (_) {}
      }
    } else {
      if (_dentistId.isEmpty) {
        try {
          final user = context.read<AuthenticateProvider>().user;
          _dentistId = user?.uid ?? '';
          _dentistName = user?.fullName ?? '';
        } catch (_) {}
      }
    }

    return Material(
      color: Colors.white,
      child: AnimatedBuilder(
        animation: _animCtrl,
        builder: (context, _) => FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration:
                    BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_back, size: 20, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.calendar_month, color: Color(0xFF4F46E5), size: 24),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Nueva Cita',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text('Completa los datos para agendar',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ]),
            ]),
            const SizedBox(height: 24),
            if (widget.isPatientMode)
              _SectionField(
                icon: Icons.person,
                label: 'Paciente',
                child: Row(children: [
                  Expanded(
                    child: Text(_patientName.isNotEmpty ? _patientName : 'Cargando...',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800])),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Tú',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0D9488))),
                  ),
                ]),
              )
            else
              _SectionField(
                icon: Icons.person,
                label: 'Paciente',
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => PatientSearchSheet(
                        clinicId: _clinicId,
                        onSelected: (id, name, photo) => setState(() {
                          _patientId = id;
                          _patientName = name;
                          _patientPhoto = photo;
                        }),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _patientName.isNotEmpty
                          ? const Color(0xFF0D9488).withOpacity(0.06)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _patientName.isNotEmpty
                            ? const Color(0xFF0D9488).withOpacity(0.2)
                            : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          _patientName.isNotEmpty
                              ? _patientName
                              : 'Toca para buscar paciente...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _patientName.isNotEmpty
                                ? const Color(0xFF1A1A1A)
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                      Icon(Icons.search, size: 18,
                          color: _patientName.isNotEmpty
                              ? const Color(0xFF0D9488)
                              : Colors.grey[400]),
                    ]),
                  ),
                ),
              ),
            if (widget.isPatientMode) ...[
              const SizedBox(height: 14),
              _SectionField(
                icon: Icons.medical_services_outlined,
                label: 'Especialista',
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => DentistSearchSheet(
                        clinicId: _clinicId,
                        onSelected: (id, name, photo) => setState(() {
                          _dentistId = id;
                          _dentistName = name;
                        }),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _dentistName.isNotEmpty
                          ? const Color(0xFF4F46E5).withOpacity(0.06)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _dentistName.isNotEmpty
                            ? const Color(0xFF4F46E5).withOpacity(0.2)
                            : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          _dentistName.isNotEmpty
                              ? _dentistName
                              : 'Seleccionar especialista...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _dentistName.isNotEmpty
                                ? const Color(0xFF1A1A1A)
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                      Icon(Icons.search, size: 18,
                          color: _dentistName.isNotEmpty
                              ? const Color(0xFF4F46E5)
                              : Colors.grey[400]),
                    ]),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            _SectionField(
              icon: Icons.medical_services_outlined,
              label: 'Tratamiento',
              child: _treatmentsLoading
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.center,
                      child:
                          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)))
                  : _treatments.isEmpty
                      ? TextField(
                          controller: TextEditingController(),
                          decoration: InputDecoration(
                            hintText: 'Escribe el tratamiento...',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        )
                      : _TreatmentGrid(
                          treatments: _treatments,
                          selected: _selectedTreatment,
                          onSelect: (t) => setState(() => _selectedTreatment = t),
                        ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _SectionField(
                  icon: Icons.calendar_today,
                  label: 'Fecha',
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (ctx, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme:
                                const ColorScheme.light(primary: Color(0xFF4F46E5)),
                          ),
                          child: child!,
                        ),
                      );
                      if (d != null) setState(() => _selectedDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800]),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[400]),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SectionField(
                  icon: Icons.access_time,
                  label: 'Hora',
                  child: TextField(
                    controller: _timeCtrl,
                    decoration: InputDecoration(
                      hintText: 'HH:MM',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _saving ? null : _createAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF4F46E5).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 20, color: Colors.white.withOpacity(0.9)),
                            const SizedBox(width: 8),
                            const Text('Agendar Cita',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAppointment() async {
    if (_patientName.isEmpty) return;
    final treatment = _selectedTreatment;
    if (treatment == null) return;

    if (widget.isPatientMode && _dentistName.isEmpty) return;

    setState(() => _saving = true);
    final pid = _patientId.isNotEmpty
        ? _patientId
        : 'walkin_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await context.read<AppointmentProvider>().bookAppointment(
        clinicId: _clinicId,
        patientId: pid,
        patientName: _patientName,
        patientPhoto: _patientPhoto,
        dentistId: _dentistId,
        dentistName: _dentistName,
        treatmentName: treatment.name,
        date: _selectedDate,
        timeSlot: _timeCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cita creada exitosamente',
                style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        );
        widget.onCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        );
      }
    }
  }
}

class _TreatmentGrid extends StatelessWidget {
  final List<TreatmentModel> treatments;
  final TreatmentModel? selected;
  final ValueChanged<TreatmentModel> onSelect;

  const _TreatmentGrid({
    required this.treatments,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: treatments.length,
      itemBuilder: (_, i) => _TreatmentCard(
        treatment: treatments[i],
        isSelected: selected?.id == treatments[i].id,
        onTap: () => onSelect(treatments[i]),
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final TreatmentModel treatment;
  final bool isSelected;
  final VoidCallback onTap;

  const _TreatmentCard({
    required this.treatment,
    required this.isSelected,
    required this.onTap,
  });

  Color get _categoryColor {
    switch (treatment.category) {
      case 'preventivo':
        return const Color(0xFF0D9488);
      case 'estético':
        return const Color(0xFFDB2777);
      case 'ortodoncia':
        return const Color(0xFF7C3AED);
      case 'endodoncia':
        return const Color(0xFF2563EB);
      case 'implante':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  IconData get _icon {
    switch (treatment.iconName) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'whitening':
        return Icons.auto_awesome;
      case 'braces':
        return Icons.settings;
      case 'implant':
        return Icons.construction;
      case 'root-canal':
        return Icons.psychology;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_icon, size: 16, color: isSelected ? Colors.white : color),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(treatment.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
                const SizedBox(height: 2),
                Text('\$${treatment.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.grey[500],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionField extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _SectionField(
      {required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(children: [
            Icon(icon, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500)),
          ]),
        ),
        child,
      ],
    );
  }
}
