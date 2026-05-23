import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/providers/domain/appointment-provider.dart';
import 'package:medident/core/providers/domain/agenda-provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/services/agenda-service.dart';
import 'package:medident/screens/widgets/shared/create_appointment_sheet.dart';

class AgendaTab_Screen extends StatelessWidget {
  final String? clinicId;
  const AgendaTab_Screen({super.key, this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppointmentProvider, AgendaProvider>(
      builder: (context, aptProv, agendaProv, _) => _AgendaBody(
        appointments: aptProv.appointments,
        agendaProvider: agendaProv,
        clinicId: clinicId,
      ),
    );
  }
}

class _AgendaBody extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final AgendaProvider agendaProvider;
  final String? clinicId;

  const _AgendaBody({required this.appointments, required this.agendaProvider, this.clinicId});

  @override
  Widget build(BuildContext context) {
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: handle),
        SliverToBoxAdapter(child: _StatsBar(appointments: appointments)),
        SliverToBoxAdapter(
          child: _AgendaCalendar(
            focusedDay: agendaProvider.focusedDay,
            selectedDay: agendaProvider.selectedDay,
            dayStatuses: agendaProvider.dayStatuses,
            appointments: appointments,
            onDaySelected: (selected, focused) {
              agendaProvider.selectDay(selected);
              _showDaySheet(context, selected, appointments, agendaProvider);
            },
            onPageChanged: (focused) => agendaProvider.setFocusedDay(focused),
          ),
        ),
        SliverToBoxAdapter(child: _AppointmentsList(
          appointments: appointments,
          agendaProvider: agendaProvider,
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
  //─────────────────────────────────────────────── Show Sheet
  void _showDaySheet(BuildContext context, DateTime day,
      List<AppointmentModel> appointments, AgendaProvider agendaProv) {
    final dayStr = DateFormat('yyyy-MM-dd').format(day);
    final dayAppointments =
        appointments.where((a) => DateFormat('yyyy-MM-dd').format(a.date) == dayStr).toList();
    final dayKey = agendaProv.dayKey(day);
    final currentStatus = agendaProv.dayStatuses[dayKey] ?? DayStatus.normal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DaySheet(
        day: day,
        appointments: dayAppointments,
        currentStatus: currentStatus,
        agendaProv: agendaProv,
        clinicId: clinicId,
      ),
    );
  }
}

// ──────────────────────────────────────────────── Stats 
class _StatsBar extends StatelessWidget {
  final List<AppointmentModel> appointments;
  const _StatsBar({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = appointments.where((a) =>
        a.date.year == now.year && a.date.month == now.month && a.date.day == now.day).length;
    final week = appointments.where((a) =>
        a.date.isAfter(now.subtract(const Duration(days: 7)))).length;
    final pending = appointments.where((a) => a.status != 'confirmed').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        _StatCard(icon: Icons.today, value: '$today', label: 'Hoy', color: const Color(0xFF1E40AF)),
        const SizedBox(width: 12),
        _StatCard(icon: Icons.date_range, value: '$week', label: 'Semana', color: const Color(0xFF0F766E)),
        const SizedBox(width: 12),
        _StatCard(icon: Icons.pending_actions, value: '$pending', label: 'Pendientes', color: const Color(0xFFEA580C)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
        ]),
      ),
    );
  }
}

