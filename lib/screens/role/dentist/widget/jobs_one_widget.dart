import 'package:flutter/material.dart';
import 'package:medident/core/models/jobs-model.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:provider/provider.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class Job_One_Widget extends StatefulWidget {
  final JobModel job;
  final String currentUserId;
  final bool isSaved;
  final bool hasApplied;
  final Function(String)? onSave;
  final Function(String, String?)? onApply;
  final Function(String)? onShare;

  const Job_One_Widget({
    super.key,
    required this.job,
    required this.currentUserId,
    this.isSaved = false,
    this.hasApplied = false,
    this.onSave,
    this.onApply,
    this.onShare,
  });

  @override
  State<Job_One_Widget> createState() => _Job_One_WidgetState();
}

class _Job_One_WidgetState extends State<Job_One_Widget> {
  bool _isSaved = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
    _hasApplied = widget.hasApplied;
  }

  @override
  void didUpdateWidget(covariant Job_One_Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSaved != widget.isSaved) {
      _isSaved = widget.isSaved;
    }
    if (oldWidget.hasApplied != widget.hasApplied) {
      _hasApplied = widget.hasApplied;
    }
  }

  Future<void> _showApplyDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aplicar a empleo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Deseas aplicar a "${widget.job.title}"?',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Carta de presentación (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onApply?.call(widget.job.id, controller.text.trim().isNotEmpty ? controller.text.trim() : null);
              Navigator.pop(context, true);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    if (result == true) {
      setState(() => _hasApplied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DentistHomeProvider>();
    final bool isExpired = widget.job.expiresAt != null && 
        widget.job.expiresAt!.isBefore(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
            // Header with save/share buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company logo or placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getJobGradient(widget.job.type),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SafeNetworkImage(
                    imageUrl: widget.job.companyLogo,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.job.company,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ✅ Save and share buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onSave != null)
                      GestureDetector(
                        onTap: () {
                          widget.onSave?.call(widget.job.id);
                          setState(() => _isSaved = !_isSaved);
                        },
                        child: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: _isSaved ? const Color(0xFF1D4ED8) : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    if (widget.onSave != null && widget.onShare != null)
                      const SizedBox(width: 8),
                    if (widget.onShare != null)
                      GestureDetector(
                        onTap: () => widget.onShare?.call(widget.job.id),
                        child: Icon(
                          Icons.share_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                  ],
                ),
                if (isExpired)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Vencido',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              widget.job.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Info row
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.location_on_outlined,
                  label: widget.job.location,
                  color: const Color(0xFF0F766E),
                ),
                _buildInfoChip(
                  icon: _getJobTypeIcon(widget.job.type),
                  label: _getJobTypeLabel(widget.job.type),
                  color: const Color(0xFF7C3AED),
                ),
                if (widget.job.salary != null)
                  _buildInfoChip(
                    icon: Icons.attach_money,
                    label: '\$${widget.job.salary!.toStringAsFixed(0)}',
                    color: const Color(0xFFEA580C),
                  ),
                if (widget.job.specialty != null)
                  _buildInfoChip(
                    icon: Icons.medical_services_outlined,
                    label: widget.job.specialty!,
                    color: const Color(0xFF1D4ED8),
                  ),
              ],
            ),

            if (widget.job.requirements != null && widget.job.requirements!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Requisitos:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.job.requirements!.take(3).map((req) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE0F2FE)),
                    ),
                    child: Text(
                      req,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isExpired ? null : () {
                      provider.openJobDetails(widget.job.id);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFF1D4ED8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Ver detalles',
                      style: TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (isExpired || _hasApplied) ? null : () => _showApplyDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasApplied ? Colors.grey : const Color(0xFF1D4ED8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      _hasApplied ? 'Aplicado' : 'Aplicar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Posted date
            Text(
              'Publicado ${_getTimeAgo(widget.job.createdAt)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getJobGradient(String type) {
    switch (type) {
      case 'full-time':
        return [const Color(0xFF1D4ED8), const Color(0xFF3B82F6)];
      case 'part-time':
        return [const Color(0xFF7C3AED), const Color(0xFFA855F7)];
      case 'contract':
        return [const Color(0xFFEA580C), const Color(0xFFF97316)];
      case 'remote':
        return [const Color(0xFF0F766E), const Color(0xFF14B8A6)];
      default:
        return [const Color(0xFF475569), const Color(0xFF64748B)];
    }
  }

  IconData _getJobTypeIcon(String type) {
    switch (type) {
      case 'full-time':
        return Icons.work_outlined;
      case 'part-time':
        return Icons.schedule;
      case 'contract':
        return Icons.description_outlined;
      case 'remote':
        return Icons.computer;
      default:
        return Icons.work_outlined;
    }
  }

  String _getJobTypeLabel(String type) {
    switch (type) {
      case 'full-time':
        return 'Tiempo completo';
      case 'part-time':
        return 'Medio tiempo';
      case 'contract':
        return 'Contrato';
      case 'remote':
        return 'Remoto';
      default:
        return type;
    }
  }

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) return 'hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'hace ${difference.inHours}h';
    if (difference.inDays < 30) return 'hace ${difference.inDays}d';
    return 'hace ${(difference.inDays / 30).floor()} meses';
  }
}
