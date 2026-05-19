import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:medident/core/providers/clinic/clinic-provider.dart';
import 'package:medident/core/services/clinic-service.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/screens/role/dentist/clinic/dentist_clinic_mobile.dart';
import 'package:medident/screens/role/dentist/clinic/dentist_clinic_tablet.dart';
import 'package:medident/screens/role/dentist/clinic/dentist_clinic_desktop.dart';

class DentistClinicScreen extends StatefulWidget {
  const DentistClinicScreen({super.key});

  @override
  State<DentistClinicScreen> createState() => _DentistClinicScreenState();
}

class _DentistClinicScreenState extends State<DentistClinicScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<DentistMainProvider>();
    final userId = mainProvider.userId;
    if (userId.isEmpty || _initializedForUserId == userId) return;
    _initializedForUserId = userId;

    final user = context.read<AuthenticateProvider>().user;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (user?.clinicId != null && user!.clinicId!.isNotEmpty) {
        // Fast path: user.clinicId is cached — skip Firestore read,
        // show dashboard immediately, refresh full clinic data in background.
        final cp = ClinicProvider(service: ClinicService());
        cp.setCachedStatus(isOwner: user.isClinicOwner);
        mainProvider.registerSectionProvider('clinicStatus', cp);
        await cp.refreshFromClinicId(user.clinicId!, userId);
        if (!mounted) return;
        mainProvider.initializeSection('clinic');
      } else {
        // Slow path: new user — check Firestore for clinic status.
        await mainProvider.initializeSection('clinicStatus');
        if (!mounted) return;
        final cp = mainProvider.clinicStatusProvider;
        if (cp != null && (cp.status == ClinicStatus.owner || cp.status == ClinicStatus.employee)) {
          mainProvider.initializeSection('clinic');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DentistMainProvider, bool>(
      selector: (_, p) => p.isSectionLoading('clinicStatus'),
      builder: (context, isLoading, _) {
        if (isLoading) {
          return Scaffold(
            body: _buildScreenShimmer(),
          );
        }

        final mainProvider = context.watch<DentistMainProvider>();
        final error = mainProvider.getSectionError('clinicStatus');

        if (error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error al cargar clínica: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => mainProvider.initializeSection('clinicStatus'),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final clinicProvider = mainProvider.clinicStatusProvider;
        if (clinicProvider == null) {
          return Scaffold(
            body: _buildScreenShimmer(),
          );
        }

        return ChangeNotifierProvider.value(
          value: clinicProvider,
          child: const ResponsiveUtils(
            mobile: DentistClinicMobile(),
            tablet: DentistClinicTablet(),
            desktop: DentistClinicDesktop(),
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
              Container(
                height: 14,
                width: 120,
                color: Colors.white,
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
