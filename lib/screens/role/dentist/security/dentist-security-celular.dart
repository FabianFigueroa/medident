import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-info-section.dart' hide Device;
import 'package:provider/provider.dart';
import 'dart:typed_data';

class DentistSecurityCelular extends StatelessWidget {
  const DentistSecurityCelular({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('[DentistSecurityCelular] build() iniciado');
    
    final provider = context.watch<DentistSecurityProvider>();
    debugPrint('[DentistSecurityCelular] Provider obtenido: ${provider.uid}');
    debugPrint('[DentistSecurityCelular] isLoading: ${provider.isLoading}');
    debugPrint('[DentistSecurityCelular] Error: ${provider.error}');
    
    final profile = provider.securityData;
    debugPrint('[DentistSecurityCelular] securityData null: ${profile == null}');

    if (profile == null) {
      debugPrint('[DentistSecurityCelular] Profile nulo, mostrando loading...');
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    debugPrint('[DentistSecurityCelular] Profile cargado correctamente');
    debugPrint('[DentistSecurityCelular] UserId del profile: ${profile.userId}');

    final bool isRegisteringCard = profile.isRegisteringCard;
    final String? scannedRfidCardId = profile.scannedRfidCardId;
    final bool isAssigningRfidCard = profile.isAssigningRfidCard;

    debugPrint('[DentistSecurityCelular] Tarjeta registrándose: $isRegisteringCard');
    debugPrint('[DentistSecurityCelular] RFID escaneado: $scannedRfidCardId');
    debugPrint('[DentistSecurityCelular] Asignando RFID: $isAssigningRfidCard');

    final List<Map<String, dynamic>> allDevices = [];
    allDevices.addAll(profile.lights.map((d) => ({'type': 'lights', 'device': d})));
    allDevices.addAll(profile.fans.map((d) => ({'type': 'fans', 'device': d})));
    allDevices.addAll(profile.airs.map((d) => ({'type': 'airs', 'device': d})));
    allDevices.addAll(profile.tvs.map((d) => ({'type': 'tvs', 'device': d})));
    allDevices.addAll(profile.voices.map((d) => ({'type': 'voices', 'device': d})));
    allDevices.addAll(profile.doors.map((d) => ({'type': 'doors', 'device': d})));

    debugPrint('[DentistSecurityCelular] Total dispositivos: ${allDevices.length}');
    debugPrint('[DentistSecurityCelular] Lights: ${profile.lights.length}, Fans: ${profile.fans.length}, Airs: ${profile.airs.length}');
    debugPrint('[DentistSecurityCelular] TVs: ${profile.tvs.length}, Voices: ${profile.voices.length}, Doors: ${profile.doors.length}');
    
    debugPrint('[DentistSecurityCelular] Construyendo UI...');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [

          _buildDentistSecurityAppBar(),
          
          // --- RESUMEN EJECUTIVO ---
          _buildSecuritySummary(context, provider, profile),

          // --- NUEVO WIDGET DE CONTROL LED ---
          _buildLedControlSection(context, provider),

          // --- SECCIÓN DE EMPLEADOS ---
          _buildEmployeesSection(context, profile),

          if (isRegisteringCard)
            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingS, vertical: AppConstants.paddingS),
                color: AppColors.secondary.withOpacity(0.1),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXS)),
                child: ListTile(
                  leading: const Icon(Icons.nfc_rounded, color: AppColors.secondary, size: AppConstants.iconL),
                  title: Text('Modo Registro de Tarjeta Activo', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('Acerca la nueva tarjeta RFID al lector para registrarla.', style: AppTextStyles.bodyMedium),
                  trailing: TextButton(
                    onPressed: () => provider.setCardRegistrationMode(false),
                    child: Text('Cancelar', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
                  ),
                ),
              ),
            ),

          /////////////////////////////////////////////////////////// items
          _buildDeviceGrid(context, provider, allDevices),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestión de Tarjetas RFID', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppConstants.paddingS),
                  _buildRfidCardManagement(context, provider, isRegisteringCard, scannedRfidCardId, isAssigningRfidCard),
                  const SizedBox(height: AppConstants.paddingS),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESP32-CAM', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppConstants.paddingS),
                  _buildEsp32CamSection(context, provider),
                  const SizedBox(height: AppConstants.paddingS),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋 Bitácora de Seguridad', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppConstants.paddingS),
                  _buildSecurityEventsList(context),
                  const SizedBox(height: AppConstants.paddingL),
                ],
              ),
            ),
          ),
        ],
      ),
      //floatingActionButton: const AddSecurityEventFloatingButton(),
    );
  }
  
  // --- NUEVO WIDGET DE CONTROL LED ---
  Widget _buildLedControlSection(BuildContext context, DentistSecurityProvider provider) {
    debugPrint('[DentistSecurityCelular._buildLedControlSection] Construyendo sección LED');
    final String? selectedOption = provider.dentistSecurityModel?.activeLedOption;
    debugPrint('[DentistSecurityCelular._buildLedControlSection] Opción LED seleccionada: $selectedOption');

    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.all(AppConstants.paddingS),
        elevation: AppConstants.elevationS,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Control Tira LED', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLedOptionButton(context, provider, 'Modo 1', 'led_option_1', Icons.looks_one_rounded, selectedOption),
                  _buildLedOptionButton(context, provider, 'Modo 2', 'led_option_2', Icons.looks_two_rounded, selectedOption),
                  _buildLedOptionButton(context, provider, 'Modo 3', 'led_option_3', Icons.looks_3_rounded, selectedOption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLedOptionButton(BuildContext context, DentistSecurityProvider provider, String label, String optionKey, IconData icon, String? selectedOption) {
    final bool isSelected = selectedOption == optionKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Si el botón ya está seleccionado, lo deselecciona (apaga). Si no, lo selecciona.
          final newOption = isSelected ? null : optionKey;
          provider.updateActiveLedOption(newOption);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingXS),
          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary.withOpacity(0.15) : AppColors.background,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.grey300,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppConstants.iconL,
                color: isSelected ? AppColors.secondary : AppColors.grey600,
              ),
              const SizedBox(height: AppConstants.paddingXS),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.secondary : AppColors.grey700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDeviceGrid(BuildContext context, DentistSecurityProvider provider, List<Map<String, dynamic>> devices) {
    if (devices.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingXXL),
            child: Text(
              'No hay dispositivos.\nPresiona el botón de arriba para añadir uno.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
            ),
          ),
        ),
      );
    }
    
    return SliverPadding(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.paddingM,
          mainAxisSpacing: AppConstants.paddingM,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final deviceMap = devices[index];
            return _buildDeviceCard(context, provider, deviceMap['type'], deviceMap['device']);
          },
          childCount: devices.length,
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, DentistSecurityProvider provider, String deviceType, Device device) {
    debugPrint('[DentistSecurityCelular._buildDeviceCard] Construyendo tarjeta para: $deviceType - ${device.name}');
    final bool isOn = device.isOn;
    debugPrint('[DentistSecurityCelular._buildDeviceCard] Estado: $isOn');
    
    final Map<String, IconData> icons = {
      'lights': Icons.lightbulb_outline_rounded,
      'fans': Icons.wind_power_outlined,
      'tvs': Icons.tv_rounded,
      'airs': Icons.ac_unit_rounded,
      'voices': Icons.record_voice_over_rounded,
      'doors': Icons.door_front_door_outlined,
    };
    
    final IconData icon = icons[deviceType] ?? Icons.device_unknown_rounded;
    final Color activeColor = AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isOn ? activeColor.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM), // Usar radiusM
        border: Border.all(color: isOn ? activeColor : AppColors.grey300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isOn ? activeColor : AppColors.black).withOpacity(isOn ? 0.2 : 0.05),
            blurRadius: AppConstants.elevationM,
            offset: const Offset(0, AppConstants.elevationS),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          onTap: () {
            debugPrint('[DentistSecurityCelular._buildDeviceCard.onTap] Dispositivo tocado: $deviceType - ${device.name}');
            debugPrint('[DentistSecurityCelular._buildDeviceCard.onTap] Cambiando estado de $isOn a ${!isOn}');
            provider.updateUserDeviceState(deviceType, device.id, !isOn);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      icon,
                      size: AppConstants.iconL, // Usar iconL
                      color: isOn ? activeColor : AppColors.grey600,
                    ),
                    Switch(
                      value: isOn,
                      onChanged: (newState) {
                        provider.updateUserDeviceState(deviceType, device.id, newState);
                      },
                      activeColor: activeColor,
                      inactiveTrackColor: AppColors.grey300,
                      inactiveThumbColor: AppColors.grey500,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(
                      device.id,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRfidCardManagement(BuildContext context, DentistSecurityProvider provider,
      bool isRegisteringCard, String? scannedRfidCardId, bool isAssigningRfidCard) {
    debugPrint('[DentistSecurityCelular._buildRfidCardManagement] Construyendo gestión RFID');
    debugPrint('[DentistSecurityCelular._buildRfidCardManagement] isRegisteringCard: $isRegisteringCard');
    debugPrint('[DentistSecurityCelular._buildRfidCardManagement] scannedRfidCardId: $scannedRfidCardId');
    debugPrint('[DentistSecurityCelular._buildRfidCardManagement] isAssigningRfidCard: $isAssigningRfidCard');
    
    final rfidCards = provider.rfidCards;
    debugPrint('[DentistSecurityCelular._buildRfidCardManagement] Total tarjetas RFID: ${rfidCards.length}');

    return Card(
      elevation: AppConstants.elevationS,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)), // Usar radiusM
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tarjetas RFID Registradas', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: Icon(isRegisteringCard ? Icons.mic_off : Icons.nfc_rounded, color: AppColors.white),
                  label: Text(isRegisteringCard ? 'Desactivar' : 'Activar', style: AppTextStyles.labelLarge.copyWith(color: AppColors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegisteringCard ? AppColors.error : AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXS)), // Usar radiusXS
                  ),
                  onPressed: () => provider.setCardRegistrationMode(!isRegisteringCard),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            if (scannedRfidCardId != null && isAssigningRfidCard) // Si hay una tarjeta escaneada esperando asignación
              _buildAssignScannedRfidCard(context, provider, scannedRfidCardId)
            else if (rfidCards.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                child: Center(
                  child: Text(
                    'No hay tarjetas RFID registradas aún.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rfidCards.length,
                itemBuilder: (context, index) {
                  final card = rfidCards[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingXS),
                    elevation: AppConstants.elevationS, // Usar elevationXS
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusS)), // Usar radiusS
                    child: ListTile(
                      leading: const Icon(Icons.credit_card_rounded, color: AppColors.primary, size: AppConstants.iconM),
                      title: Text(card.assignedTo, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('ID: ${card.cardId}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: AppConstants.iconM),
                        onPressed: () => _confirmDeleteRfidCard(context, provider, card.cardId, card.assignedTo),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignScannedRfidCard(BuildContext context, DentistSecurityProvider provider, String cardId) {
    final TextEditingController cardNameController = TextEditingController();
    cardNameController.text = 'Nueva Tarjeta RFID'; // Valor por defecto

    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarjeta RFID Escaneada:',
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(cardId, style: AppTextStyles.bodyLarge.copyWith(fontFamily: 'monospace', color: AppColors.primary)), // Usar AppTextStyles y AppColors
          const SizedBox(height: AppConstants.paddingM),
          TextFormField(
            controller: cardNameController,
            decoration: InputDecoration(
              labelText: 'Nombre para la tarjeta',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXS)), // Usar radiusXS
              prefixIcon: const Icon(Icons.label_outline, color: AppColors.primary),
              labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.grey700), // Estilo para el label
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXS)), // Usar radiusXS
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
                  ),
                  onPressed: () async {
                    if (cardNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor, ingresa un nombre para la tarjeta.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)), backgroundColor: AppColors.error));
                      return;
                    }
                    await provider.assignRfidCard(cardId: cardId, cardName: cardNameController.text.trim());
                    cardNameController.dispose();
                  },
                  child: Text('Asignar Tarjeta', style: AppTextStyles.buttonTextLarge.copyWith(color: AppColors.white)), // Usar buttonTextLarge
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    provider.cancelRfidAssignment();
                    cardNameController.dispose();
                  },
                  child: Text('Cancelar', style: AppTextStyles.buttonText.copyWith(color: AppColors.error)), // Usar buttonText
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRfidCard(BuildContext context, DentistSecurityProvider provider, String cardId, String cardName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación', style: AppTextStyles.titleLarge),
        content: Text('¿Estás seguro de que quieres eliminar la tarjeta RFID "$cardName"?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXS))), // Usar radiusXS
            onPressed: () {
              provider.deleteRfidCard(cardId);
              Navigator.of(context).pop();
            },
            child: Text('Eliminar', style: AppTextStyles.buttonText.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEsp32CamSection(BuildContext context, DentistSecurityProvider provider) {
    debugPrint('[DentistSecurityCelular._buildEsp32CamSection] Construyendo sección cámara');
    final profile = provider.securityProfile;
    debugPrint('[DentistSecurityCelular._buildEsp32CamSection] Profile null: ${profile == null}');
    
    final String? esp32CamIp = profile?.esp32CamIp;
    final bool isCameraActive = profile?.isCameraActive ?? false;
    final Uint8List? lastCameraSnapshot = provider.lastCameraSnapshot;
    final bool isCameraConnected = provider.isCameraConnected;

    debugPrint('[DentistSecurityCelular._buildEsp32CamSection] IP Cámara: $esp32CamIp');
    debugPrint('[DentistSecurityCelular._buildEsp32CamSection] Cámara activa: $isCameraActive');
    debugPrint('[DentistSecurityCelular._buildEsp32CamSection] Cámara conectada: $isCameraConnected');
    debugPrint('[DentistSecurityCelular._buildEsp32CamSection] Snapshot: $lastCameraSnapshot');debugPrint('[DentistSecurityCelular._buildEsp32CamSection] Snapshot disponible: ${lastCameraSnapshot != null}');

    return Card(
      elevation: AppConstants.elevationS,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cámara de Seguridad', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.grey700, size: AppConstants.iconM),
                  onPressed: () => _showEsp32CamConfigDialog(context, provider, esp32CamIp, isCameraActive),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingS),
            ListTile(
              leading: Icon(isCameraConnected ? Icons.videocam : Icons.videocam_off, color: isCameraConnected ? AppColors.positive : AppColors.error, size: AppConstants.iconL),
              title: Text('Estado de la Cámara', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(isCameraConnected ? 'Conectada' : 'Desconectada', style: AppTextStyles.bodyMedium.copyWith(color: isCameraConnected ? AppColors.positive : AppColors.error)),
              trailing: Switch(
                value: isCameraActive,
                onChanged: (newValue) {
                  provider.setEsp32CamConfig(ipAddress: esp32CamIp, isActive: newValue);
                },
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),

            if (lastCameraSnapshot != null && isCameraConnected)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                child: Image.memory(
                  lastCameraSnapshot,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: AppColors.grey200,
                    child: Center(child: Icon(Icons.broken_image, size: AppConstants.iconXL, color: AppColors.grey500)),
                  ),
                ),
              )
            else if (!isCameraActive)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingL),
                  child: Text(
                    'La cámara está inactiva.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingL),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: AppConstants.paddingS),
                      Text('Conectando a la cámara...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEsp32CamConfigDialog(BuildContext context, DentistSecurityProvider provider, String? currentIp, bool currentIsActive) {
    final TextEditingController ipController = TextEditingController(text: currentIp);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Configurar ESP32-CAM', style: AppTextStyles.titleLarge),
          content: TextFormField(
            controller: ipController,
            decoration: InputDecoration(
              labelText: 'Dirección IP de la ESP32-CAM',
              hintText: 'ej. 192.168.1.100',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXS)),
              prefixIcon: const Icon(Icons.network_check, color: AppColors.primary),
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXS))),
              onPressed: () async {
                Navigator.of(context).pop();
                final newIp = ipController.text.trim();
                await provider.setEsp32CamConfig(ipAddress: newIp.isEmpty ? null : newIp, isActive: currentIsActive);
                ipController.dispose();
              },
              child: Text('Guardar', style: AppTextStyles.buttonText.copyWith(color: AppColors.white)),
            ),
          ],
        );
      },
    ).whenComplete(() {
      ipController.dispose();
    });
  }
  Widget _buildDentistSecurityAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 2,
      backgroundColor: AppColors.primary,
      title: Text('Seguridad', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.white),
          onPressed: () {
            // Refresh action
          },
        ),
      ],
    );
  }

  // --- RESUMEN EJECUTIVO ---
  Widget _buildSecuritySummary(BuildContext context, DentistSecurityProvider provider, DentistSecurityModel profile) {
    debugPrint('[DentistSecurityCelular._buildSecuritySummary] Construyendo resumen');
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.8), AppColors.secondary.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 Resumen de Seguridad',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard(
                    icon: '🆔',
                    label: 'Tarjetas RFID',
                    value: '${profile.rfidCards.length}',
                    color: AppColors.white,
                  ),
                  _buildSummaryCard(
                    icon: '🔌',
                    label: 'Dispositivos',
                    value: '${profile.lights.length + profile.fans.length + profile.airs.length + profile.tvs.length + profile.doors.length}',
                    color: AppColors.white,
                  ),
                  _buildSummaryCard(
                    icon: '✅',
                    label: 'Activos',
                    value: '${profile.lights.where((l) => l.isOn).length}',
                    color: AppColors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --- SECCIÓN DE EMPLEADOS ---
  Widget _buildEmployeesSection(BuildContext context, DentistSecurityModel profile) {
    debugPrint('[DentistSecurityCelular._buildEmployeesSection] Construyendo sección empleados');
    debugPrint('[DentistSecurityCelular._buildEmployeesSection] locationId: ${profile.locationId}');

    final clinicId = profile.locationId;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('Personal de Turno', style: AppTextStyles.headlineSmall),
                const Spacer(),
                if (clinicId.isNotEmpty)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('clinicId', isEqualTo: clinicId)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox.shrink();
                      final total = snap.data!.docs.length;
                      final active = snap.data!.docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return data['isInClinic'] == true;
                      }).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.positive.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$active/$total',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.positive,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingS),
            if (clinicId.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No hay clínica vinculada para mostrar personal.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600, fontStyle: FontStyle.italic),
                ),
              )
            else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('clinicId', isEqualTo: clinicId)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          'Sin personal registrado en la clínica.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600, fontStyle: FontStyle.italic),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final name = data['fullName'] as String? ?? 'Sin nombre';
                        final photoUrl = data['imageUrl'] as String?;
                        final role = data['role'] as String? ?? 'employee';
                        final isInClinic = data['isInClinic'] == true;
                        final cardCode = data['assignedCardCode'] as String?;
                        final hasCard = cardCode != null && cardCode.isNotEmpty;

                        return _StaffCard(
                          name: name,
                          photoUrl: photoUrl,
                          role: role,
                          isInClinic: isInClinic,
                          hasCard: hasCard,
                        );
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: AppConstants.paddingM),
          ],
        ),
      ),
    );
  }

  Widget _StaffCard({
    required String name,
    String? photoUrl,
    required String role,
    required bool isInClinic,
    required bool hasCard,
  }) {
    final activeColor = AppColors.positive;

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: AppConstants.paddingS),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isInClinic ? activeColor.withOpacity(0.3) : AppColors.grey300,
          width: isInClinic ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isInClinic
                ? activeColor.withOpacity(0.08)
                : AppColors.black.withOpacity(0.03),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isInClinic
                          ? activeColor.withOpacity(0.15)
                          : AppColors.grey100,
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isInClinic ? activeColor : AppColors.grey500,
                              ),
                            )
                          : null,
                    ),
                    if (isInClinic)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppConstants.paddingXS),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isInClinic ? AppColors.textPrimary : AppColors.grey500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _roleLabel(role),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isInClinic
                            ? activeColor
                            : hasCard
                                ? Colors.orange[300]
                                : AppColors.grey400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isInClinic
                          ? 'En clínica'
                          : hasCard
                              ? 'Sin marcar'
                              : 'Sin tarjeta',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isInClinic
                            ? activeColor
                            : hasCard
                                ? Colors.orange[400]
                                : AppColors.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'dentist':
        return 'Odontólogo/a';
      case 'employee':
        return 'Empleado/a';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  Widget _buildSecurityEventsList(BuildContext context) {
    debugPrint('[DentistSecurityCelular._buildSecurityEventsList] Construyendo bitácora');
    
    final securityEvents = [
      {
        'icon': '🆔',
        'title': 'Acceso con Tarjeta RFID',
        'subtitle': 'Dr. Roberto Silva - Entrada',
        'time': 'Hace 5 minutos',
        'color': AppColors.positive,
      },
      {
        'icon': '🚪',
        'title': 'Puerta Desbloqueada',
        'subtitle': 'Puerta Principal - Acceso Manual',
        'time': 'Hace 12 minutos',
        'color': AppColors.secondary,
      },
      {
        'icon': '💡',
        'title': 'Luz Encendida',
        'subtitle': 'Consultorio 1 - Sistema Automático',
        'time': 'Hace 25 minutos',
        'color': AppColors.primary,
      },
      {
        'icon': '🔴',
        'title': 'Alarma Desactivada',
        'subtitle': 'Sistema General - Dr. Silva',
        'time': 'Hace 1 hora',
        'color': AppColors.error,
      },
      {
        'icon': '✅',
        'title': 'Sistema Sincronizado',
        'subtitle': 'Todos los valores actualizados',
        'time': 'Hace 2 horas',
        'color': AppColors.positive,
      },
    ];

    return Column(
      children: List.generate(
        securityEvents.length,
        (index) {
          final event = securityEvents[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(color: AppColors.grey300),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingS),
              child: Row(
                children: [
                  Text(
                    event['icon'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'] as String,
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['subtitle'] as String,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        event['time'] as String,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingXS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (event['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                        ),
                        child: Text(
                          'Registrado',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: event['color'] as Color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
