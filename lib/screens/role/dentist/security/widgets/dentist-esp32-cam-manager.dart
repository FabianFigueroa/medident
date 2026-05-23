import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para gestionar ESP32-CAM
class DentistEsp32CamManager extends StatefulWidget {
  const DentistEsp32CamManager({super.key});

  @override
  State<DentistEsp32CamManager> createState() => _DentistEsp32CamManagerState();
}

class _DentistEsp32CamManagerState extends State<DentistEsp32CamManager> {
  late TextEditingController _ipController;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistEsp32CamManager] build() iniciado');
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityProfile;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📹 Cámara ESP32-CAM', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppConstants.paddingM),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estado de Conexión', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  provider.isCameraConnected ? Icons.check_circle : Icons.error,
                                  color: provider.isCameraConnected ? AppColors.positive : AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  provider.isCameraConnected ? 'Conectada' : 'Desconectada',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: provider.isCameraConnected ? AppColors.positive : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.settings),
                          label: const Text('Configurar'),
                          onPressed: () => _showConfigDialog(context, provider),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingL),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dirección IP:', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
                          const SizedBox(height: 4),
                          Text(
                            profile?.esp32CamIp ?? 'No configurada',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigDialog(BuildContext context, DentistSecurityProvider provider) {
    _ipController.text = provider.securityProfile?.esp32CamIp ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar ESP32-CAM'),
        content: TextField(
          controller: _ipController,
          decoration: InputDecoration(
            labelText: 'Dirección IP',
            hintText: '192.168.1.100',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusXS),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              provider.setEsp32CamConfig(
                ipAddress: _ipController.text.isNotEmpty ? _ipController.text : null,
                isActive: true,
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}
