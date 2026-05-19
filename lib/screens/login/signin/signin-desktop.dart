import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class Signin_Desktop extends StatefulWidget {
  final TrackingScrollController trackingScrollController;
  //
  const Signin_Desktop.Signin_Desktop({super.key, required this.trackingScrollController});

  @override
  State<Signin_Desktop> createState() => _Signin_DesktopState();
}

class _Signin_DesktopState extends State<Signin_Desktop> {
  //
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SigninProvider>(context, listen: false).loadLastUser();
    });
  }

  ///
  @override
  void dispose() {
    // Limpiar recursos aqu�
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final provider = Provider.of<SigninProvider>(context, listen: false);
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contrase�a'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu correo electr�nico',
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
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
                backgroundColor: const Color.fromARGB(255, 238, 46, 33),
              ),
            );
          });
        }

        if (provider.lastUserEmail != null) {
          return _buildQuickLoginView(context, provider);
        } else {
          return _buildNormalLoginView(context, provider);
        }
      },
    );
  }

  Widget _buildQuickLoginView(BuildContext context, SigninProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hola de nuevo,',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            provider.lastUserName ?? '',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: CircleAvatar_Widget(
              imageUrl: provider.lastUserPhotoUrl,
              radius: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            provider.lastUserEmail ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: provider.passwordController,
            decoration: const InputDecoration(
              labelText: 'Contrase�a',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            autofocus: true,
          ),
          const SizedBox(height: 24),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildSignInButton(context, provider, 'Iniciar Sesi�n'),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => provider.clearLastUser(),
            child: const Text('Usar otra cuenta'),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalLoginView(BuildContext context, SigninProvider provider) {
    //final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      backgroundColor: AppColors.white,

      /////
      ////
      body: Row(
        children: [
          //////////////////////////////////////////////////////////////// left  MediaQuery.of(context).viewPadding.bottom -
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewPadding.top,
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              0,
              20,
            ), // Si est�s usando AppBar
            child: Image.asset('assets/images/post.png', fit: BoxFit.cover),
          ),

          ////////////////////////////////////////////////////////////////// right

          ////////////////////////////////////////////////////////////////////////////
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(1, 50, 1, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ///// image
                  Image.asset('assets/logos/logus.png', width: 80, height: 80),

                  /// txt
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Text(
                      'Medident',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                        fontSize: 40,
                        color: AppColors.grey800,
                      ),
                    ),
                  ),
                  ////
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 1, 40, 1),
                      child: Text(
                        'Bienvenido a la plataforma dental y m�dica de Medident. �Ingresa para gestionar tu consulta!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Ubuntu-Regular',
                          fontSize: 13,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  ///////////////////////////////////////////////// email
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 1, 40, 1),
                    child: TextField(
                      controller: provider.emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo: ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.grey700,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 10),
                  /////////////////////////////////////////////////////// pass
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 1, 40, 1),
                    child: TextField(
                      controller: provider.passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contrase�a: ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.grey700,
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 1, 40, 1),
                      child: TextButton(
                        onPressed: () => _showForgotPasswordDialog(context),
                        child: const Text('�Olvidaste tu contrase�a?'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 1, 40, 1),
                      child: _buildSignInButton(
                        context,
                        provider,
                        'Iniciar Sesi�n',
                      ),
                    ),
                  //////////
                  const SizedBox(height: 44),
                  ///////
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '�No tienes una cuenta?',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Ubuntu-Regular',
                          fontSize: 13,
                          color: AppColors.grey600,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-7, 0),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          ),
                          child: const Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Ubuntu-Regular',
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //////////
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ///
                      const Text("Ingresa con alguna de tus redes sociales..."),
                      //
                      const SizedBox(height: 20),

                      ///
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /////////////////////////////////////// btn google
                          Flexible(
                            flex: 1,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.login_outlined,
                                color: Colors.white,
                              ),
                              label: const Text('Google'),
                              onPressed: () {
                                // TODO: Handle Facebook Sign in
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFFC50606),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 19,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ////////////////////////////////////////// btn facebook
                          Flexible(
                            flex: 1,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.facebook,
                                color: Colors.white,
                              ),
                              label: const Text('Facebook'),
                              onPressed: () {
                                // TODO: Handle Facebook Sign in
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF1877F2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 19,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  /////////
                ],
              ),
            ),
          ),
        ],
      ),

      ///
    );
  }

  Widget _buildSignInButton(
    BuildContext context,
    SigninProvider provider,
    String text,
  ) {
    return ElevatedButton(
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
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                    (_) => false,
                  );
                }
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: provider.isFormValid
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade400,
        minimumSize: const Size(double.infinity, 37),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
