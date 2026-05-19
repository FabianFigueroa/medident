import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Visits_One_Widget extends StatefulWidget {
  final List<dynamic> visits;
  final Function(dynamic)? onTap;
  final Function(String, String)? onStatusChange; // visitId, newStatus
  final bool isLoading;

  const Visits_One_Widget({
    super.key,
    required this.visits,
    this.onTap,
    this.onStatusChange,
    this.isLoading = false,
  });

  @override
  State<Visits_One_Widget> createState() => _Visits_One_WidgetState();
}

class _Visits_One_WidgetState extends State<Visits_One_Widget> {
  final Set<String> _processingIds = {};

  String _formatDate(dynamic date) {
    if (date == null || date == '') return '';
    if (date is String) return date;
    if (date is Timestamp) {
      return DateFormat('dd/MM/yy HH:mm').format(date.toDate());
    }
    return date.toString();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF22C55E);
      case 'in-progress':
        return const Color(0xFFEA580C);
      case 'scheduled':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completada';
      case 'in-progress':
        return 'En progreso';
      case 'scheduled':
        return 'Programada';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.task_alt;
      case 'in-progress':
        return Icons.pending_outlined;
      case 'scheduled':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _handleCheckInOut(dynamic visit) async {
    final visitId = visit['id'] ?? '';
    if (visitId.isEmpty || widget.onStatusChange == null) return;

    final currentStatus = visit['status'] ?? 'scheduled';
    String newStatus;
    if (currentStatus == 'scheduled') {
      newStatus = 'in-progress';
    } else if (currentStatus == 'in-progress') {
      newStatus = 'completed';
    } else {
      return; // Already completed
    }

    setState(() => _processingIds.add(visitId));
    try {
      widget.onStatusChange?.call(visitId, newStatus);
      final msg = newStatus == 'in-progress' ? 'Check-in realizado' : 'Check-out realizado';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(visitId));
    }
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.history_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No hay visitas clínicas',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visits.isEmpty && !widget.isLoading) {
      return _buildEmpty();
    }

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
            // Header (tu diseño original)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Historial Clínico',
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
                    '${widget.visits.length} visitas',
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

            // Lista de visitas
            widget.isLoading
                ? _buildShimmer()
                : Column(
                    children: widget.visits.take(3).map((visit) => _buildVisitItem(context, visit)).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitItem(BuildContext context, dynamic visit) {
    final String patientName = visit['patientName'] ?? 'Paciente';
    final String treatment = visit['treatment'] ?? 'Consulta';
    final String date = _formatDate(visit['date']);
    final String? notes = visit['notes'];
    final String status = visit['status'] ?? 'scheduled';
    final bool isCompleted = status == 'completed';
    final bool isInProgress = status == 'in-progress';
    final String visitId = visit['id'] ?? '';
    final bool isProcessing = _processingIds.contains(visitId);

    return InkWell(
      onTap: () => widget.onTap?.call(visit),
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
            // Icono según estado (tu diseño original)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Info (tu diseño original)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
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
                          treatment,
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
                  if (notes != null && notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notes,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ✅ Check-in/Check-out button + Estado
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                if (!isCompleted && widget.onStatusChange != null)
                  GestureDetector(
                    onTap: isProcessing ? null : () => _handleCheckInOut(visit),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isProcessing
                            ? Colors.grey[300]
                            : (isInProgress ? const Color(0xFFEA580C) : const Color(0xFF0F766E)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              isInProgress ? 'Check-out' : 'Check-in',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isInProgress ? const Color(0xFFEA580C) : const Color(0xFF0F766E),
                              ),
                            ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
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

  Widget _buildShimmer() {
    return Column(
      children: List.generate(3, (index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