// ── Appointments Grouped List ──────────────────────────
class _AppointmentsList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final AgendaProvider agendaProvider;

  const _AppointmentsList({required this.appointments, required this.agendaProvider});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = appointments.where((a) =>
        a.date.isAfter(now.subtract(const Duration(days: 1)))).toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));

    if (upcoming.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No hay citas próximas', style: TextStyle(fontSize: 15, color: Colors.grey[500])),
        ]),
      );
    }

    final groupedByMonth = <String, List<AppointmentModel>>{};
    for (final a in upcoming) {
      final key = '${a.date.year}-${a.date.month.toString().padLeft(2, '0')}';
      groupedByMonth.putIfAbsent(key, () => []);
      groupedByMonth[key]!.add(a);
    }

    final monthNames = {
      1: 'Enero', 2: 'Febrero', 3: 'Marzo', 4: 'Abril',
      5: 'Mayo', 6: 'Junio', 7: 'Julio', 8: 'Agosto',
      9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre', 12: 'Diciembre',
    };

    final sortedKeys = groupedByMonth.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.list_alt_rounded, size: 18, color: Color(0xFF1E40AF)),
            const SizedBox(width: 8),
            Text('Próximas Citas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          ]),
          const SizedBox(height: 16),
          for (final monthKey in sortedKeys) ...[
            _MonthHeader(
              label: monthNames[int.parse(monthKey.split('-')[1])] ?? monthKey,
              count: groupedByMonth[monthKey]!.length,
            ),
            ..._buildDayGroups(groupedByMonth[monthKey]!),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDayGroups(List<AppointmentModel> monthAppts) {
    final groupedByDay = <int, List<AppointmentModel>>{};
    for (final a in monthAppts) {
      groupedByDay.putIfAbsent(a.date.day, () => []);
      groupedByDay[a.date.day]!.add(a);
    }

    final sortedDays = groupedByDay.keys.toList()..sort();
    final widgets = <Widget>[];

    for (final day in sortedDays) {
      final dayAppts = groupedByDay[day]!;
      final first = dayAppts.first.date;
      final weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
      final dayName = weekdays[first.weekday % 7];
      final isToday = first.day == DateTime.now().day &&
          first.month == DateTime.now().month &&
          first.year == DateTime.now().year;

      widgets.add(_DayHeader(
        day: day,
        dayName: dayName,
        isToday: isToday,
      ));

      for (final a in dayAppts) {
        widgets.add(_AppointmentCard(appointment: a));
      }
    }

    return widgets;
  }
}

class _MonthHeader extends StatelessWidget {
  final String label;
  final int count;
  const _MonthHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E40AF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.calendar_month, size: 16, color: Color(0xFF1E40AF)),
        ),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500])),
        ),
      ]),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final int day;
  final String dayName;
  final bool isToday;
  const _DayHeader({required this.day, required this.dayName, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF1E40AF) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('$day', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold,
              color: isToday ? Colors.white : Colors.grey[700],
            )),
          ),
        ),
        const SizedBox(width: 10),
        Text(dayName, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        if (isToday)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('HOY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF))),
          ),
      ]),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = appointment.status == 'confirmed';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => _showAppointmentDialog(context, appointment),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isConfirmed ? Colors.green.withOpacity(0.2) : Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isConfirmed ? Colors.green.withOpacity(0.08) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  Text(appointment.timeSlot.split(':').first,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isConfirmed ? Colors.green[700] : Colors.grey[600])),
                  const Text('min', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey[800])),
                    const SizedBox(height: 3),
                    Text('${appointment.treatmentName} · ${appointment.dentistName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConfirmed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isConfirmed ? 'Confirmada' : 'Pendiente',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: isConfirmed ? Colors.green[700] : Colors.orange[700]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Calendar ───────────────────────────────────────────
class _AgendaCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<String, DayStatus> dayStatuses;
  final List<AppointmentModel> appointments;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;

  const _AgendaCalendar({
    required this.focusedDay, required this.selectedDay,
    required this.dayStatuses, required this.appointments,
    required this.onDaySelected, required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        locale: 'es',
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: Color(0xFF1E40AF), shape: BoxShape.rectangle),
          markerDecoration: const BoxDecoration(color: Color(0xFF1E40AF), shape: BoxShape.circle),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, _) => _DayCell(
            day: day, month: focusedDay, appointments: appointments,
            dayStatuses: dayStatuses,
          ),
          todayBuilder: (context, day, _) => _DayCell(
            day: day, month: focusedDay, appointments: appointments,
            dayStatuses: dayStatuses, isToday: true,
          ),
          selectedBuilder: (context, day, _) => _DayCell(
            day: day, month: focusedDay, appointments: appointments,
            dayStatuses: dayStatuses, isSelected: true,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day, month;
  final List<AppointmentModel> appointments;
  final Map<String, DayStatus> dayStatuses;
  final bool isToday, isSelected;

  const _DayCell({
    required this.day, required this.month, required this.appointments,
    required this.dayStatuses, this.isToday = false, this.isSelected = false,
  });

  String _dayKey(DateTime d) => '${d.year}_${d.month}_${d.day}';

  bool get _isPast {
    final now = DateTime.now();
    return DateTime(day.year, day.month, day.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get _isOutside => day.month != month.month;

  /// Computes aggregate color from the day's appointments
  Color? get _apptStatusColor {
    final dayAppts = appointments.where((a) =>
        a.date.year == day.year && a.date.month == day.month && a.date.day == day.day);
    if (dayAppts.isEmpty) return null;

    bool hasPending = false;
    bool hasConfirmed = false;
    bool hasCompleted = false;

    for (final a in dayAppts) {
      switch (a.status) {
        case 'pending': hasPending = true;
        case 'confirmed': hasConfirmed = true;
        case 'completed': hasCompleted = true;
      }
    }

    if (hasPending) return const Color(0xFFD97706).withOpacity(0.15);
    if (hasConfirmed && !hasCompleted) return const Color(0xFF16A34A).withOpacity(0.12);
    if (hasCompleted && !hasConfirmed && !hasPending) return const Color(0xFF4F46E5).withOpacity(0.12);
    return const Color(0xFF16A34A).withOpacity(0.12);
  }

  @override
  Widget build(BuildContext context) {
    final apptCount = appointments.where((a) =>
        a.date.year == day.year && a.date.month == day.month && a.date.day == day.day).length;
    final status = dayStatuses[_dayKey(day)];
    final isPast = _isPast;
    final isOutside = _isOutside;
    final cellColor = _apptStatusColor;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1E40AF)
            : (isPast && !isToday
                ? Colors.grey[100]
                : (cellColor ?? (status?.bgColor ?? Colors.transparent))),
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: const Color(0xFF1E40AF), width: 2.5)
            : (isSelected ? Border.all(color: Colors.white, width: 2) : null),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${day.day}', style: TextStyle(
                fontSize: 15,
                fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isOutside || isPast ? Colors.grey[400] : Colors.black87),
              )),
              if (apptCount > 0 && !isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isPast ? Colors.grey[300] : const Color(0xFF1E40AF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('$apptCount', style: TextStyle(
                    fontSize: 9,
                    color: isPast ? Colors.grey[500] : Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
                ),
            ],
          ),
          if (status != null && !isSelected && !isPast)
            Positioned(top: 4, right: 4, child: Icon(status.icon, size: 10, color: status.color)),
        ],
      ),
    );
  }
}

