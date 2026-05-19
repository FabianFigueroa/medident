import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-camera.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:medident/main_export.dart';

class SignupTablet extends StatelessWidget {
  final TrackingScrollController trackingScrollController;

  const SignupTablet({super.key, required this.trackingScrollController});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();

    return Scaffold(
      //bottomSheet: ,
      appBar: AppBar(title: const Text('Registro')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: trackingScrollController,
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceDialog(context, provider),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: provider.previewImageBytes != null ? MemoryImage(provider.previewImageBytes!) : null,
                          child: provider.previewImageBytes == null
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary, width: 1.0),
                          ),
                          child: Text(
                            'Escoger fotografia',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(provider.fullNameController, ' Nombres: '),
                  _buildTextField(provider.emailController, ' Correo: ', keyboardType: TextInputType.emailAddress),
                  _buildTextField(provider.passwordController, ' Contraseña: ', obscureText: true),
                  _buildTextField(provider.confirmPasswordController, ' Repetir Contraseña: ', obscureText: true),
                  TextField(
                    controller: provider.birthDateController,
                    decoration: _inputDecoration(' Fecha de Nacimiento: '),
                    readOnly: true,
                    onTap: () => _selectDate(context, provider),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<UserGender>(
                          value: provider.selectedGender,
                          onChanged: (gender) => provider.setSelectedGender(gender),
                          items: UserGender.values.map((g) => DropdownMenuItem(value: g, child: Text(g.displayName))).toList(),
                          decoration: _inputDecoration(' Género '),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: (provider.isAdminCheckLoading)
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<UserRole>(
                          value: provider.selectedRole,
                          hint: const Text('Rol'),
                          onChanged: (role) => provider.setSelectedRole(role),
                          items: UserRole.values.where((role) {
                            if (role == UserRole.admin) return provider.isAdminRoleAvailable;
                            return true;
                          }).map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.displayName),
                          ),).toList(),
                          decoration: _inputDecoration('Selecciona tu Rol: '),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (provider.selectedRole == UserRole.employee) ...[
                    _buildTextField(provider.nitController, ' NIT: '),
                    const SizedBox(height: 5),
                    (provider.isLoadingCards)
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                      value: provider.selectedCardDisplay,
                      hint: const Text('Selecciona una Tarjeta'),
                      onChanged: (display) => provider.setSelectedCardCode(display),
                      items: (provider.availableCards ?? [])
                          .map((display) => DropdownMenuItem(value: display, child: Text(display)))
                          .toList(),
                      decoration: _inputDecoration('Selecciona una Tarjeta: '),
                    ),
                    const SizedBox(height: 15),
                  ],
                  //const SizedBox(height: 122),
                ],
              ),
            ),
          ),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _onRegisterPressed(context, provider),
                  style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.whiteLigthColor,
                      minimumSize: const Size(double.infinity, 50)),
                  child: const Text(
                    'Registrarme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////// image source dialog
  void _showImageSourceDialog(BuildContext context, RegisterProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Elegir una Foto'),
        actions: [
          TextButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Galería'), onPressed: () async {
            Navigator.of(dialogContext).pop();
            await provider.pickImageFromGallery();
            if (context.mounted && provider.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.red));
            }
          }),
          TextButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Cámara'), onPressed: () {
            Navigator.of(dialogContext).pop();
            _openCamera(context, provider);
          }),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////// camera
  Future<void> _openCamera(BuildContext context, RegisterProvider provider) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final Uint8List? imageBytes = await navigator.push(
        MaterialPageRoute(builder: (_) => const AppCameraScreen()),
      );
      if (imageBytes != null) {
        provider.setImageBytes(imageBytes);
      }
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Se necesita permiso para usar la cámara.'), backgroundColor: Colors.red));
    }
  }

  Future<void> _selectDate(BuildContext context, RegisterProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) provider.setSelectedBirthDate(picked);
  }

  //////////////////////////////////////////////////////////////// NAVEGACIÓN CORREGIDA
  Future<void> _onRegisterPressed(BuildContext context, RegisterProvider provider) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.register();
    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text(' ¡Registro exitoso! '), backgroundColor: Colors.green));
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => SigninScreen(
            initialEmail: provider.emailController.text.trim(),
          ),
        ),
      );
    } else if (provider.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.red));
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(controller: controller, decoration: _inputDecoration(label), obscureText: obscureText, keyboardType: keyboardType),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(labelText: label, border: const OutlineInputBorder());
  }
}
