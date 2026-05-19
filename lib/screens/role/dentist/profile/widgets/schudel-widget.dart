import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/dentist/profile/widgets/day-selector-widget.dart';
import 'package:medident/screens/role/dentist/profile/widgets/schudel-calendar-widget.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-schudel-model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = true;
  String? _error;

  List<DentistSchudelModel> _appointments = [];
  List<UserSchudelModel> _doctors = [];
  UserSchudelModel? _currentUser;
  Set<DateTime> _datesWithAppointments = {};

  static final Map<String, List<DentistSchudelModel>> _cache = {};
  static UserSchudelModel? _cachedCurrentUser;
  static List<UserSchudelModel> _cachedDoctors = [];
  static DateTime _lastUserFetch = DateTime(2000);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _ensureUsersLoaded();
      await _loadAppointmentsForDate(_selectedDate);
    } catch (e) {
      setState(() => _error = 'Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _ensureUsersLoaded() async {
    final now = DateTime.now();
    if (_cachedDoctors.isNotEmpty &&
        now.difference(_lastUserFetch).inMinutes < 5) {
      return;
    }

    final fs = FirebaseFirestore.instance;
    final usersSnap = await fs.collection('users').limit(50).get();

    final allUsers = usersSnap.docs.map((doc) {
      final data = doc.data();
      return UserSchudelModel(
        uid: doc.id,
        fullName: data['fullName'] ?? data['name'] ?? 'Sin nombre',
        firstName: data['firstName'] ?? data['name']?.toString().split(' ').first ?? '',
        avatarUrl: data['avatarUrl'] ?? '',
        role: data['role'] ?? 'doctor',
        specialty: data['specialty'] ?? '',
        avatarColor: Colors.primaries[doc.id.hashCode % Colors.primaries.length],
        hasActiveStory: false,
        storyIsSeen: false,
      );
    }).toList();

    _cachedDoctors = allUsers.where((u) => u.role == 'doctor' || u.role == 'dentist').toList();
    _cachedCurrentUser = _cachedDoctors.isNotEmpty ? _cachedDoctors.first : allUsers.firstOrNull;
    _lastUserFetch = DateTime.now();
  }

  Future<void> _loadAppointmentsForDate(DateTime date) async {
    final cacheKey = _dateKey(date);
    if (_cache.containsKey(cacheKey)) {
      _appointments = _cache[cacheKey]!;
      _doctors = List.from(_cachedDoctors);
      _currentUser = _cachedCurrentUser;
      _datesWithAppointments = _computeDatesWithAppointments();
      return;
    }

    final fs = FirebaseFirestore.instance;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await fs
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(50)
        .get();

    final mapped = snap.docs.map((doc) {
      final d = doc.data();
      return DentistSchudelModel(
        id: doc.id,
        assignedDoctor: _doctorFromDoc(d['dentistId'] as String? ?? d['doctorId'] as String? ?? ''),
        patient: _patientFromDoc(d),
        atTimeInit: _parseDateTime(d['date'], d['startTime']),
        atTimeFinal: _parseDateTime(d['date'], d['endTime']),
        schudelCaption: d['reason'] ?? d['caption'] ?? 'Consulta',
        serviceType: d['serviceType'] ?? d['service'] ?? 'General',
        clinic: d['clinic'] ?? 'Medident',
        status: _parseStatus(d['status']),
        consultingRoom: d['consultingRoom'] as String?,
        cost: (d['cost'] as num?)?.toDouble() ?? 0,
        notes: d['notes'] as String?,
        isUrgent: d['isUrgent'] as bool? ?? false,
        requiresLab: d['requiresLab'] as bool? ?? false,
        requiredEquipment: (d['requiredEquipment'] as List?)?.cast<String>() ?? [],
      );
    }).toList();

    _cache[cacheKey] = mapped;
    _appointments = mapped;
    _doctors = List.from(_cachedDoctors);
    _currentUser = _cachedCurrentUser;
    _datesWithAppointments = _computeDatesWithAppointments();
  }

  Set<DateTime> _computeDatesWithAppointments() {
    if (_appointments.isEmpty) return {};
    return {_selectedDate};
  }

  UserSchudelModel _doctorFromDoc(String? uid) {
    if (uid == null) return _cachedDoctors.first;
    return _cachedDoctors.where((d) => d.uid == uid).firstOrNull ?? _cachedDoctors.first;
  }

  UserSchudelModel _patientFromDoc(Map<String, dynamic> d) {
    final name = d['patientName'] as String? ?? d['fullName'] as String? ?? 'Paciente';
    return UserSchudelModel(
      uid: d['patientId'] as String? ?? '',
      fullName: name,
      firstName: name.split(' ').first,
      avatarUrl: d['patientAvatar'] as String? ?? '',
      role: 'patient',
      specialty: '',
      avatarColor: Colors.primaries[name.hashCode % Colors.primaries.length],
    );
  }

  DateTime _parseDateTime(dynamic dateField, dynamic timeField) {
    if (dateField is Timestamp) {
      final ts = dateField.toDate();
      if (timeField is String && timeField.contains(':')) {
        final parts = timeField.split(':');
        return DateTime(ts.year, ts.month, ts.day,
            int.tryParse(parts[0]) ?? ts.hour,
            int.tryParse(parts[1]) ?? ts.minute);
      }
      return ts;
    }
    if (dateField is DateTime) {
      return dateField;
    }
    return DateTime.now();
  }

  AppointmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed': return AppointmentStatus.confirmed;
      case 'inProgress':
      case 'in_progress': return AppointmentStatus.inProgress;
      case 'completed': return AppointmentStatus.completed;
      case 'cancelled': return AppointmentStatus.cancelled;
      case 'noShow':
      case 'no_show': return AppointmentStatus.noShow;
      case 'rescheduled': return AppointmentStatus.rescheduled;
      default: return AppointmentStatus.newAppointment;
    }
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
    HapticFeedback.selectionClick();
    _loadAppointmentsForDate(date);
  }

  void _onAppointmentTap(DentistSchudelModel appt) {
    HapticFeedback.lightImpact();
    _showAppointmentDetail(appt);
  }

  void _onAddAppointment() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nueva cita →'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromARGB(255, 14, 174, 160),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (_currentUser == null) {
      return const Center(child: Text('No se encontraron usuarios'));
    }

    return SizedBox.expand(
      child: DentistSchudel_3_Widget(
        selectedDate: _selectedDate,
        appointments: _appointments,
        doctors: _doctors,
        currentUser: _currentUser!,
        datesWithAppointments: _datesWithAppointments,
        onDateChanged: _onDateChanged,
        onAppointmentTap: _onAppointmentTap,
        onAddAppointment: _onAddAppointment,
      ),
    );
  }

  void _showAppointmentDetail(DentistSchudelModel appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentDetailSheet(appointment: appt),
    );
  }
}

