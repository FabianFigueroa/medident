import 'package:flutter/material.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-panel-shell.dart';

class DentistDates_Widget extends StatelessWidget {
  final List<AppointmentModel> appointments;

  const DentistDates_Widget({required this.appointments});

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
                    ////////////////////////////////////////////////////////
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: appointment.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            appointment.time,
                            style: TextStyle(
                              color: appointment.color,
                              fontFamily: 'Ubuntu-Bold',
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            appointment.duration,
                            style: const TextStyle(
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
                            appointment.patient,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Ubuntu-Bold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appointment.procedure,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              fontFamily: 'Ubuntu-Regular',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appointment.room,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF0F766E),
                              fontFamily: 'Ubuntu-Medium',
                            ),
                          ),
                        ],
                      ),
                    ),
                    ///
                    ////////////////////////////////////////////////////
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: appointment.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        appointment.status,
                        style: TextStyle(
                          color: appointment.color,
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


class AppointmentModel {
  final String time;
  final String duration;
  final String patient;
  final String procedure;
  final String room;
  final String status;
  final Color color;

  const AppointmentModel({
    required this.time,
    required this.duration,
    required this.patient,
    required this.procedure,
    required this.room,
    required this.status,
    required this.color,
  });
}


const List<AppointmentModel> mockAppointmentsList = [
  AppointmentModel(
    time: '08:30',
    duration: '45 min',
    patient: 'Daniela Ruiz',
    procedure: 'Valoracion integral y plan cosmetico',
    room: 'Consultorio 2',
    status: 'Confirmada',
    color: Color(0xFF0F766E),
  ),
  AppointmentModel(
    time: '10:15',
    duration: '60 min',
    patient: 'Carlos Medina',
    procedure: 'Ajuste de ortodoncia con control fotografico',
    room: 'Sala digital',
    status: 'En espera',
    color: Color(0xFFEA580C),
  ),
  AppointmentModel(
    time: '12:00',
    duration: '30 min',
    patient: 'Laura Camelo',
    procedure: 'Seguimiento post operatorio',
    room: 'Consultorio 1',
    status: 'Rapida',
    color: Color(0xFF1D4ED8),
  ),
];
