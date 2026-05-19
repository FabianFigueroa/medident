import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:medident/main_export.dart';

class TurnosOneWidget extends StatefulWidget {
  final Function(TurnoModel)? onTap;
  final Function(String, String)? onStatusChange;

  const TurnosOneWidget({
    super.key,
    this.onTap,
    this.onStatusChange,
  });

  @override
  State<TurnosOneWidget> createState() => _TurnosOneWidgetState();
}

class _TurnosOneWidgetState extends State<TurnosOneWidget> {
  final Set<String> _notifyingTurnos = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<DentistHomeProvider>(
      builder: (context, provider, _) {
        final turnos = provider.turnos;
        final isLoading = provider.isLoading;

        if (isLoading && turnos.isEmpty) {
          return _buildLoadingState();
        }

        if (turnos.isEmpty) {
          return _buildEmptyState();
        }

        final todayTurnos = turnos.where((t) => t.isToday).toList();
        final upcomingTurnos =
            turnos.where((t) => !t.isToday).toList();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header moderno
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Turnos Empleados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Ubuntu-Bold',
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${turnos.length} turnos',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Ubuntu-Medium',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Turnos de hoy
                if (todayTurnos.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Hoy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontFamily: 'Ubuntu-Medium',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...todayTurnos
                      .take(2)
                      .map((t) => _buildTurnoItem(context, t)),
                  if (todayTurnos.length > 2) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '+ ${todayTurnos.length - 2} turnos más hoy',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Ubuntu-Regular',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],

                // Próximos turnos
                if (upcomingTurnos.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.upcoming, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Próximos',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontFamily: 'Ubuntu-Medium',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...upcomingTurnos
                      .take(2)
                      .map((t) => _buildTurnoItem(context, t)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTurnoItem(BuildContext context, TurnoModel turno) {
    final isNotifying = _notifyingTurnos.contains(turno.id);
    final statusColor = _getStatusColor(turno.status);

    return InkWell(
      onTap: () => widget.onTap?.call(turno),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Ícono según estado
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getStatusIcon(turno.status),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    turno.employeeName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Ubuntu-Medium',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${turno.startTime} - ${turno.endTime}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontFamily: 'Ubuntu-Regular',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Notificar y cambiar estado
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isNotifying ? null : () => _notifyTurno(turno),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isNotifying
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.notifications_outlined, size: 16),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showStatusDialog(context, turno),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusLabel(turno.status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                        fontFamily: 'Ubuntu-Medium',
                      ),
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

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedTask01,
            size: 60,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay turnos programados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Ubuntu-Medium',
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return const Color(0xFFEA580C);
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'scheduled':
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return Icons.pending_outlined;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'scheduled':
      default:
        return Icons.schedule_outlined;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return 'En progreso';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      case 'scheduled':
      default:
        return 'Programado';
    }
  }

  Future<void> _notifyTurno(TurnoModel turno) async {
    if (!mounted) return;
    setState(() => _notifyingTurnos.add(turno.id));
    try {
      // Simular notificación (en producción usar Firebase Messaging)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notificación enviada a ${turno.employeeName}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _notifyingTurnos.remove(turno.id));
    }
  }

  Future<void> _showStatusDialog(
      BuildContext context, TurnoModel turno) async {
    final statuses = ['scheduled', 'in-progress', 'completed', 'cancelled'];
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Cambiar estado',
          style: TextStyle(fontFamily: 'Ubuntu-Bold'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((s) {
            final color = _getStatusColor(s);
            return ListTile(
              leading: Icon(_getStatusIcon(s), color: color, size: 18),
              title: Text(_getStatusLabel(s)),
              onTap: () => Navigator.pop(context, s),
            );
          }).toList(),
        ),
      ),
    );
    if (result != null) {
      widget.onStatusChange?.call(turno.id, result);
    }
  }
}
