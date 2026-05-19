import 'package:flutter/material.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class AdminShopsScreen extends StatefulWidget {
  const AdminShopsScreen({super.key});
  @override
  State<AdminShopsScreen> createState() => _AdminShopsScreenState();
}

class _AdminShopsScreenState extends State<AdminShopsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<AdminMainProvider>();
    final sectionLoading = mainProvider.isSectionLoading('shops');
    if (!sectionLoading && mainProvider.getProvider('shops') == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AdminMainProvider>().initializeSection('shops');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_ADMIN_SHOPS',
      message: 'Entrando a la pantalla de tiendas del admin.',
      role: 'admin',
      child: Selector<AdminMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('shops'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return const ResponsiveUtils(
            mobile: AdminShopsMobile(),
            tablet: AdminShopsTablet(),
            desktop: AdminShopsDesktop(),
          );
        },
      ),
    );
  }
}
