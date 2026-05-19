import 'package:flutter/material.dart';
import 'package:medident/core/models/appointment-model.dart';

const double _slotH = 52.0;
const int _startHour = 7;
const int _endHour = 19;

class CalendarTable extends StatelessWidget {
  final DateTime date;
  final List<AppointmentModel> appointments;
  final void Function(AppointmentModel)? onTap;

  const CalendarTable({
    super.key,
    required this.date,
    required this.appointments,
    this.onTap,
  });

  int get _totalSlots => (_endHour - _startHour) * 2;
  double get _totalHeight => _totalSlots * _slotH;

  double _topOffset(String timeSlot) {
    final parts = timeSlot.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? _startHour;
    final m = int.tryParse(parts[1]) ?? 0;
    final totalMinutes = (h - _startHour) * 60 + m;
    return (totalMinutes / 30.0) * _slotH;
  }

  @override
  Widget build(BuildContext context) {
    final dayAppts = appointments;
    if (dayAppts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(children: [
          Icon(Icons.event_busy, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text('Sin citas para este día', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ]),
      );
    }

    final doctors = <String, String>{};
    for (final a in dayAppts) {
      doctors[a.dentistId] = a.dentistName.isNotEmpty ? a.dentistName : a.dentistId;
    }
    final doctorEntries = doctors.entries.toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final doctorWidth = ((screenWidth - 56) / doctorEntries.length).clamp(140.0, 240.0);

    final sorted = List<AppointmentModel>.from(dayAppts)
      ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.calendar_view_day, size: 20, color: const Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Text('CalendarTable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[800])),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: Text('${dayAppts.length} cita${dayAppts.length == 1 ? '' : 's'} · ${doctorEntries.length} doctor${doctorEntries.length == 1 ? '' : 'es'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: SizedBox(
              height: _totalHeight + 4,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 4),
                child: SizedBox(
                  width: 44 + doctorEntries.length * doctorWidth,
                  height: _totalHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimeAxis(slotHeight: _slotH, startHour: _startHour, totalSlots: _totalSlots),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Stack(
                          children: [
                            _GridLines(slotHeight: _slotH, totalSlots: _totalSlots, startHour: _startHour),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: doctorEntries.map((entry) {
                                final doctorAppts = sorted.where((a) => a.dentistId == entry.key).toList();
                                return SizedBox(
                                  width: doctorWidth,
                                  child: Column(
                                    children: [
                                      _DoctorHeader(name: entry.value, color: _doctorColor(entry.key)),
                                      Expanded(
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: doctorAppts.map((a) {
                                            final top = _topOffset(a.timeSlot);
                                            return Positioned(
                                              top: top,
                                              left: 2,
                                              right: 2,
                                              height: _slotH - 4,
                                              child: GestureDetector(
                                                onTap: () => onTap?.call(a),
                                                child: _AppointmentCard(appointment: a),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _doctorColor(String id) {
    final colors = [
      const Color(0xFF2563EB), const Color(0xFF0D9488), const Color(0xFF7C3AED),
      const Color(0xFFDB2777), const Color(0xFF4F46E5), const Color(0xFF0891B2),
      const Color(0xFFD97706),
    ];
    return colors[id.hashCode % colors.length];
  }
}

class _DoctorHeader extends StatelessWidget {
  final String name;
  final Color color;
  const _DoctorHeader({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final short = name.split(' ');
    final display = short.length >= 2 ? '${short[0]} ${short[1][0]}.' : name;
    return Container(
      height: 30,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(display, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  Color get _color {
    switch (appointment.status) {
      case 'confirmed': return const Color(0xFF16A34A);
      case 'cancelled': return const Color(0xFFDC2626);
      case 'completed': return const Color(0xFF4F46E5);
      default: return const Color(0xFFD97706);
    }
  }

  String get _statusLabel {
    switch (appointment.status) {
      case 'confirmed': return 'Confirmada';
      case 'cancelled': return 'Cancelada';
      case 'completed': return 'Completada';
      default: return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 6, 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: _color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(a.timeSlot,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _color, letterSpacing: 0.3)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(_statusLabel,
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: _color, height: 1.2)),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(a.patientName,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 1),
          Text(
            '${a.treatmentName} · ${a.dentistName.isNotEmpty ? a.dentistName.split(' ').first : 'N/A'}',
            style: TextStyle(fontSize: 8, color: Colors.grey[500], height: 1.2),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _TimeAxis extends StatelessWidget {
  final double slotHeight;
  final int startHour;
  final int totalSlots;
  const _TimeAxis({required this.slotHeight, required this.startHour, required this.totalSlots});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        children: List.generate(totalSlots, (i) {
          final h = startHour + i ~/ 2;
          final m = i % 2 == 0 ? '00' : '30';
          final isHour = i % 2 == 0;
          return SizedBox(
            height: slotHeight,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${h.toString().padLeft(2, '0')}:$m',
                  style: TextStyle(
                    fontSize: isHour ? 10 : 8,
                    fontWeight: isHour ? FontWeight.w600 : FontWeight.normal,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GridLines extends StatelessWidget {
  final double slotHeight;
  final int totalSlots;
  final int startHour;
  const _GridLines({required this.slotHeight, required this.totalSlots, required this.startHour});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(totalSlots, (i) {
        final isHour = i % 2 == 0;
        return Container(
          height: slotHeight,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isHour ? Colors.grey[300]! : Colors.grey[100]!,
                width: isHour ? 0.5 : 0.3,
              ),
            ),
          ),
        );
      }),
    );
  }
}
