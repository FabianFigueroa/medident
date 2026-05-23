import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/core/providers/doctor/doctor-main-provider.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/core/utils/screen-trace.dart';
import 'package:medident/screens/role/doctor/doctor-home-mobile.dart';
import 'package:provider/provider.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<DoctorMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DoctorMainProvider>().initializeSection('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_DOCTOR_HOME',
      message: 'Entrando al home del rol doctor. Cargando panel principal del medico.',
      role: 'doctor',
      child: Selector<DoctorMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('home'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Scaffold(
              body: _buildScreenShimmer(),
            );
          }

          final mainProvider = context.watch<DoctorMainProvider>();
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
              body: _buildScreenShimmer(),
            );
          }

          final userId = mainProvider.userId;

          return ChangeNotifierProvider.value(
            value: homeProvider,
            child: ResponsiveUtils(
              mobile: DoctorHomeMobile(userId: userId),
              tablet: DoctorHomeMobile(userId: userId),
              desktop: DoctorHomeMobile(userId: userId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenShimmer() {
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 14,
                    width: 120,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
