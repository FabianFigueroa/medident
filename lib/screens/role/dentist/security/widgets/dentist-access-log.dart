import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para mostrar bitácora de accesos y eventos
class DentistAccessLog extends StatefulWidget {
  const DentistAccessLog({super.key});

  @override
  State<DentistAccessLog> createState() => _DentistAccessLogState();
}

class _DentistAccessLogState extends State<DentistAccessLog> {
  late TextEditingController _filterController;
  String _selectedType = 'Todos';

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController();
  debugPrint('[DentistAccessLog] initState() completado');
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistAccessLog] build() iniciado');
    
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;
    
    if (profile == null) return SliverToBoxAdapter(child: const SizedBox.shrink());

    final logs = profile.securityLogs;
    final filteredLogs = _filterLogs(logs);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📋 Bitácora de Accesos', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppConstants.paddingM),
            _buildFilterBar(),
            const SizedBox(height: AppConstants.paddingM),
            if (filteredLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Text('Sin registros', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) => _buildLogTile(filteredLogs[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        TextField(
          controller: _filterController,
          decoration: InputDecoration(
            hintText: '🔍 Buscar evento...',
            contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            suffixIcon: _filterController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _filterController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Todos', 'Acceso', 'Alerta', 'Dispositivo'].map((type) {
              final isSelected = _selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingS),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedType = type);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<SecurityLog> _filterLogs(List<SecurityLog> logs) {
    // Crear lista mutable al inicio para evitar errores con listas const
    var filtered = List<SecurityLog>.from(logs);
    
    // Filter by type
    if (_selectedType != 'Todos') {
      filtered = filtered.where((log) => log.type.toLowerCase().contains(_selectedType.toLowerCase())).toList();
    }
    
    // Filter by search
    if (_filterController.text.isNotEmpty) {
      filtered = filtered.where((log) {
        final query = _filterController.text.toLowerCase();
        return log.description.toLowerCase().contains(query) ||
            log.type.toLowerCase().contains(query);
      }).toList();
    }
    
    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return filtered;
  }

  Widget _buildLogTile(SecurityLog log) {
    final emoji = _getEmojiForType(log.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(log.description, style: AppTextStyles.bodyLarge),
        subtitle: Text(
          '${log.type} • ${_formatTime(log.timestamp)}',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
        ),
        trailing: Icon(
          _getIconForType(log.type),
          color: _getColorForType(log.type),
        ),
      ),
    );
  }

  String _getEmojiForType(String type) {
    if (type.toLowerCase().contains('acceso')) return '🚪';
    if (type.toLowerCase().contains('alerta')) return '⚠️';
    if (type.toLowerCase().contains('dispositivo')) return '⚙️';
    if (type.toLowerCase().contains('error')) return '❌';
    return '📌';
  }

  IconData _getIconForType(String type) {
    if (type.toLowerCase().contains('acceso')) return Icons.door_front_door;
    if (type.toLowerCase().contains('alerta')) return Icons.warning;
    if (type.toLowerCase().contains('dispositivo')) return Icons.settings;
    return Icons.info;
  }

  Color _getColorForType(String type) {
    if (type.toLowerCase().contains('alerta')) return AppColors.error;
    if (type.toLowerCase().contains('acceso')) return AppColors.primary;
    return AppColors.grey600;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 1) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }
}
