import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para configuración global de seguridad
class DentistSecuritySettings extends StatefulWidget {
  const DentistSecuritySettings({super.key});

  @override
  State<DentistSecuritySettings> createState() => _DentistSecuritySettingsState();
}

class _DentistSecuritySettingsState extends State<DentistSecuritySettings> {
  late bool _notificationsEnabled;
  late bool _biometricEnabled;
  late bool _cameraRecordingEnabled;
  late String _alertLevel;
  late TextEditingController _facilityNameController;

  @override
  void initState() {
    super.initState();
    debugPrint('[DentistSecuritySettings] initState() completado');
    
    _notificationsEnabled = true;
    _biometricEnabled = true;
    _cameraRecordingEnabled = true;
    _alertLevel = 'Alto';
    _facilityNameController = TextEditingController(text: 'Clínica Dental');
  }

  @override
  void dispose() {
    _facilityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistSecuritySettings] build() iniciado');
    
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;
    
    if (profile == null) return SliverToBoxAdapter(child: const SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚙️ Configuración de Seguridad', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppConstants.paddingM),
            
            // Facility Name
            _buildSettingSection('Nombre de la Instalación', [
              _buildTextField('Nombre', _facilityNameController),
            ]),
            
            // Notifications
            _buildSettingSection('Notificaciones', [
              _buildToggleSetting(
                'Habilitar Notificaciones',
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
                '🔔',
              ),
              _buildToggleSetting(
                'Alertas Críticas',
                true,
                (value) {},
                '⚠️',
              ),
            ]),
            
            // Biometric & Camera
            _buildSettingSection('Autenticación & Cámara', [
              _buildToggleSetting(
                'Autenticación Biométrica',
                _biometricEnabled,
                (value) => setState(() => _biometricEnabled = value),
                '👆',
              ),
              _buildToggleSetting(
                'Grabación Continua',
                _cameraRecordingEnabled,
                (value) => setState(() => _cameraRecordingEnabled = value),
                '📹',
              ),
            ]),
            
            // Alert Settings
            _buildSettingSection('Nivel de Alerta', [
              _buildDropdownSetting(
                'Sensibilidad',
                _alertLevel,
                ['Bajo', 'Medio', 'Alto', 'Máximo'],
                (value) => setState(() => _alertLevel = value ?? 'Alto'),
              ),
            ]),
            
            // Dangerous Zone
            _buildSettingSection('Zona de Peligro', [
              _buildDangerButton('🗑️ Limpiar Datos Locales', MainAxisAlignment.spaceBetween),
              const SizedBox(height: AppConstants.paddingM),
              _buildDangerButton('🔓 Cerrar Sesión', MainAxisAlignment.spaceBetween),
            ]),
            
            const SizedBox(height: AppConstants.paddingL),
            _buildSaveButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.paddingM),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const SizedBox(height: AppConstants.paddingM),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),
      ],
    );
  }

  Widget _buildToggleSetting(String label, bool value, Function(bool) onChanged, String emoji) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppConstants.paddingM),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingM),
      ),
    );
  }

  Widget _buildDropdownSetting(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        DropdownButton<String>(
          value: value,
          items: options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDangerButton(String label, MainAxisAlignment alignment) {
    return GestureDetector(
      onTap: () => _showConfirmationDialog(label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          border: Border.all(color: AppColors.error),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSaveButton(DentistSecurityProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          debugPrint('[DentistSecuritySettings] Guardando configuración');
          _showSnackBar('✅ Configuración guardada');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
        ),
        child: Text(
          'Guardar Cambios',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  void _showConfirmationDialog(String action) {
    debugPrint('[DentistSecuritySettings] Mostrando diálogo de confirmación: $action');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Acción'),
        content: Text('¿Estás seguro de que deseas ejecutar: $action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('✅ Acción ejecutada: $action');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.positive,
      ),
    );
  }
}