class _AppointmentDetailSheet extends StatelessWidget {
  final DentistSchudelModel appointment;

  const _AppointmentDetailSheet({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final status = appointment.status;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey900,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(status.icon, size: 12, color: status.color),
                    const SizedBox(width: 4),
                    Text(status.label,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: status.color)),
                  ],
                ),
              ),
              if (appointment.isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.grey900.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Urgente',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey900)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(appointment.patient.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppColors.grey900)),
          Text(appointment.schudelCaption,
              style: const TextStyle(fontSize: 16, color: AppColors.grey900)),
          const SizedBox(height: 20),
          _InfoRow(icon: Icons.access_time_rounded, label: 'Hora', value: appointment.timeRangeLabel),
          _InfoRow(icon: Icons.person_outline_rounded, label: 'Doctor', value: appointment.assignedDoctor.fullName),
          _InfoRow(icon: Icons.local_hospital_outlined, label: 'Servicio', value: appointment.serviceType),
          _InfoRow(icon: Icons.meeting_room_outlined, label: 'Consultorio', value: appointment.consultingRoom ?? '—'),
          _InfoRow(icon: Icons.attach_money_rounded, label: 'Valor', value: '\$${appointment.cost.toStringAsFixed(0)} COP'),
          if (appointment.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(appointment.notes!,
                  style: const TextStyle(fontSize: 14, color: AppColors.grey900)),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey900),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontSize: 14, color: AppColors.grey900)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.grey900),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
