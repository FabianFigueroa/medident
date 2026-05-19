import 'package:flutter/material.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class AdminDeliveryScreen extends StatefulWidget {
  const AdminDeliveryScreen({super.key});
  @override
  State<AdminDeliveryScreen> createState() => _AdminDeliveryScreenState();
}

class _AdminDeliveryScreenState extends State<AdminDeliveryScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<AdminMainProvider>();
    final sectionLoading = mainProvider.isSectionLoading('delivery');
    if (!sectionLoading && mainProvider.getProvider('delivery') == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AdminMainProvider>().initializeSection('delivery');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_ADMIN_DELIVERY',
      message: 'Entrando a la pantalla de entregas del admin.',
      role: 'admin',
      child: Selector<AdminMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('delivery'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return const ResponsiveUtils(
            mobile: AdminDeliveryMobile(),
            tablet: AdminDeliveryTablet(),
            desktop: AdminDeliveryDesktop(),
          );
        },
      ),
    );
  }
}
