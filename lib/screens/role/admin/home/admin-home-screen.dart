import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
      context.read<AdminMainProvider>().initializeSection('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_ADMIN_HOME',
      message: 'Entrando al home del rol admin.',
      role: 'admin',
      child: Selector<AdminMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('home'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Scaffold(
              body: _buildShimmer(),
            );
          }

          final mainProvider = context.watch<AdminMainProvider>();
          final error = mainProvider.getSectionError('home');

          if (error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error al cargar home: $error'),
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
            return Scaffold(
              body: _buildShimmer(),
            );
          }

          return ChangeNotifierProvider.value(
            value: homeProvider,
            child: ResponsiveUtils(
              mobile: AdminHomeMobileWidget(),
              tablet: AdminHomeTabletWidget(),
              desktop: AdminHomeDesktop(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 14, width: 120, color: Colors.white),
              const SizedBox(height: 12),
              Container(height: 200, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

