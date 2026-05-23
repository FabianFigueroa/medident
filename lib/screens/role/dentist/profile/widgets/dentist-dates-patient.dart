import 'package:flutter/material.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-panel-shell.dart';

class DentistDates_Widget extends StatelessWidget {
  final List<AppointmentModel> appointments;

  const DentistDates_Widget({super.key, required this.appointments});

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF0F766E);
      case 'pending':
        return const Color(0xFFEA580C);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DentistPanelShell(
      title: 'Agenda prioritaria',
      subtitle: 'Turnos destacados del dia con seguimiento rapido.',
      child: Column(
        children: appointments
            .map(
              (appointment) => Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _statusColor(appointment.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            appointment.timeSlot,
                            style: TextStyle(
                              color: _statusColor(appointment.status),
                              fontFamily: 'Ubuntu-Bold',
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            '—',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontFamily: 'Ubuntu-Regular',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patientName,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Ubuntu-Bold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appointment.treatmentName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              fontFamily: 'Ubuntu-Regular',
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Consultorio',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF0F766E),
                              fontFamily: 'Ubuntu-Medium',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(appointment.status).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        appointment.status,
                        style: TextStyle(
                          color: _statusColor(appointment.status),
                          fontSize: 11,
                          fontFamily: 'Ubuntu-Bold',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
