import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class Signin_Mobile extends StatefulWidget {
  final TrackingScrollController trackingScrollController;
  const Signin_Mobile({super.key, required this.trackingScrollController});

  @override
  State<Signin_Mobile> createState() => _Signin_MobileState();
}

class _Signin_MobileState extends State<Signin_Mobile>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SigninProvider>(context, listen: false).loadLastUser();
    });
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final provider = Provider.of<SigninProvider>(context, listen: false);
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Recuperar Contraseña'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu correo electrónico',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                final message = await provider.sendPasswordResetEmail(email);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SigninProvider>(
      builder: (context, provider, child) {
        if (provider.errorMessage != null && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          });
        }
        return provider.lastUserEmail != null
            ? _buildQuickLoginView(context, provider)
            : _buildNormalLogin_View(context, provider);
      },
    );
  }

  Widget _buildBackground({required Widget child}) {
    return Container(
      child: Stack(
        children: [

          //////////////////////////// dots
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/dots-bg.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          ///////////////////////////
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
          Container(color: const Color.fromARGB(212, 255, 255, 255).withValues(alpha: 0.88)),
          child,
        ],
      ),
    );
  }

  Widget _buildQuickLoginView(BuildContext context, SigninProvider provider) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            //padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _AnimatedItem(
                  delay: 0,
                  child: Text(
                    'Hola de nuevo,',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                _AnimatedItem(
                  delay: 100,
                  child: Text(
                    provider.lastUserName ?? '',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                _AnimatedItem(
                  delay: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar_Widget(
                      imageUrl: provider.lastUserPhotoUrl,
                      radius: 68,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _AnimatedItem(
                  delay: 300,
                  child: Text(
                    provider.lastUserEmail ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _AnimatedItem(
                  delay: 400,
                  child: _buildPasswordField(provider),
                ),
                const SizedBox(height: 28),
                _AnimatedItem(
                  delay: 500,
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF007AFF))
                      : _buildSignInButton(context, provider, 'Iniciar Sesión'),
                ),
                const SizedBox(height: 24),
                _AnimatedItem(
                  delay: 600,
                  child: TextButton(
                    onPressed: () => provider.clearLastUser(),
                    child: Text(
                      'Usar otra cuenta',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalLogin_View(BuildContext context, SigninProvider provider) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // const SizedBox(height: 40),
                _AnimatedItem(
                  delay: 0,
                  child: _buildLogoHeader(),
                ),
                // const SizedBox(height: 32),
                _AnimatedItem(
                  delay: 100,
                  child: Container(
                    padding: const EdgeInsets.all(28),
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
                        Text(
                          'Bienvenido',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ingresa tus datos para continuar.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildEmailField(provider),
                        const SizedBox(height: 14),
                        _buildPasswordField(provider),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showForgotPasswordDialog(context),
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        provider.isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF007AFF),
                                ),
                              )
                            : _buildSignInButton(
                                context,
                                provider,
                                'Iniciar Sesión',
                              ),
                      ],
                    ),
                  ),
                ),
                if (!isKeyboardVisible) ...[
                  const SizedBox(height: 28),
                  _AnimatedItem(
                    delay: 400,
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
                    delay: 500,
                    child: Row(
                      children: [
                        _buildGoogleButton(),
                        const SizedBox(width: 14),
                        _buildFacebookButton(),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 36),
                _AnimatedItem(
                  delay: 600,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        ),
                        child: const Text(
                          'Crear Cuenta',
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

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset(
              'assets/logos/logus.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'MEDIDENT',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'I.P.S.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade400,
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(SigninProvider provider) {
    return TextField(
      controller: provider.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(
        label: 'Correo electrónico',
        icon: Icons.email_outlined,
      ),
    );
  }

  Widget _buildPasswordField(SigninProvider provider) {
    return TextField(
      controller: provider.passwordController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration(
        label: 'Contraseña',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Widget _buildSignInButton(
    BuildContext context,
    SigninProvider provider,
    String text,
  ) {
    final isValid = provider.isFormValid;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: provider.isFormValid && !provider.isLoading
            ? () async {
                FocusScope.of(context).unfocus();
                final success = await provider.signInWithEmailAndPassword();
                if (success && context.mounted) {
                  final authGateProvider = Provider.of<AuthGateProvider?>(
                    context,
                    listen: false,
                  );
                  if (authGateProvider == null) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const AuthGate(),
                      ),
                      (_) => false,
                    );
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? const Color(0xFF007AFF) : Colors.grey.shade200,
          foregroundColor: isValid ? Colors.white : Colors.grey.shade400,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1C1C1E),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFDADCE0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'Google',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1C1C1E),
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
        height: 52,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.facebook,
                  size: 16,
                  color: Color(0xFF1877F2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Facebook',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
