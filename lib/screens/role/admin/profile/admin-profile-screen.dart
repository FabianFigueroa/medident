import 'package:flutter/material.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});
  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<AdminMainProvider>();
    final sectionLoading = mainProvider.isSectionLoading('profile');
    if (!sectionLoading && mainProvider.getProvider('profile') == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AdminMainProvider>().initializeSection('profile');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_ADMIN_PROFILE',
      message: 'Entrando a la pantalla de perfil del admin.',
      role: 'admin',
      child: Selector<AdminMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('profile'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return const ResponsiveUtils(
            mobile: AdminProfileMobile(),
            tablet: AdminProfileTablet(),
            desktop: AdminProfileDesktop(),
          );
        },
      ),
    );
  }
}
