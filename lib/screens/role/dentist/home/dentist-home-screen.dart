import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/core/utils/screen-trace.dart';
import 'package:medident/screens/role/dentist/home/dentist-home-mobile.dart';
import 'package:medident/screens/role/dentist/home/dentist-home-tablet.dart';
import 'package:medident/screens/role/dentist/home/dentist-home-desktop.dart';
import 'package:provider/provider.dart';

class DentistHomeScreen extends StatefulWidget {
  const DentistHomeScreen({super.key});

  @override
  State<DentistHomeScreen> createState() => _DentistHomeScreenState();
}

class _DentistHomeScreenState extends State<DentistHomeScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<DentistMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DentistMainProvider>().initializeSection('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DentistMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('home'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Scaffold(
              body: _buildScreenShimmer(),
            );
          }

          final mainProvider = context.watch<DentistMainProvider>();
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

          // Si el provider aún no está listo (primera vez), lo inicializamos
          if (homeProvider == null) {
            return Scaffold(
              body: _buildScreenShimmer(),
            );
          }

          final userId = mainProvider.userId;

          //:::::::::::::::::::::::::::::::::::: Datos listos — los pasamos a las vistas como parámetros limpios
          return ChangeNotifierProvider.value(
            value: homeProvider,
            child: ResponsiveUtils(
              mobile: DentistHomeMobile(userId: userId),
              tablet: DentistHomeTablet(userId: userId),
              desktop: DentistHomeDesktop(userId: userId),
            ),
          );
        },
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
