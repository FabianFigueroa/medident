import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/models/patient-model.dart';
import 'package:medident/core/models/turno-model.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/dentist/dentist-agenda-provider.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:medident/core/providers/dentist/dentist-turnos-provider.dart';
import 'package:medident/core/providers/dentist/dentist-clinic-provider.dart';
import 'package:medident/core/providers/domain/appointment-provider.dart';
import 'package:medident/screens/shared/notification-screen.dart';
import 'package:medident/screens/role/dentist/clinic/patients/patient-detail-screen.dart';
import 'package:medident/screens/role/dentist/clinic/onboarding/clinic-onboarding-screen.dart';
import 'package:medident/screens/widgets/shared/create_appointment_sheet.dart';
import 'package:medident/screens/widgets/shared/request_turno_change_sheet.dart';
import 'package:provider/provider.dart';

const _accent = Color(0xFF0EA5A4);
const _text = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _pendingColor = Color(0xFFF59E0B);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _startOfWeek(DateTime d) {
  final day = _dateOnly(d);
  return day.subtract(Duration(days: day.weekday - 1));
}
String _key(DateTime d) => '${d.year}_${d.month}_${d.day}';

// ═══════════════════════════════════════════════════════════════════
// AGENDA PERSONAL DEL DENTISTA (citas clínicas)
// ═══════════════════════════════════════════════════════════════════
class DentistAgendaScreen extends StatelessWidget {
  const DentistAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.read<DentistMainProvider>();
    return ChangeNotifierProvider<MainProviderBase>.value(
      value: mainProvider,
      child: const PersonalAgendaView(
        title: 'Mi agenda',
        clinicSection: 'clinicStatus',
      ),
    );
  }
}

/// Vista de agenda reutilizable por cualquier rol clínico (dentista, doctor,
/// empleado). Requiere que el `MainProviderBase` del rol esté disponible en el
/// árbol y que registre las sub-secciones [clinicSection] y `agenda`.
class PersonalAgendaView extends StatefulWidget {
  final String title;
  final String? clinicSection;
  final bool allowCreate;

  const PersonalAgendaView({
    super.key,
    required this.title,
    this.clinicSection,
    this.allowCreate = true,
  });

  @override
  State<PersonalAgendaView> createState() => _PersonalAgendaViewState();
}

