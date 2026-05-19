import 'package:flutter/material.dart';
import 'package:medident/screens/role/dentist/profile/widgets/appoiments-card-widget.dart';
import 'package:medident/screens/role/dentist/profile/widgets/day-selector-widget.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-schudel-model.dart';
import 'package:medident/screens/role/dentist/profile/widgets/profile-avatar-widget.dart';
import 'theme.dart';

// ─────────────────────────────────────────
//  DentistSchudelWidget (Widget principal)
//  Las 3 secciones completas de la pantalla
//
//  Sección 1: DaySelector (card con esquinas
//             redondeadas, selector de día)
//  Sección 2: ProfileAvatarStories (anillos
//             estilo Facebook Stories)
//  Sección 3: Timeline multi-columna con
//             altura variable por duración
// ─────────────────────────────────────────
const double _slotH = 68.0;

/// Altura de un slot de 30 minutos en el timeline
const int _timelineStartHour = 8;

/// Hora de inicio del timeline (8:00 AM)
const int _timelineEndHour = 18;

/// Hora de fin del timeline (18:00 PM)

class DentistSchudel_3_Widget extends StatefulWidget {
  final DateTime selectedDate;
  final List<DentistSchudelModel> appointments;
  final List<UserSchudelModel> doctors;
  final UserSchudelModel currentUser;
  final Set<DateTime> datesWithAppointments;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<DentistSchudelModel>? onAppointmentTap;
  final ValueChanged<UserSchudelModel>? onDoctorTap;
  final VoidCallback? onAddAppointment;

  const DentistSchudel_3_Widget({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.doctors,
    required this.currentUser,
    required this.datesWithAppointments,
    this.onDateChanged,
    this.onAppointmentTap,
    this.onDoctorTap,
    this.onAddAppointment,
  });

  @override
  State<DentistSchudel_3_Widget> createState() =>
      _DentistSchudel_3_WidgetState();
}

class _DentistSchudel_3_WidgetState extends State<DentistSchudel_3_Widget> {
  final ScrollController _timelineScrollController = ScrollController();
  int get _totalSlots =>
      (_timelineEndHour - _timelineStartHour) *
      2; // Número total de slots en el timeline
  double get _totalTimelineHeight =>
      _totalSlots * _slotH; // Altura total del timeline

  // Columnas de doctores que aparecen en el día seleccionado
  List<UserSchudelModel> get _activeDoctors {
    final uids = widget.appointments.map((a) => a.assignedDoctor.uid).toSet();
    return widget.doctors.where((d) => uids.contains(d.uid)).toList();
  }

  // Citas de un doctor específico
  List<DentistSchudelModel> _appointmentsFor(UserSchudelModel doctor) {
    return widget.appointments
        .where((a) => a.assignedDoctor.uid == doctor.uid)
        .toList()
      ..sort((a, b) => a.atTimeInit.compareTo(b.atTimeInit));
  }

  // Desplazamiento vertical en píxeles de una hora + minuto
  double _topOffsetFor(DateTime time) {
    final totalMinutes = (time.hour - _timelineStartHour) * 60 + time.minute;
    return (totalMinutes / 30.0) * _slotH;
  }

  // Etiquetas de hora para el eje izquierdo
  List<String> get _timeLabels {
    final labels = <String>[];
    for (int h = _timelineStartHour; h < _timelineEndHour; h++) {
      labels.add('${h.toString().padLeft(2, '0')}:00');
      labels.add('${h.toString().padLeft(2, '0')}:30');
    }
    return labels;
  }

  @override
  void initState() {
    super.initState();
    // Auto-scroll al inicio de la jornada (8:00)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = (1 * 2) * _slotH; // 1 hora después del inicio
      if (_timelineScrollController.hasClients) {
        _timelineScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ////////////////////////////////////////////////// SECCIÓN 1: Day Selector
        // DaySelector_Widget(
        //   selectedDate: widget.selectedDate,
        //   focusedMonth: widget.selectedDate,
        //   datesWithAppointments: widget.datesWithAppointments,
        //   onDateSelected: (date) => widget.onDateChanged?.call(date),
        //   notificationCount: 3,
        // ),

        // const SizedBox(height: 4),

        ////////////////////////////////////////////////// SECCIÓN 2: Doctor Stories
        // ProfileAvatarStories(
        //   doctors: widget.doctors,
        //   currentUser: widget.currentUser,
        //   onDoctorTap: widget.onDoctorTap,
        // ),

        //////////////////////////////////////////////////// Línea divisoria estilo iOS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: const Color.fromARGB(72, 244, 136, 87).withOpacity(0.3),
          ),
        ),

