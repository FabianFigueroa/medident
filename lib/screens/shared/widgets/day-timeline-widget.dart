import 'package:flutter/material.dart';
import 'package:medident/core/models/appointment-model.dart';

const double _slotH = 52.0;
const int _startHour = 8;
const int _endHour = 18;

class DayTimelineWidget extends StatelessWidget {
  final DateTime date;
  final List<AppointmentModel> appointments;
  final void Function(AppointmentModel)? onTap;

  const DayTimelineWidget({
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
    if (appointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 40, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text('Sin citas para este día', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final sorted = List<AppointmentModel>.from(appointments)
      ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 18, color: const Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Text('Horario del día', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                const Spacer(),
                Text('${appointments.length} cita${appointments.length == 1 ? '' : 's'}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: SizedBox(
              height: 300,
              child: SingleChildScrollView(
                child: SizedBox(
                  height: _totalHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 42,
                        child: Column(
                          children: List.generate(_totalSlots, (i) {
                            final h = _startHour + i ~/ 2;
                            final m = i % 2 == 0 ? '00' : '30';
                            return SizedBox(
                              height: _slotH,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 1, left: 4),
                                  child: Text(
                                    '${h.toString().padLeft(2, '0')}:$m',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Column(
                              children: List.generate(_totalSlots, (i) =>
                                Container(
                                  height: _slotH,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: i % 2 == 0 ? Colors.grey[200]! : Colors.grey[100]!,
                                        width: i % 2 == 0 ? 0.5 : 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...sorted.map((a) => Positioned(
                              top: _topOffset(a.timeSlot),
                              left: 4,
                              right: 4,
                              height: 48,
                              child: GestureDetector(
                                onTap: () => onTap?.call(a),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(a.status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: _statusColor(a.status).withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _statusColor(a.status),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              a.patientName,
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              a.treatmentName,
                                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(a.timeSlot, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _statusColor(a.status))),
                                    ],
                                  ),
                                ),
                              ),
                            )),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return const Color(0xFF4F46E5);
      default: return Colors.orange;
    }
  }
}
