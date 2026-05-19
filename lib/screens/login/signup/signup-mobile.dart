import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medident/core/utils/app-camera.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:medident/main_export.dart';

class SignupMobile extends StatefulWidget {
  final TrackingScrollController trackingScrollController;
  const SignupMobile({super.key, required this.trackingScrollController});

  @override
  State<SignupMobile> createState() => _SignupMobileState();
}

class _SignupMobileState extends State<SignupMobile> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            controller: widget.trackingScrollController,
            child: Column(
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                  const SizedBox(width: 15),
                  _AnimatedItem(
                  delay: 0,
                  child: _buildLogoHeader(),
                ),
                ]),
                //const SizedBox(height: 24),
                _AnimatedItem(
                  delay: 100,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Text(
                        //   'Crear Cuenta',
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.w700,
                        //     color: Colors.grey.shade900,
                        //   ),
                        // ),
                        // const SizedBox(height: 6),
                        // Text(
                        //   'Completa tus datos para registrarte.',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.grey.shade500,
                        //   ),
                        // ),
                        //const SizedBox(height: 24),
                        _AnimatedItem(
                          delay: 100,
                          child: _buildPhotoSelector(context, provider),
                        ),
                        const SizedBox(height: 16),
                        _AnimatedItem(
                          delay: 150,
                          child: _buildTextField(
                            provider.fullNameController,
                            'Nombres',
                            Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedItem(
                          delay: 200,
                          child: _buildTextField(
                            provider.emailController,
                            'Correo electrónico',
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedItem(
                          delay: 250,
                          child: _buildTextField(
                            provider.passwordController,
                            'Contraseña',
                            Icons.lock_outline,
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedItem(
                          delay: 300,
                          child: _buildTextField(
                            provider.confirmPasswordController,
                            'Repetir Contraseña',
                            Icons.lock_outline,
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedItem(
                          delay: 350,
                          child: _buildDateField(context, provider),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedItem(
                          delay: 400,
                          child: _buildGenderAndRoleRow(provider),
                        ),
                        const SizedBox(height: 4),
                        if (provider.selectedRole == UserRole.employee) ...[
                          const SizedBox(height: 8),
                          _AnimatedItem(
                            delay: 450,
                            child: _buildTextField(
                              provider.nitController,
                              'NIT',
                              Icons.badge_outlined,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _AnimatedItem(
                            delay: 500,
                            child: provider.isLoadingCards
                                ? const Center(child: CircularProgressIndicator())
                                : _buildCardDropdown(provider),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _AnimatedItem(
                          delay: 450,
                          child: provider.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF007AFF),
                                  ),
                                )
                              : _buildRegisterButton(context, provider),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isKeyboardVisible) ...[
                  const SizedBox(height: 28),
                  _AnimatedItem(
                    delay: 500,
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey.shade200),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'O continúa con',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey.shade200),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _AnimatedItem(
                    delay: 550,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 25),
                        _buildGoogleButton(),
                        const SizedBox(width: 14),
                        _buildFacebookButton(),
                        const SizedBox(width: 25),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _AnimatedItem(
                  delay: 600,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground({required Widget child}) {
    return Container(
      child: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/dots-bg.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          Positioned(
            top: -37,
            right: 0,
            width: 180,
            height: 180,
            child: Lottie.asset(
              'assets/animations/right-top.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          Positioned(
            bottom: -37,
            left: 0,
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/animations/left-bottom.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          Container(
            color: const Color.fromARGB(212, 255, 255, 255).withValues(alpha: 0.88),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 30, color:  Colors.grey.shade900)),
        const SizedBox(height: 25),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color.fromARGB(134, 242, 239, 239),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Image.asset(
              'assets/logos/logus.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'MEDIDENT',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'I.P.S.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade400,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSelector(BuildContext context, RegisterProvider provider) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context, provider),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: provider.previewImageBytes != null
                ? MemoryImage(provider.previewImageBytes!)
                : null,
            child: provider.previewImageBytes == null
                ? Icon(Icons.camera, color: const Color.fromARGB(255, 226, 223, 223), size: 25)
                : null,
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromARGB(255, 101, 147, 192), width: 1.0),
            ),
            child: const Text(
              'Seleccionar una foto',
              style: TextStyle(
                color: Color.fromARGB(255, 61, 121, 180),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ),
    );
  }

  Widget _buildDateField(BuildContext context, RegisterProvider provider) {
    return TextField(
      controller: provider.birthDateController,
      decoration: _inputDecoration(
        label: 'Fecha de Nacimiento',
        icon: Icons.calendar_today_outlined,
      ),
      readOnly: true,
      onTap: () => _selectDate(context, provider),
    );
  }

  Widget _buildGenderAndRoleRow(RegisterProvider provider) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<UserGender>(
            value: provider.selectedGender,
            onChanged: (gender) => provider.setSelectedGender(gender),
            items: UserGender.values
                .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g.displayName),
                    ))
                .toList(),
            decoration: _inputDecoration(label: 'Género', icon: Icons.people_outline),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: provider.isAdminCheckLoading
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<UserRole>(
                  value: provider.selectedRole,
                  hint: const Text('Rol'),
                  onChanged: (role) => provider.setSelectedRole(role),
                  items: UserRole.values
                      .where((role) {
                        if (role == UserRole.admin) return provider.isAdminRoleAvailable;
                        return true;
                      })
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.displayName),
                          ))
                      .toList(),
                  decoration: _inputDecoration(label: 'Rol', icon: Icons.work_outline),
                ),
        ),
      ],
    );
  }

  Widget _buildCardDropdown(RegisterProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.selectedCardDisplay,
      hint: const Text('Selecciona una Tarjeta'),
      onChanged: (display) => provider.setSelectedCardCode(display),
      items: (provider.availableCards ?? [])
          .map((display) => DropdownMenuItem(value: display, child: Text(display)))
          .toList(),
      decoration: _inputDecoration(
        label: 'Selecciona una Tarjeta',
        icon: Icons.credit_card_outlined,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  Widget _buildRegisterButton(BuildContext context, RegisterProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: provider.isLoading
            ? null
            : () => _onRegisterPressed(context, provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Registrarme',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1C1C1E),
            backgroundColor: const Color.fromARGB(255, 251, 22, 22),
            side: const BorderSide(color: Color(0xFFDADCE0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Icon(
                    Icons.g_mobiledata,
                    size: 30,
                    color: Color.fromARGB(255, 238, 12, 23),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Google',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacebookButton() {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.facebook,
                  size: 30,
                  color: Color(0xFF1877F2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Facebook',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
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
            label: const Text('Galería'),
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
            label: const Text('Cámara'),
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
          content: Text('Se necesita permiso para usar la cámara.'),
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
    if (picked != null) provider.setSelectedBirthDate(picked);
  }

  Future<void> _onRegisterPressed(BuildContext context, RegisterProvider provider) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      provider.setLoading(true);

      final success = await provider.register();
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso!'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.popUntil((route) => route.isFirst);
      } else if (provider.errorMessage != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      provider.setLoading(false);
    }
  }
}

class _AnimatedItem extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedItem({required this.child, this.delay = 0});

  @override
  State<_AnimatedItem> createState() => _AnimatedItemState();
}

class _AnimatedItemState extends State<_AnimatedItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.delay == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _animation.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