// ── Day Bottom Sheet ───────────────────────────────────
class _DaySheet extends StatelessWidget {
  final DateTime day;
  final List<AppointmentModel> appointments;
  final DayStatus currentStatus;
  final AgendaProvider agendaProv;
  final String? clinicId;

  const _DaySheet({
    required this.day, required this.appointments,
    required this.currentStatus, required this.agendaProv,
    this.clinicId,
  });

  static const _startHour = 7;
  static const _endHour = 20;

  Set<String> get _occupiedSlots => appointments.map((a) => a.timeSlot.trim()).toSet();

  List<String> _generateSlots() {
    final slots = <String>[];
    for (var h = _startHour; h < _endHour; h++) {
      slots.add('${h.toString().padLeft(2, '0')}:00');
      slots.add('${h.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  void _createAppointment(BuildContext context, String slot) {
    final cid = clinicId ?? '';
    final user = context.read<AuthenticateProvider>().user;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateAppointment_Widget(
        initialDate: day,
        clinicId: cid,
        userId: user?.uid,
        userName: user?.fullName,
        userPhoto: user?.imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPast = DateTime(day.year, day.month, day.day)
        .isBefore(DateTime(now.year, now.month, now.day));
    final weekdays = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final dayName = weekdays[day.weekday % 7];
    final dateStr = DateFormat("d 'de' MMMM, yyyy", 'es').format(day);
    final slots = _generateSlots();
    final occupied = _occupiedSlots;

    final apptBySlot = <String, AppointmentModel>{};
    for (final a in appointments) {
      final key = a.timeSlot.trim();
      if (!apptBySlot.containsKey(key)) apptBySlot[key] = a;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(children: [
        Center(child: Container(
          margin: const EdgeInsets.only(top: 52),
          width: 40, height: 5,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        )),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayName, style: TextStyle(fontSize: 15, color: isPast ? Colors.grey[400] : Colors.grey)),
                Text(dateStr, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isPast ? Colors.grey[500] : Colors.black)),
              ],
            )),
            _StatusChip(status: currentStatus, onChanged: (s) => agendaProv.setDayStatus(day, s)),
          ]),
        ),
        const Divider(height: 30),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: slots.length,
            itemBuilder: (_, i) {
              final slot = slots[i];
              final isOccupied = occupied.contains(slot);
              final appt = apptBySlot[slot];
              final isHourStart = slot.endsWith(':00');
              return Column(
                children: [
                  if (isHourStart)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Row(children: [
                        Text(slot.split(':').first, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w600)),
                        const Expanded(child: Divider(thickness: 0.5)),
                      ]),
                    ),
                  _TimeSlotTile(
                    time: slot,
                    isOccupied: isOccupied,
                    appointment: appt,
                    isPast: isPast,
                    onConfirm: appt != null ? () => agendaProv.updateAppointmentStatus(appt.id, 'confirmed') : null,
                    onCancel: appt != null ? () => agendaProv.updateAppointmentStatus(appt.id, 'cancelled') : null,
                    onDelete: appt != null ? () => agendaProv.deleteAppointment(appt.id) : null,
                    onCreateAppointment: isPast ? null : () => _createAppointment(context, slot),
                  ),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _TimeSlotTile extends StatelessWidget {
  final String time;
  final bool isOccupied;
  final AppointmentModel? appointment;
  final bool isPast;
  final VoidCallback? onConfirm, onCancel, onDelete, onCreateAppointment;

  const _TimeSlotTile({
    required this.time, required this.isOccupied, this.appointment,
    this.isPast = false, this.onConfirm, this.onCancel, this.onDelete,
    this.onCreateAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = appointment?.status == 'confirmed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: GestureDetector(
        onTap: appointment != null
            ? () => _showAppointmentDialog(context, appointment!)
            : (!isPast ? onCreateAppointment : null),
        child: Container(
          decoration: BoxDecoration(
            color: isOccupied ? Colors.white : (isPast ? Colors.grey[50] : Colors.green.withOpacity(0.04)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isOccupied ? Colors.grey.shade200 : (isPast ? Colors.grey[200]! : Colors.green.withOpacity(0.15))),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Center(
                  child: Text(time, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: isOccupied ? Colors.grey[700] : (isPast ? Colors.grey[400] : Colors.green),
                  )),
                ),
              ),
              Container(width: 1, height: 36, color: Colors.grey[200]),
              const SizedBox(width: 12),
              Expanded(
                child: isOccupied && appointment != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(appointment!.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('${appointment!.treatmentName} · ${appointment!.dentistName}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(isPast ? Icons.block : Icons.check_circle, size: 16, color: isPast ? Colors.grey[400] : Colors.green[400]),
                          const SizedBox(width: 6),
                          Text(isPast ? 'No disponible' : 'Disponible', style: TextStyle(fontSize: 13, color: isPast ? Colors.grey[400] : Colors.green[600], fontWeight: FontWeight.w500)),
                        ],
                      ),
              ),
              if (isOccupied && appointment != null && !isPast)
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'confirm') onConfirm?.call();
                    else if (v == 'cancel') onCancel?.call();
                    else if (v == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (!isConfirmed)
                      const PopupMenuItem(value: 'confirm', child: ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Confirmar'))),
                    if (isConfirmed)
                      const PopupMenuItem(value: 'cancel', child: ListTile(leading: Icon(Icons.cancel, color: Colors.orange), title: Text('Cancelar'))),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Eliminar'))),
                  ],
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

void _showAppointmentDialog(BuildContext context, AppointmentModel appointment) {
  final agendaProv = Provider.of<AgendaProvider>(context, listen: false);
  final aptProv = Provider.of<AppointmentProvider>(context, listen: false);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AppointmentDetailSheet(
      appointment: appointment,
      agendaProv: agendaProv,
      aptProv: aptProv,
    ),
  );
}

// ── Appointment Detail Sheet ────────────────────────────
class _AppointmentDetailSheet extends StatefulWidget {
  final AppointmentModel appointment;
  final AgendaProvider agendaProv;
  final AppointmentProvider aptProv;

  const _AppointmentDetailSheet({
    required this.appointment,
    required this.agendaProv,
    required this.aptProv,
  });

  @override
  State<_AppointmentDetailSheet> createState() => _AppointmentDetailSheetState();
}

class _AppointmentDetailSheetState extends State<_AppointmentDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _detailsFade;
  late Animation<Offset> _detailsSlide;
  late Animation<double> _actionsFade;
  late Animation<Offset> _actionsSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();

    _headerFade = CurvedAnimation(
      parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)),
    );
    _detailsFade = CurvedAnimation(
      parent: _controller, curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
    );
    _detailsSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic)),
    );
    _actionsFade = CurvedAnimation(
      parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
    );
    _actionsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AppointmentModel get apt => widget.appointment;
  AgendaProvider get prov => widget.agendaProv;
  AppointmentProvider get aptProv => widget.aptProv;

  Color get _statusColor {
    switch (apt.status) {
      case 'confirmed': return const Color(0xFF16A34A);
      case 'cancelled': return const Color(0xFFDC2626);
      case 'completed': return const Color(0xFF4F46E5);
      default: return const Color(0xFFD97706);
    }
  }

  String get _statusLabel {
    switch (apt.status) {
      case 'confirmed': return 'Confirmada';
      case 'cancelled': return 'Cancelada';
      case 'completed': return 'Completada';
      default: return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Header ──
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: _buildHeader(),
            ),
          ),
          const SizedBox(height: 24),
          // ── Details Grid ──
          FadeTransition(
            opacity: _detailsFade,
            child: SlideTransition(
              position: _detailsSlide,
              child: _buildDetailsGrid(),
            ),
          ),
          const SizedBox(height: 28),
          // ── Actions Grid ──
          FadeTransition(
            opacity: _actionsFade,
            child: SlideTransition(
              position: _actionsSlide,
              child: _buildActionsGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final timeParts = apt.timeSlot.split(':');
    final hour = timeParts.isNotEmpty ? timeParts[0] : '--';

    return Row(
      children: [
        // Time badge
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _statusColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(hour,
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold,
                  color: _statusColor,
                ),
              ),
              Text('min',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(apt.patientName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('${apt.treatmentName} · ${apt.dentistName}',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
              _StatusBadge(
                label: _statusLabel,
                color: _statusColor,
              ),
            ],
          ),
        ),
        // Patient avatar
        CircleAvatar(
          radius: 26,
          backgroundColor: _statusColor.withOpacity(0.1),
          child: Text(
            apt.patientName.isNotEmpty ? apt.patientName[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,
              color: _statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    final details = <Map<String, dynamic>>[
      {'icon': Icons.calendar_today, 'label': 'Fecha', 'value': DateFormat("d 'de' MMMM, yyyy", 'es').format(apt.date)},
      {'icon': Icons.access_time, 'label': 'Horario', 'value': apt.timeSlot},
      {'icon': Icons.medical_services_outlined, 'label': 'Tratamiento', 'value': apt.treatmentName},
      {'icon': Icons.person, 'label': 'Doctor', 'value': apt.dentistName},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: details.map((d) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(d['icon'] as IconData, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(d['label'] as String,
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      Text(d['value'] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ),
          if (apt.notes != null && apt.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text('Notas: ', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  Expanded(
                    child: Text(apt.notes!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

  Widget _buildActionsGrid() {
    final isPending = apt.status == 'pending';
    final isConfirmed = apt.status == 'confirmed';
    final isCompleted = apt.status == 'completed';
    final isCancelled = apt.status == 'cancelled';

    final actions = <_ActionItem>[];

    if (isPending || isCancelled) {
      actions.add(_ActionItem(
        icon: Icons.check_circle,
        label: 'Confirmar',
        color: const Color(0xFF16A34A),
        onTap: () {
          Navigator.pop(context);
          aptProv.updateStatus(apt.id, 'confirmed');
        },
      ));
    }
    if (isConfirmed) {
      actions.add(_ActionItem(
        icon: Icons.cancel,
        label: 'Cancelar',
        color: const Color(0xFFEA580C),
        onTap: () {
          Navigator.pop(context);
          aptProv.updateStatus(apt.id, 'cancelled');
        },
      ));
    }
    if (isConfirmed || isPending) {
      actions.add(_ActionItem(
        icon: Icons.task_alt,
        label: 'Completada',
        color: const Color(0xFF4F46E5),
        onTap: () {
          Navigator.pop(context);
          aptProv.updateStatus(apt.id, 'completed');
        },
      ));
    }
    actions.add(_ActionItem(
      icon: Icons.date_range,
      label: 'Reagendar',
      color: const Color(0xFF2563EB),
      onTap: () => _rescheduleAppointment(context),
    ));
    actions.add(_ActionItem(
      icon: Icons.edit_note,
      label: 'Editar Notas',
      color: const Color(0xFFD97706),
      onTap: () => _editNotes(context),
    ));
    if (apt.status != 'cancelled') {
      actions.add(_ActionItem(
        icon: Icons.notifications_active,
        label: 'Recordatorio',
        color: const Color(0xFF0891B2),
        onTap: () => _sendReminder(context),
      ));
    }
    if (!isCompleted && !isCancelled) {
      actions.add(_ActionItem(
        icon: Icons.delete,
        label: 'Eliminar',
        color: const Color(0xFFDC2626),
        onTap: () => _confirmDelete(context),
      ));
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: List.generate(actions.length, (i) {
        final a = actions[i];
        final delay = 0.05 * i;
        final anim = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (0.4 + delay).clamp(0.0, 0.9),
            (0.55 + delay).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        );
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(anim),
            child: _ActionCard(item: a),
          ),
        );
      }),
    );
  }

  Future<void> _rescheduleAppointment(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: apt.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(apt.date),
    );
    if (time == null || !mounted) return;

    final newSlot = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    Navigator.pop(context);
    await prov.updateAppointment(apt.id, {
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day, time.hour, time.minute)),
      'timeSlot': newSlot,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cita reagendada correctamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2563EB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _editNotes(BuildContext context) async {
    final controller = TextEditingController(text: apt.notes ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Editar Notas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe notas adicionales...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, controller.text),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context);
      await prov.updateAppointment(apt.id, {'notes': result});
    }
  }

  Future<void> _sendReminder(BuildContext context) async {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recordatorio enviado al paciente'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0891B2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    Navigator.pop(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar cita'),
        content: const Text('¿Estás seguro de eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await aptProv.deleteAppointment(apt.id);
    }
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 20, color: item.color),
            const SizedBox(width: 8),
            Text(item.label,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: item.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DayStatus status;
  final ValueChanged<DayStatus> onChanged;

  const _StatusChip({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DayStatus>(
      onSelected: onChanged,
      itemBuilder: (_) => DayStatus.values.map((s) => PopupMenuItem(
        value: s,
        child: Text(s.label),
      )).toList(),
      child: Chip(
        avatar: Icon(status.icon, size: 18, color: status.color),
        label: Text(status.label, style: TextStyle(fontSize: 13, color: status.color)),
        backgroundColor: status.color.withOpacity(0.1),
      ),
    );
  }
}

