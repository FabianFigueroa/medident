import 'package:flutter/material.dart';
import 'package:medident/screens/role/dentist/profile/dentist-profile-mobile.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class DentistProfileScreen extends StatefulWidget {
  const DentistProfileScreen({super.key});

  @override
  State<DentistProfileScreen> createState() => _DentistProfileScreenState();
}

class _DentistProfileScreenState extends State<DentistProfileScreen> {
  final TrackingScrollController _scrollController = TrackingScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dentistMainProvider = context.read<DentistMainProvider>();
      await Future.wait([
        dentistMainProvider.initializeSection('profile'),
        dentistMainProvider.initializeSection('clinic'),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DentistMainProvider>(
      builder: (context, dentistMainProvider, child) {
        // ESTADO 1: La sección se está inicializando o el provider aún no se ha creado.
        if (dentistMainProvider.isSectionLoading('profile') || dentistMainProvider.profileProvider == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // ESTADO 2: Ocurrió un error durante la inicialización.
        final error = dentistMainProvider.getSectionError('profile');
        if (error != null) {
          return Scaffold(
            body: Center(child: Text('Error al cargar la sección de perfil: $error')),
          );
        }
        
        final clinicProvider = dentistMainProvider.clinicProvider;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dentistMainProvider.profileProvider!),
            if (clinicProvider != null)
              ChangeNotifierProvider.value(value: clinicProvider),
          ],
          child: ResponsiveUtils(
            mobile: DentistProfile_Mobile(
              scrollController: _scrollController,
            ),
            tablet: DentistProfile_Mobile(
              scrollController: _scrollController,
            ),
            desktop: DentistProfile_Mobile(
              scrollController: _scrollController,
              isDesktop: true,
            ),
          ),
        );
      },
    );
  }
}
