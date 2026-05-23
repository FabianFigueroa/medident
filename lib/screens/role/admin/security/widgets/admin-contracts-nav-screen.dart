import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/screens/role/admin/security/widgets/admin-contracts-screen.dart';

class AdminContractsNavScreen extends StatefulWidget {
  const AdminContractsNavScreen({super.key});

  @override
  State<AdminContractsNavScreen> createState() => _AdminContractsNavScreenState();
}

class _AdminContractsNavScreenState extends State<AdminContractsNavScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<AdminMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminMainProvider>().initializeSection('contract');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().contractProvider;
    if (provider == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contratos'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: provider,
      child: const ScreenTrace(
        tag: 'ROLE_ADMIN_CONTRACTS',
        message: 'Gestión de contratos de seguridad IoT',
        role: 'admin',
        child: AdminContractsScreen(),
      ),
    );
  }
}
