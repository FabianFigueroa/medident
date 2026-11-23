import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

/// Home del empleado.
/// Antes construía EmployeeHomeMobile sin registrar el EmployeeHomeProvider
/// que ese widget lee, y la pantalla fallaba con ProviderNotFoundException.
/// Ahora inicializa la sección 'home' del EmployeeMainProvider y la expone,
/// igual que el home del paciente.
class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<EmployeeMainProvider>();
    final userId = mainProvider.userId;
    if (userId.isEmpty || _initializedForUserId == userId) return;
    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EmployeeMainProvider>().initializeSection('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.watch<EmployeeMainProvider>();
    final error = mainProvider.getSectionError('home');
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error al cargar el inicio: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => mainProvider.initializeSection('home'),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final homeProvider = mainProvider.homeProvider;
    if (homeProvider == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider<EmployeeHomeProvider>.value(
      value: homeProvider,
      child: const ScreenTrace(
        tag: 'ROLE_EMPLOYEE_HOME',
        message: 'Entrando al home del rol employee. Cargando panel operativo del empleado.',
        role: 'employee',
        child: ResponsiveUtils(
          mobile: EmployeeHomeMobile(),
          tablet: EmployeeHomeTablet(),
          desktop: EmployeeHomeDesktop(),
        ),
      ),
    );
  }
}
