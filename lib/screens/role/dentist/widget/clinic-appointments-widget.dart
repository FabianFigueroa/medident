import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medident/core/models/appointment-model.dart';

class ClinicAppointmentsWidget extends StatefulWidget {
  final List<AppointmentModel> appointments;
  final Function(AppointmentModel)? onTap;
  final Function(AppointmentModel)? onStatusChange;

  const ClinicAppointmentsWidget({
    super.key,
    required this.appointments,
    this.onTap,
    this.onStatusChange,
  });

  @override
  State<ClinicAppointmentsWidget> createState() => _ClinicAppointmentsWidgetState();
}

class _ClinicAppointmentsWidgetState extends State<ClinicAppointmentsWidget> {
  String _selectedFilter = 'all'; // 'all', 'today', 'upcoming', 'pending'

  List<AppointmentModel> get _filteredAppointments {
    switch (_selectedFilter) {
      case 'today':
        return widget.appointments.where((a) => a.isToday).toList();
      case 'upcoming':
        return widget.appointments.where((a) => a.isUpcoming).toList();
      case 'pending':
        return widget.appointments.where((a) => a.status == 'pending').toList();
      default:
        return widget.appointments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAppointments;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Gestión de Citas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${filtered.length} citas',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todas', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hoy', 'today'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Próximas', 'upcoming'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendientes', 'pending'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lista de citas
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 40,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay citas con este filtro',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtered.take(5).map((apt) => _buildAppointmentCard(context, apt)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF0F766E).withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0F766E) : Colors.grey[700],
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentModel apt) {
    return InkWell(
      onTap: widget.onTap != null ? () => widget.onTap!(apt) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Icono según estado
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getStatusColor(apt.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getStatusIcon(apt.status),
                color: _getStatusColor(apt.status),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.patientName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          apt.treatmentName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('HH:mm').format(apt.date)} - ${apt.timeSlot}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Menú de acciones
            PopupMenuButton<String>(
              onSelected: (value) {
                if (widget.onStatusChange != null) {
                  widget.onStatusChange!(apt);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'confirmed',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16),
                      SizedBox(width: 8),
                      Text('Confirmar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'completed',
                  child: Row(
                    children: [
                      Icon(Icons.task_alt, color: Color(0xFF1D4ED8), size: 16),
                      SizedBox(width: 8),
                      Text('Completar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancelled',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Color(0xFFEF4444), size: 16),
                      SizedBox(width: 8),
                      Text('Cancelar'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(apt.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusLabel(apt.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(apt.status),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF22C55E);
      case 'pending':
        return const Color(0xFFEA580C);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF1D4ED8);
      default:
        return const Color(0xFF475569);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.pending_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.task_alt;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmada';
      case 'pending':
        return 'Pendiente';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Completada';
      default:
        return status;
    }
  }
}