class _PersonalAgendaViewState extends State<PersonalAgendaView> {
  String? _initializedForUserId;
  bool _initializing = true;
  DateTime _selectedDay = _dateOnly(DateTime.now());
  DateTime _weekStart = _startOfWeek(DateTime.now());
  bool _weekView = false;
  String? _patientFilterId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<MainProviderBase>();
    if (mainProvider.userId.isEmpty ||
        _initializedForUserId == mainProvider.userId) {
      return;
    }
    _initializedForUserId = mainProvider.userId;
    // initializeSection notifica a los listeners; llamarlo durante la
    // construcción rompía el árbol ("setState() called during build").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initialize(mainProvider);
    });
  }

  Future<void> _initialize(MainProviderBase mainProvider) async {
    final clinicSection = widget.clinicSection;
    var clinicId = '';
    if (clinicSection != null) {
      await mainProvider.initializeSection(clinicSection);
      var clinicProvider =
          mainProvider.getTypedProvider<DentistClinicProvider>(clinicSection);
      if (clinicProvider == null) {
        await mainProvider.initializeSection(clinicSection);
        clinicProvider =
            mainProvider.getTypedProvider<DentistClinicProvider>(clinicSection);
      } else if (clinicProvider.clinic == null) {
        await clinicProvider.refresh(mainProvider.userId);
      }
      clinicId = mainProvider
              .getTypedProvider<DentistClinicProvider>(clinicSection)
              ?.clinic
              ?.id ??
          '';
    }

    final existing =
        mainProvider.getTypedProvider<DentistAgendaProvider>('agenda');
    if (existing != null && existing.clinicId != clinicId) {
      mainProvider.clearSection('agenda');
    }
    await mainProvider.initializeSection('agenda');

    if (!mounted) return;
    setState(() => _initializing = false);
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.watch<MainProviderBase>();
    final agenda =
        mainProvider.getTypedProvider<DentistAgendaProvider>('agenda');
    final loading = _initializing ||
        (agenda == null &&
            (mainProvider.isSectionLoading('agenda') ||
                (widget.clinicSection != null &&
                    mainProvider.isSectionLoading(widget.clinicSection!))));
    final clinicId = agenda?.clinicId ?? '';
    final userId = mainProvider.userId;
    final canManage = widget.clinicSection == null
        ? true
        : mainProvider
                .getTypedProvider<DentistClinicProvider>(widget.clinicSection!)
                ?.canManageAgenda ??
            false;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0.4,
        title: Text(widget.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationScreen.conProveedor(context)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton:
          !widget.allowCreate || clinicId.isEmpty || !canManage
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva cita'),
                  onPressed: () => _openCreateAppointment(context, userId),
                ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: loading || agenda == null
          ? const _AgendaSkeleton()
          : (widget.clinicSection != null && clinicId.isEmpty)
              ? _NoClinicState(onRetry: () => _initialize(mainProvider))
              : ChangeNotifierProvider.value(
                  value: agenda,
                  child: Consumer<DentistAgendaProvider>(
                    builder: (context, provider, _) {
                      final mine = provider.mine;
                      final filtered = _patientFilterId == null
                          ? mine
                          : mine
                              .where((a) => a.patientId == _patientFilterId)
                              .toList();
                      return _AgendaBody(
                        agenda: provider,
                        filtered: filtered,
                        selectedDay: _selectedDay,
                        weekStart: _weekStart,
                        weekView: _weekView,
                        patientFilterId: _patientFilterId,
                        onRefresh: provider.refresh,
                        onSelectDay: (d) => setState(() {
                          _selectedDay = d;
                          _weekStart = _startOfWeek(d);
                        }),
                        onPrevWeek: () => setState(() {
                          _weekStart =
                              _weekStart.subtract(const Duration(days: 7));
                          _selectedDay = _weekStart;
                        }),
                        onNextWeek: () => setState(() {
                          _weekStart = _weekStart.add(const Duration(days: 7));
                          _selectedDay = _weekStart;
                        }),
                        onPickDate: () => _pickDate(),
                        onToggleView: (v) => setState(() => _weekView = v),
                        onFilterPatient: (id) => setState(() =>
                            _patientFilterId = _patientFilterId == id ? null : id),
                        onOpenPatient: (p) => _openPatient(context, p),
                        onOpenAppointment: (a) =>
                            _showAppointmentActions(
                                context, a, provider, canManage),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
      helpText: 'Seleccionar día',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() {
        _selectedDay = _dateOnly(picked);
        _weekStart = _startOfWeek(picked);
      });
    }
  }

  Future<DentistClinicProvider?> _clinicProvider(BuildContext context) async {
    final section = widget.clinicSection;
    if (section == null) return null;
    final main = context.read<MainProviderBase>();
    var cp = main.getTypedProvider<DentistClinicProvider>(section);
    if (cp == null) {
      await main.initializeSection(section);
      cp = main.getTypedProvider<DentistClinicProvider>(section);
    }
    return cp;
  }

  Future<void> _openPatient(BuildContext context, PatientModel patient) async {
    final cp = await _clinicProvider(context);
    if (cp == null || !context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: cp,
          child: PatientDetailScreen(patient: patient),
        ),
      ),
    );
  }

  Future<void> _openCreateAppointment(
      BuildContext context, String userId) async {
    final agenda = context
        .read<MainProviderBase>()
        .getTypedProvider<DentistAgendaProvider>('agenda');
    if (agenda == null) return;
    final cp = await _clinicProvider(context);
    if (cp == null || !context.mounted) return;
    final user = context.read<AuthenticateProvider>().user;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<AppointmentProvider>.value(
              value: agenda.appointmentProvider,
            ),
            ChangeNotifierProvider.value(value: cp),
          ],
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: _text,
              title: const Text('Nueva cita'),
            ),
            body: CreateAppointment_Widget(
              clinicId: agenda.clinicId,
              userId: userId,
              userName: user?.fullName ?? '',
              userPhoto: user?.imageUrl,
            ),
          ),
        ),
      ),
    );
  }

  void _showAppointmentActions(BuildContext context,
      AppointmentModel appointment, DentistAgendaProvider prov, bool canManage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(appointment.patientName,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: _text)),
            const SizedBox(height: 4),
            Text(
              '${DateFormat("d 'de' MMMM", 'es').format(appointment.date)} · ${appointment.timeSlot}',
              style: const TextStyle(fontSize: 13, color: _muted),
            ),
            const SizedBox(height: 4),
            Text(appointment.treatmentName,
                style: const TextStyle(fontSize: 13, color: _text)),
            if ((appointment.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(appointment.notes!,
                  style: const TextStyle(fontSize: 12.5, color: _muted)),
            ],
            const SizedBox(height: 18),
            if (!canManage)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: _muted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Solo el dueño o el equipo autorizado puede modificar la agenda.',
                        style: TextStyle(fontSize: 11.5, color: _muted),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  // RN-30: solo una cita pendiente se confirma, y la confirma
                  // el profesional o la clínica, no el paciente de la cita.
                  if (appointment.status == 'pending' &&
                      appointment.patientId != prov.userId)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await prov.updateStatus(
                              appointment.id, 'confirmed');
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Confirmar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (appointment.status == 'pending' &&
                      appointment.patientId != prov.userId)
                    const SizedBox(width: 10),
                  if (appointment.status == 'pending' ||
                      appointment.status == 'confirmed')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await prov.updateStatus(
                            appointment.id, 'cancelled');
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CUERPO COMPARTIDO DE AGENDA (pacientes + calendario + lista)
// ═══════════════════════════════════════════════════════════════════
class _AgendaBody extends StatelessWidget {
  final DentistAgendaProvider agenda;
  final List<AppointmentModel> filtered;
  final DateTime selectedDay;
  final DateTime weekStart;
  final bool weekView;
  final String? patientFilterId;
  final Future<void> Function() onRefresh;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onPickDate;
  final ValueChanged<bool> onToggleView;
  final ValueChanged<String> onFilterPatient;
  final ValueChanged<PatientModel> onOpenPatient;
  final ValueChanged<AppointmentModel> onOpenAppointment;

  const _AgendaBody({
    required this.agenda,
    required this.filtered,
    required this.selectedDay,
    required this.weekStart,
    required this.weekView,
    required this.patientFilterId,
    required this.onRefresh,
    required this.onSelectDay,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onPickDate,
    required this.onToggleView,
    required this.onFilterPatient,
    required this.onOpenPatient,
    required this.onOpenAppointment,
  });

  List<AppointmentModel> get _visible {
    if (!weekView) {
      final k = _key(selectedDay);
      return filtered.where((a) => _key(a.date) == k).toList()
        ..sort(_porFechaYHora);
    }
    final end = weekStart.add(const Duration(days: 7));
    return filtered
        .where((a) =>
            !_dateOnly(a.date).isBefore(weekStart) &&
            _dateOnly(a.date).isBefore(end))
        .toList()
      ..sort(_porFechaYHora);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _accent,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _buildTodayHeader(),
          _buildPatients(context),
          _ModernWeekStrip(
            anchor: weekStart,
            selected: selectedDay,
            counts: agenda.dayCounts,
            onSelect: onSelectDay,
            onPrev: onPrevWeek,
            onNext: onNextWeek,
            onPickDate: onPickDate,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Row(
              children: [
                Text(weekView ? 'Semana' : 'Día',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _text)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${_visible.length}',
                      style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _accent)),
                ),
                const Spacer(),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle:
                        WidgetStateProperty.all(const TextStyle(fontSize: 12)),
                  ),
                  segments: const [
                    ButtonSegment(value: false, label: Text('Día')),
                    ButtonSegment(value: true, label: Text('Semana')),
                  ],
                  selected: {weekView},
                  onSelectionChanged: (s) => onToggleView(s.first),
                ),
              ],
            ),
          ),
          ..._buildGroupedList(),
        ],
      ),
    );
  }

  Widget _buildTodayHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5A4), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -24,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _headerStat('Hoy', '${agenda.todayCount}', 'citas'),
              ),
              Container(width: 1, height: 38, color: Colors.white24),
              Expanded(
                child: _headerStat(
                    'Pendientes', '${agenda.pendingCount}', 'por confirmar'),
              ),
              Container(width: 1, height: 38, color: Colors.white24),
              Expanded(
                child: _headerStat(
                    'Pacientes', '${agenda.uniquePatientsCount}', 'en agenda'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, String sub) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Text(sub,
            style: TextStyle(
                fontSize: 10.5, color: Colors.white.withOpacity(0.85))),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildPatients(BuildContext context) {
    final patients = agenda.patients;
    final requesters = agenda.requesters;
    final selectedPatient = agenda.patientById(patientFilterId);
    if (patients.isEmpty && requesters.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D0F172A),
              blurRadius: 12,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.people_alt_outlined,
                    size: 14, color: _accent),
              ),
              const SizedBox(width: 7),
              const Text('Pacientes',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _text)),
              const Spacer(),
              if (requesters.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _pendingColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${requesters.length} solicitud(es)',
                      style: const TextStyle(
                          fontSize: 10,
                          color: _pendingColor,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in patients)
                  _patientAvatar(
                    name: p.fullName,
                    photo: p.photo,
                    isRequester: false,
                    selected: p.id == patientFilterId,
                    onTap: () => onFilterPatient(p.id),
                    onLongPress: () => onOpenPatient(p),
                  ),
                for (final r in requesters)
                  _patientAvatar(
                    name: r.patientName,
                    photo: r.patientPhoto,
                    isRequester: true,
                    selected: r.patientId == patientFilterId,
                    onTap: () => onFilterPatient(r.patientId),
                    onLongPress: () => onOpenAppointment(r),
                  ),
              ],
            ),
          ),
          if (selectedPatient != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedPatient.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _text),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => onOpenPatient(selectedPatient),
                    icon: const Icon(Icons.folder_open_outlined, size: 16),
                    label: const Text('Historia clínica',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: _accent),
                  ),
                  InkWell(
                    onTap: () => onFilterPatient(selectedPatient.id),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child:
                          Icon(Icons.close, size: 16, color: _muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _patientAvatar({
    required String name,
    String? photo,
    required bool isRequester,
    required bool selected,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? _accent
                          : isRequester
                              ? _pendingColor
                              : const Color(0xFFE2E8F0),
                      width: selected || isRequester ? 2.4 : 1.4,
                    ),
                  ),
                  child: ClipOval(
                    child: photo != null && photo.isNotEmpty
                        ? Image.network(photo, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _initials(initial))
                        : _initials(initial),
                  ),
                ),
                if (isRequester)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: _pendingColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.priority_high,
                          size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              name.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _accent : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(String initial) {
    return Container(
      color: _accent.withOpacity(0.1),
      alignment: Alignment.center,
      child: Text(initial,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: _accent)),
    );
  }

  List<Widget> _buildGroupedList() {
    final visible = _visible;
    if (visible.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 44),
          child: Column(
            children: [
              Icon(Icons.event_available, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Text('No hay citas ${weekView ? 'esta semana' : 'este día'}',
                  style: const TextStyle(fontSize: 13.5, color: _muted)),
            ],
          ),
        ),
      ];
    }
    final groups = <String, List<AppointmentModel>>{};
    for (final a in visible) {
      groups.putIfAbsent(_key(a.date), () => []).add(a);
    }
    final widgets = <Widget>[];
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
        final da = groups[a]!.first.date;
        final db = groups[b]!.first.date;
        return da.compareTo(db);
      });
    for (final k in sortedKeys) {
      final list = groups[k]!
        ..sort((a, b) {
          final c = a.date.compareTo(b.date);
          return c != 0 ? c : a.timeSlot.compareTo(b.timeSlot);
        });
      final day = list.first.date;
      final isToday = _dateOnly(day) == _dateOnly(DateTime.now());
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Row(
          children: [
            Text(
              isToday
                  ? 'Hoy'
                  : DateFormat("EEEE d 'de' MMMM", 'es').format(day),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _text),
            ),
            const SizedBox(width: 8),
            Text('${list.length} cita(s)',
                style: const TextStyle(fontSize: 11, color: _muted)),
          ],
        ),
      ));
      for (final a in list) {
        widgets.add(_appointmentCard(a));
      }
    }
    return widgets;
  }

  Widget _appointmentCard(AppointmentModel a) {
    final color = _statusColor(a.status);
    return GestureDetector(
      onTap: () => onOpenAppointment(a),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(a.timeSlot,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  Text('hs',
                      style: TextStyle(fontSize: 9, color: color.withOpacity(0.7))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: _text)),
                  const SizedBox(height: 2),
                  Text(a.treatmentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(_statusLabel(a.status),
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF16A34A);
      case 'completed':
        return const Color(0xFF2563EB);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return _pendingColor;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmada';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Pendiente';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// AGENDA DE TURNOS LABORALES
// ═══════════════════════════════════════════════════════════════════
class DentistTurnosAgendaScreen extends StatelessWidget {
  const DentistTurnosAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.read<DentistMainProvider>();
    return ChangeNotifierProvider<MainProviderBase>.value(
      value: mainProvider,
      child: const PersonalTurnosView(title: 'Mis turnos laborales'),
    );
  }
}

/// Vista de turnos laborales reutilizable por cualquier rol con turnos.
class PersonalTurnosView extends StatefulWidget {
  final String title;

  const PersonalTurnosView({super.key, required this.title});

  @override
  State<PersonalTurnosView> createState() => _PersonalTurnosViewState();
}

class _PersonalTurnosViewState extends State<PersonalTurnosView> {
  String? _initializedForUserId;
  bool _initializing = true;
  DateTime _selectedDay = _dateOnly(DateTime.now());
  DateTime _weekStart = _startOfWeek(DateTime.now());
  bool _weekView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<MainProviderBase>();
    if (mainProvider.userId.isEmpty ||
        _initializedForUserId == mainProvider.userId) {
      return;
    }
    _initializedForUserId = mainProvider.userId;
    // initializeSection notifica a los listeners; llamarlo durante la
    // construcción rompía el árbol ("setState() called during build").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initialize(mainProvider);
    });
  }

  Future<void> _initialize(MainProviderBase mainProvider) async {
    await mainProvider.initializeSection('turnos');
    if (!mounted) return;
    setState(() => _initializing = false);
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.watch<MainProviderBase>();
    final provider =
        mainProvider.getTypedProvider<DentistTurnosProvider>('turnos');
    final loading = _initializing ||
        (provider == null && mainProvider.isSectionLoading('turnos'));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0.4,
        title: Text(widget.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationScreen.conProveedor(context)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: provider == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.post_add_rounded),
              label: const Text('Solicitud'),
              onPressed: () => _openSolicitud(context, provider),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: loading || provider == null
          ? const _AgendaSkeleton()
          : ChangeNotifierProvider.value(
              value: provider,
              child: Consumer<DentistTurnosProvider>(
                builder: (context, turnosProvider, _) {
                  final visible = _weekView
                      ? turnosProvider.byWeek(_weekStart)
                      : turnosProvider.byDay(_selectedDay);
                  return RefreshIndicator(
                    color: const Color(0xFF4F46E5),
                    onRefresh: () async => turnosProvider.refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 90),
                      children: [
                        _buildTopSummary(turnosProvider),
                        _ModernWeekStrip(
                          anchor: _weekStart,
                          selected: _selectedDay,
                          counts: turnosProvider.dayCounts,
                          onSelect: (d) => setState(() {
                            _selectedDay = d;
                            _weekStart = _startOfWeek(d);
                          }),
                          onPrev: () => setState(() {
                            _weekStart =
                                _weekStart.subtract(const Duration(days: 7));
                            _selectedDay = _weekStart;
                          }),
                          onNext: () => setState(() {
                            _weekStart =
                                _weekStart.add(const Duration(days: 7));
                            _selectedDay = _weekStart;
                          }),
                          onPickDate: _pickDate,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                          child: Row(
                            children: [
                              Text(_weekView ? 'Semana' : 'Día',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _text)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${visible.length}',
                                    style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF4F46E5))),
                              ),
                              const Spacer(),
                              SegmentedButton<bool>(
                                showSelectedIcon: false,
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  textStyle: WidgetStateProperty.all(
                                      const TextStyle(fontSize: 12)),
                                ),
                                segments: const [
                                  ButtonSegment(
                                      value: false, label: Text('Día')),
                                  ButtonSegment(
                                      value: true, label: Text('Semana')),
                                ],
                                selected: {_weekView},
                                onSelectionChanged: (s) =>
                                    setState(() => _weekView = s.first),
                              ),
                            ],
                          ),
                        ),
                        if (visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 44),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.work_off_outlined,
                                      size: 36, color: Color(0xFF6366F1)),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                    'No tienes turnos ${_weekView ? 'esta semana' : 'este día'}',
                                    style: const TextStyle(
                                        fontSize: 13.5, color: _muted)),
                              ],
                            ),
                          )
                        else
                          ..._buildGroups(visible, turnosProvider),
                      ],
                    ),
                  );
                },
              ),
            ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
      helpText: 'Seleccionar día',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() {
        _selectedDay = _dateOnly(picked);
        _weekStart = _startOfWeek(picked);
      });
    }
  }

  Widget _buildTopSummary(DentistTurnosProvider provider) {
    final next = provider.nextTurno();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _turnoStat('Hoy', '${provider.todayCount}', 'turnos'),
              ),
              Container(width: 1, height: 38, color: Colors.white24),
              Expanded(
                child: _turnoStat(
                    'Próximos', '${provider.upcomingCount}', 'programados'),
              ),
              Container(width: 1, height: 38, color: Colors.white24),
              Expanded(
                child:
                    _turnoStat('Activos', '${provider.activeCount}', 'en curso'),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 15, color: Colors.white70),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Próximo turno: ${next.displayDate} · ${next.startTime} - ${next.endTime}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _turnoStat(String label, String value, String sub) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Text(sub,
            style: TextStyle(
                fontSize: 10.5, color: Colors.white.withOpacity(0.85))),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }

  List<Widget> _buildGroups(
      List<TurnoModel> visible, DentistTurnosProvider provider) {
    final groups = <String, List<TurnoModel>>{};
    for (final t in visible) {
      groups.putIfAbsent(_key(t.date), () => []).add(t);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) => groups[a]!.first.date.compareTo(groups[b]!.first.date));
    final widgets = <Widget>[];
    for (final k in keys) {
      final list = groups[k]!..sort((a, b) => a.startTime.compareTo(b.startTime));
      final day = list.first.date;
      final isToday = _dateOnly(day) == _dateOnly(DateTime.now());
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Row(
          children: [
            Text(
              isToday ? 'Hoy' : DateFormat("EEEE d 'de' MMMM", 'es').format(day),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _text),
            ),
            const SizedBox(width: 8),
            Text('${list.length} turno(s)',
                style: const TextStyle(fontSize: 11, color: _muted)),
            const Spacer(),
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: _accent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: list.isEmpty
                  ? null
                  : () => _openSolicitud(context, provider, turno: list.first),
              icon: const Icon(Icons.report_problem_outlined, size: 15),
              label: const Text('Novedad', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ));
      for (final t in list) {
        widgets.add(_turnoCard(t, provider));
      }
    }
    return widgets;
  }

  Widget _turnoCard(TurnoModel t, DentistTurnosProvider provider) {
    final color = _turnoColor(t.status);
    final countdown = _countdown(t);
    final pending = t.attendanceStatus == 'pending';
    final confirmed = t.attendanceStatus == 'confirmed';
    final declined = t.attendanceStatus == 'declined';
    final canRespond = pending &&
        t.status != 'completed' &&
        t.status != 'cancelled' &&
        _daysUntil(t) >= 0 &&
        _daysUntil(t) <= 7;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${t.startTime} - ${t.endTime}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _text)),
                    const SizedBox(height: 2),
                    Text(
                      (t.notes ?? '').isNotEmpty ? t.notes! : 'Turno laboral',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                    if (countdown != null) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.timer_outlined,
                            size: 12,
                            color: _daysUntil(t) <= 1
                                ? const Color(0xFFDC2626)
                                : _accent),
                        const SizedBox(width: 4),
                        Text(countdown,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _daysUntil(t) <= 1
                                    ? const Color(0xFFDC2626)
                                    : _accent)),
                      ]),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(_turnoLabel(t.status),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color)),
                  ),
                  if (confirmed || declined) ...[
                    const SizedBox(height: 5),
                    _attendanceChip(confirmed),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (canRespond) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFFBBF7D0)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => _confirmAttendance(context, provider, t),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Confirmar',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => _declineAttendance(context, provider, t),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Declinar',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (pending && !canRespond && _daysUntil(t) > 7)
                const Expanded(
                  child: Text('Podrás confirmar 7 días antes.',
                      style: TextStyle(fontSize: 11, color: _muted)),
                ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: _pendingColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () => _openSolicitud(context, provider, turno: t),
                icon: const Icon(Icons.edit_note, size: 16),
                label: const Text('Novedad', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceChip(bool confirmed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: confirmed
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        confirmed ? 'Asistiré' : 'No asistiré',
        style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: confirmed
                ? const Color(0xFF15803D)
                : const Color(0xFFB91C1C)),
      ),
    );
  }

  int _daysUntil(TurnoModel t) {
    final today = _dateOnly(DateTime.now());
    final day = _dateOnly(t.date);
    return day.difference(today).inDays;
  }

  String? _countdown(TurnoModel t) {
    final parts = t.startTime.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final start =
        DateTime(t.date.year, t.date.month, t.date.day, hour, minute);
    final diff = start.difference(DateTime.now());
    if (diff.isNegative) return null;
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    if (days > 0) return 'Faltan ${days}d ${hours}h';
    if (hours > 0) return 'Faltan ${hours}h ${minutes}m';
    return 'Empieza en ${minutes}m';
  }

  Future<void> _confirmAttendance(BuildContext context,
      DentistTurnosProvider provider, TurnoModel turno) async {
    try {
      await provider.confirmAttendance(turno);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asistencia confirmada'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo confirmar: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _declineAttendance(BuildContext context,
      DentistTurnosProvider provider, TurnoModel turno) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Declinar asistencia'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Motivo (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.pop(ctx, reasonCtrl.text.trim()),
            child: const Text('Declinar'),
          ),
        ],
      ),
    );
    // El diálogo sigue animando su salida (y usando el TextField) un momento
    // después de cerrarse; liberar el controlador en ese instante rompía la
    // pantalla. Se libera cuando la animación ya terminó.
    Future.delayed(const Duration(milliseconds: 600), reasonCtrl.dispose);
    if (reason == null) return;
    try {
      await provider.declineAttendance(turno,
          reason: reason.isEmpty ? null : reason);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asistencia declinada. Se notificó a la clínica.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo declinar: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openSolicitud(
    BuildContext context,
    DentistTurnosProvider provider, {
    TurnoModel? turno,
  }) {
    final turnos = provider.turnos;
    TurnoModel? selected = turno;
    if (selected == null) {
      final dayList = provider.byDay(_selectedDay);
      if (dayList.isNotEmpty) {
        selected = dayList.first;
      } else if (turnos.isNotEmpty) {
        selected = turnos.first;
      }
    }
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes turnos asignados para gestionar'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final chosen = selected;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestTurnoChangeSheet(
        turnoId: chosen.id,
        employeeName: chosen.employeeName,
        employeeId: chosen.employeeId,
        turnos: turnos,
        initialTurnoId: chosen.id,
      ),
    );
  }

  Color _turnoColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF16A34A);
      case 'completed':
        return const Color(0xFF2563EB);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return _pendingColor;
    }
  }

  String _turnoLabel(String status) {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Programado';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// SELECTOR DE SEMANA MODERNO + ESTADO SIN CLÍNICA
// ═══════════════════════════════════════════════════════════════════
class _ModernWeekStrip extends StatelessWidget {
  final DateTime anchor;
  final DateTime selected;
  final Map<String, int> counts;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  const _ModernWeekStrip({
    required this.anchor,
    required this.selected,
    required this.counts,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final start = _startOfWeek(anchor);
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final monthLabel = DateFormat('MMMM yyyy', 'es').format(start);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0D0F172A), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left_rounded, color: _muted),
              ),
              Expanded(
                child: Text(
                  monthLabel[0].toUpperCase() + monthLabel.substring(1),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _text),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded, color: _muted),
              ),
              IconButton(
                onPressed: onPickDate,
                icon: const Icon(Icons.calendar_month_rounded, color: _accent),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final d in days)
                Expanded(child: _dayCell(d)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime d) {
    final isSelected = _dateOnly(d) == _dateOnly(selected);
    final isToday = _dateOnly(d) == _dateOnly(DateTime.now());
    final count = counts[_key(d)] ?? 0;
    final weekdays = const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return GestureDetector(
      onTap: () => onSelect(d),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              weekdays[d.weekday - 1],
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white70
                    : isToday
                        ? _accent
                        : _muted,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${d.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? _accent
                        : _text,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: count == 0
                    ? Colors.transparent
                    : isSelected
                        ? Colors.white
                        : _accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaSkeleton extends StatelessWidget {
  const _AgendaSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EDF3),
      highlightColor: const Color(0xFFF7FAFC),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 118,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < 4; i++) ...[
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _NoClinicState extends StatelessWidget {
  final VoidCallback onRetry;

  const _NoClinicState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accent.withOpacity(0.15),
                    const Color(0xFF0891B2).withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_hospital_outlined,
                  size: 52, color: _accent),
            ),
            const SizedBox(height: 18),
            const Text('Aún no tienes una clínica',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: _text)),
            const SizedBox(height: 8),
            const Text(
              'Crea tu clínica o únete a una para gestionar las citas de tus pacientes en tiempo real.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ClinicOnboardingScreen()),
                  );
                  onRetry();
                },
                icon: const Icon(Icons.add_business_rounded, size: 19),
                label: const Text('Crear o unirme a una clínica'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ordena citas por día y, dentro del día, por franja horaria (HH:mm).
int _porFechaYHora(AppointmentModel a, AppointmentModel b) {
  final c = a.date.compareTo(b.date);
  return c != 0 ? c : a.timeSlot.compareTo(b.timeSlot);
}
