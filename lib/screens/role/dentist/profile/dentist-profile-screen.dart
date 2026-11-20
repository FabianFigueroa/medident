import 'package:flutter/material.dart';
import 'package:medident/screens/role/dentist/profile/dentist-profile-mobile.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class DentistProfileScreen extends StatefulWidget {
  final String? userId;
  const DentistProfileScreen({super.key, this.userId});

  @override
  State<DentistProfileScreen> createState() => _DentistProfileScreenState();
}

class _DentistProfileScreenState extends State<DentistProfileScreen> {
  final TrackingScrollController _scrollController = TrackingScrollController();
  DentistProfileProvider? _externalProvider;
  bool _loadingExternal = false;
  String? _externalError;

  @override
  void dispose() {
    _externalProvider?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUid = context.read<AuthenticateProvider>().user?.uid;
      if (widget.userId != null && widget.userId != currentUid) {
        setState(() => _loadingExternal = true);
        final provider = DentistProfileProvider(
          userId: widget.userId!,
          currentUserId: currentUid,
        );
        try {
          await provider.initialize();
          if (!mounted) return;
          setState(() {
            _externalProvider = provider;
            _loadingExternal = false;
          });
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _externalError = '$e';
            _loadingExternal = false;
          });
        }
        return;
      }
      final dentistMainProvider = context.read<DentistMainProvider>();
      await Future.wait([
        dentistMainProvider.initializeSection('profile'),
        dentistMainProvider.initializeSection('clinic'),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingExternal) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_externalError != null) {
      return Scaffold(body: Center(child: Text('Error al cargar perfil: $_externalError')));
    }
    if (_externalProvider != null) {
      return ChangeNotifierProvider.value(
        value: _externalProvider!,
        child: ResponsiveUtils(
          mobile: DentistProfile_Mobile(scrollController: _scrollController),
          tablet: DentistProfile_Mobile(scrollController: _scrollController),
          desktop: DentistProfile_Mobile(
            scrollController: _scrollController,
            isDesktop: true,
          ),
        ),
      );
    }

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
