import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:medident/main_export.dart';

class SignupDesktop extends StatelessWidget {
  final TrackingScrollController trackingScrollController;

  const SignupDesktop({super.key, required this.trackingScrollController});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: double.infinity,
            child: Image.asset('assets/images/signup.png', fit: BoxFit.cover),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: trackingScrollController,
                    padding: const EdgeInsets.fromLTRB(50, 20, 50, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.width * 0.1,
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: Image.asset('assets/images/signup.png', fit: BoxFit.cover),
                        ),
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(context, provider),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: provider.previewImageBytes != null
                                    ? MemoryImage(provider.previewImageBytes!)
                                    : null,
                                child: provider.previewImageBytes == null
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : null,
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary, width: 1),
                                ),
                                child: const Text(
                                  'Tomar Foto',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(provider.fullNameController, ' Nombres: '),
                        _buildTextField(
                          provider.emailController,
                          ' Correo: ',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          provider.passwordController,
                          ' Contrasena: ',
                          obscureText: true,
                        ),
                        _buildTextField(
                          provider.confirmPasswordController,
                          ' Repetir Contrasena: ',
                          obscureText: true,
                        ),
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
                                initialValue: provider.selectedGender,
                                onChanged: provider.setSelectedGender,
                                items: UserGender.values
                                    .map(
                                      (gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender.displayName),
                                      ),
                                    )
                                    .toList(),
                                decoration: _inputDecoration(' Genero '),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: provider.isAdminCheckLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : DropdownButtonFormField<UserRole>(
                                      initialValue: provider.selectedRole,
                                      hint: const Text('Rol'),
                                      onChanged: provider.setSelectedRole,
                                      items: UserRole.values
                                          .where((role) {
                                            if (role == UserRole.admin) {
                                              return provider.isAdminRoleAvailable;
                                            }
                                            return true;
                                          })
                                          .map(
                                            (role) => DropdownMenuItem(
                                              value: role,
                                              child: Text(role.displayName),
                                            ),
                                          )
                                          .toList(),
                                      decoration: _inputDecoration('Selecciona tu Rol: '),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (provider.selectedRole == UserRole.employee) ...[
                          _buildTextField(provider.nitController, ' NIT: '),
                          const SizedBox(height: 5),
                          provider.isLoadingCards
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<String>(
                                  value: provider.selectedCardDisplay,
                                  hint: const Text('Selecciona una Tarjeta'),
                                  onChanged: (display) => provider.setSelectedCardCode(display),
                                  items: (provider.availableCards ?? [])
                                      .map(
                                        (display) => DropdownMenuItem(
                                          value: display,
                                          child: Text(display),
                                        ),
                                      )
                                      .toList(),
                                  decoration: _inputDecoration('Selecciona una Tarjeta: '),
                                ),
                          const SizedBox(height: 15),
                        ],
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50, 10, 50, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _onRegisterPressed(context, provider),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.whiteLigthColor,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'registrarme',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, RegisterProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Elegir una Foto'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeria'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await provider.pickImageFromGallery();
              if (context.mounted && provider.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camara'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _openCamera(context, provider);
            },
          ),
        ],
      ),
    );
  }

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
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Se necesita permiso para usar la camara.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, RegisterProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      provider.setSelectedBirthDate(picked);
    }
  }

  Future<void> _onRegisterPressed(BuildContext context, RegisterProvider provider) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    debugPrint('SIGNUP_DESKTOP: Boton registrarme presionado.');
    final success = await provider.register();
    debugPrint('SIGNUP_DESKTOP: Resultado de register(): $success');

    if (!context.mounted) {
      debugPrint('SIGNUP_DESKTOP: Context ya no esta montado, se cancela la navegacion.');
      return;
    }

    if (success) {
      final email = provider.emailController.text.trim();
     debugPrint('SIGNUP_DESKTOP: Navegando a SigninScreen con email $email');
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Ahora inicia sesion.'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SigninScreen(initialEmail: email),
        ),
        (route) => false,
      );
      return;
    }

    if (provider.errorMessage != null) {
      debugPrint('SIGNUP_DESKTOP: Mostrando error en pantalla: ${provider.errorMessage}');
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label),
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }
}
