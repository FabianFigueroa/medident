import 'package:flutter/material.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-schudel-model.dart';
import 'theme.dart';

// ─────────────────────────────────────────
//  AppointmentCard Widget
//  Tarjeta de cita dentro del timeline
//  La altura varía según la duración real
//  30 min = 68px (slotHeight)
// ─────────────────────────────────────────

const double kSlotHeight = 68.0; // altura de 30 minutos

class AppointmentCard extends StatelessWidget {
  final DentistSchudelModel appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  // Altura calculada según duración
  double get height => (appointment.durationMinutes / 30.0) * kSlotHeight;

  @override
  Widget build(BuildContext context) {
    final status = appointment.status;
    final isShort = appointment.durationMinutes <= 30;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height - 4, // 4px de gap entre tarjetas
        decoration: BoxDecoration(
          color: status.backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: status.color.withOpacity(0.25),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(7),
        child: isShort
            ? _ShortLayout(appointment: appointment)
            : _TallLayout(appointment: appointment),
      ),
    );
  }
}

// ── Layout para citas cortas (≤30min) ──
class _ShortLayout extends StatelessWidget {
  final DentistSchudelModel appointment;

  const _ShortLayout({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final status = appointment.status;
    return Row(
      children: [
        // Dot de estado
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 1, right: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: status.color,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                appointment.patient.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label,
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                appointment.schudelCaption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.gray1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Layout para citas largas (>30min) ──
class _TallLayout extends StatelessWidget {
  final DentistSchudelModel appointment;

  const _TallLayout({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final status = appointment.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila de estado
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status.color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              status.label.toUpperCase(),
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: status.color,
              ),
            ),
            if (appointment.isUrgent) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 3),

        // Nombre del paciente
        Text(
          appointment.patient.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColors.label,
          ),
        ),

        // Servicio
        Text(
          appointment.schudelCaption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 8,
            color: AppColors.gray1,
          ),
        ),

        const Spacer(),

        // Hora
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 8,
              color: AppColors.gray2,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                appointment.timeRangeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 7.5,
                  color: AppColors.gray2,
                ),
              ),
            ),
          ],
        ),

        // Lab indicator (si requiere laboratorio)
        if (appointment.requiresLab) ...[
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.indigo.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Lab',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w600,
                color: AppColors.indigo,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