        //////////////////////////////////////////////////// SECCIÓN 3: Timeline multi-columna
        Expanded(child: _buildTimeline()),
      ],
    );
  }

  Widget _buildTimeline() {
    final now = DateTime.now();
    final nowOffset = _topOffsetFor(now);
    final showNowLine =
        now.hour >= _timelineStartHour && now.hour < _timelineEndHour;

    return SingleChildScrollView(
      controller: _timelineScrollController,
      padding: const EdgeInsets.only(left: 8, right: 10, top: 8, bottom: 24),
      child: SizedBox(
        height: _totalTimelineHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Eje de tiempo (izquierda) ──
            _TimeAxis(labels: _timeLabels, slotHeight: _slotH),

            // ── Columnas de doctores ──
            Expanded(
              child: Stack(
                children: [
                  // Líneas horizontales de la grilla
                  _GridLines(totalSlots: _totalSlots, slotHeight: _slotH),

                  // Columnas de citas
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _activeDoctors
                        .map(
                          (doctor) => Expanded(
                            child: _DoctorColumn(
                              doctor: doctor,
                              appointments: _appointmentsFor(doctor),
                              totalHeight: _totalTimelineHeight,
                              topOffsetFor: _topOffsetFor,
                              onAppointmentTap: widget.onAppointmentTap,
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // Línea "AHORA"
                  if (showNowLine) _NowLine(topOffset: nowOffset, now: now),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////// Eje de horas izquierdo
class _TimeAxis extends StatelessWidget {
  final List<String> labels;
  final double slotHeight;
  const _TimeAxis({required this.labels, required this.slotHeight});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Column(
        children: labels
            .map(
              (label) => SizedBox(
                height: slotHeight,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 25, 25, 34),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////// ── Líneas horizontales de la grilla
class _GridLines extends StatelessWidget {
  final int totalSlots;
  final double slotHeight;

  const _GridLines({required this.totalSlots, required this.slotHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        totalSlots,
        (i) => Container(
          height: slotHeight,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: i % 2 == 0
                    ? AppColors.gray4.withOpacity(0.6)
                    : AppColors.gray5.withOpacity(0.4),
                width: i % 2 == 0 ? 0.5 : 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////// ── Columna de un doctor con citas
class _DoctorColumn extends StatelessWidget {
  final UserSchudelModel doctor;
  final List<DentistSchudelModel> appointments;
  final double totalHeight;
  final double Function(DateTime) topOffsetFor;
  final ValueChanged<DentistSchudelModel>? onAppointmentTap;

  const _DoctorColumn({
    required this.doctor,
    required this.appointments,
    required this.totalHeight,
    required this.topOffsetFor,
    this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: appointments
              .map(
                (appt) => Positioned(
                  top: topOffsetFor(appt.atTimeInit),
                  left: 0,
                  right: 0,
                  // La altura se calcula en AppointmentCard
                  // pero también la podemos forzar aquí:
                  height: (appt.durationMinutes / 30.0) * kSlotHeight - 4,
                  child: AppointmentCard(
                    appointment: appt,
                    onTap: () => onAppointmentTap?.call(appt),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////// ── Línea "Ahora" roja
class _NowLine extends StatelessWidget {
  final double topOffset;
  final DateTime now;

  const _NowLine({required this.topOffset, required this.now});

  String get _timeLabel {
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Línea horizontal
          Container(height: 1.5, color: AppColors.red),
          // Badge de hora (a la izquierda)
          Positioned(
            left: -2,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                _timeLabel,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Círculo rojo a la izquierda de la línea
          Positioned(
            left: -3,
            top: -3,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
