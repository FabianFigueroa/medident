import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/ia/valeria-provider.dart';

class ValeriaTrainingPanel extends StatelessWidget {
  const ValeriaTrainingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ValeriaProvider>(
      builder: (context, valeria, _) {
        final status = valeria.trainingStatus;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Entrenamiento de Valeria',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Ubuntu-Bold'),
                  ),
                  const Spacer(),
                  if (status.isReady)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'LISTO',
                        style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: status.progress,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Text(
                '${(status.progress * 100).toInt()}% completo',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 12),
              _buildStatRow(Icons.chat, 'Conversaciones', '${status.chatCount}', '/50', status.chatCount >= 50),
              _buildStatRow(Icons.alt_route, 'Intents únicos', '${status.uniqueIntents}', '/5', status.uniqueIntents >= 5),
              _buildStatRow(Icons.feedback, 'Feedbacks', '${status.feedbackCount}', '/10', status.feedbackCount >= 10),
              _buildStatRow(Icons.screen_share, 'Pantallas vistas', '${status.uniqueScreens}', '', true),
              _buildStatRow(Icons.bar_chart, 'Interacciones totales', '${status.totalInteractions}', '', true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportData(context, valeria),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Exportar JSON', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0),
                        side: const BorderSide(color: Color(0xFF1565C0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: status.totalInteractions == 0 ? null : () => _resetData(context, valeria),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Reiniciar', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: status.totalInteractions == 0 ? Colors.grey.shade300 : Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, String max, bool achieved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: achieved ? const Color(0xFF1565C0) : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          if (max.isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(max, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ],
          const SizedBox(width: 6),
          Icon(
            achieved ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: achieved ? Colors.green : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, ValeriaProvider valeria) {
    final data = valeria.exportTrainingData();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Datos exportados'),
        content: Text('${data.length} interacciones exportadas como JSON.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _resetData(BuildContext context, ValeriaProvider valeria) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Reiniciar datos?'),
        content: const Text('Esto borrará todo el historial de entrenamiento de Valeria.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              valeria.resetTrainingData();
              Navigator.pop(ctx);
            },
            child: const Text('Reiniciar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
