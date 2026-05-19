import 'package:flutter/material.dart';
import 'theme.dart';

// ─────────────────────────────────────────
//  DaySelector Widget
//  Sección 1 del SchudelWidget
//  Card con esquinas redondeadas que envuelve
//  el selector de día de la semana
// ─────────────────────────────────────────

class DaySelector_Widget extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final Set<DateTime> datesWithAppointments;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onMonthTap;
  final VoidCallback? onFilterTap;
  final int notificationCount;

  const DaySelector_Widget({
    super.key,
    required this.selectedDate,
    required this.focusedMonth,
    required this.datesWithAppointments,
    required this.onDateSelected,
    this.onMonthTap,
    this.onFilterTap,
    this.notificationCount = 0,
  });

  @override
  State<DaySelector_Widget> createState() => _DaySelector_WidgetState();
}

class _DaySelector_WidgetState extends State<DaySelector_Widget> {
  // Retorna los 7 días de la semana que contiene [selectedDate]
  List<DateTime> _getWeekDays() {
    final selected = widget.selectedDate;
    // Lunes como primer día de semana
    final weekday = selected.weekday; // 1=Lun, 7=Dom
    final monday = selected.subtract(Duration(days: weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _hasAppointment(DateTime date) {
    return widget.datesWithAppointments
        .any((d) => _sameDay(d, date));
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();
    final monthName = _monthName(widget.focusedMonth.month);

    return Container(
      //width: double.infinity,
      height: 300,
      margin: const EdgeInsets.symmetric(
          horizontal: 8, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //////////////////////////////////////////////////// ── Header: Mes + controles ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                //////////////////////////////////////////////////// Título del mes
                Text(
                  '$monthName ${widget.focusedMonth.year}',
                  style: const TextStyle(
                    height: 1.35,
                    fontFamily: 'Ubuntu-Medium',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.11,
                    color: Color.fromARGB(255, 14, 14, 14),
                  ),
                ),
                const Spacer(),
                //////////////////////////////////////////////////// Botón de navegación mes
                GestureDetector(
                  onTap: widget.onMonthTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 249, 249, 249),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                    
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chevron_left_rounded,
                            size: 22, color: AppColors.gray1),
                        const Icon(Icons.chevron_right_rounded,
                            size: 22, color: AppColors.blue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                //////////////////////////////////////////////////// Botón notificaciones
                _NotifButton(count: widget.notificationCount),
                const SizedBox(width: 20),
                //////////////////////////////////////////////////// Botón filtro
                GestureDetector(
                  onTap: widget.onFilterTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.gray6,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: Color.fromARGB(255, 100, 100, 104),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //////////////////////////////////////////////////// ── Row de días ──
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays
                  .map((day) => _DayCell(
                        date: day,
                        isSelected: _sameDay(day, widget.selectedDate),
                        isToday: _sameDay(day, DateTime.now()),
                        hasAppointment: _hasAppointment(day),
                        onTap: () => widget.onDateSelected(day),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return names[month];
  }
}

// ── Celda individual de día ──
class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool hasAppointment;
  final VoidCallback? onTap;

  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.hasAppointment,
    this.onTap,
  });

  static const _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 56,
        padding: const EdgeInsets.only(left: 8,  top:12, right: 8, bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue : const Color.fromARGB(34, 181, 179, 179),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //////////////////////////////////////////////////////////////// Nombre del día
            Text(
              _dayNames[date.weekday - 1],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white.withOpacity(0.75)
                    : const Color.fromARGB(255, 146, 146, 149),
              ),
            ),
            const SizedBox(height: 2),
            // Número del día
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? AppColors.blue
                            : const Color.fromARGB(255, 63, 62, 62),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Punto indicador de citas
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasAppointment
                    ? (isSelected
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.blue)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Botón de notificaciones con badge ──
class _NotifButton extends StatelessWidget {
  final int count;

  const _NotifButton({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.gray6,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 18,
            color: AppColors.label,
          ),
        ),
        if (count > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: count > 9
                  ? null
                  : Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
