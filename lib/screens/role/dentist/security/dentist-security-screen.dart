import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/core/utils/screen-trace.dart';
import 'package:medident/screens/role/dentist/security/dentist-security-mobile.dart';
import 'package:medident/screens/role/dentist/security/dentist-security-tablet.dart';
import 'package:medident/screens/role/dentist/security/dentist-security-desktop.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';

class DentistSecurityScreen extends StatefulWidget {
  const DentistSecurityScreen({super.key});

  @override
  State<DentistSecurityScreen> createState() => _DentistSecurityScreenState();
}

class _DentistSecurityScreenState extends State<DentistSecurityScreen> {
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
      context.read<DentistMainProvider>().initializeSection('security');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DentistMainProvider, bool>(
      selector: (_, p) => p.isSectionLoading('security'),
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Scaffold(
            body: _AppleShimmer(),
          );
        }

        final mainProvider = context.watch<DentistMainProvider>();
        final error = mainProvider.getSectionError('security');

        if (error != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.shield_outlined, color: Color(0xFFFF3B30), size: 32),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Error de conexión',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF86868B)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => mainProvider.initializeSection('security'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final securityProvider = mainProvider.dentistSecurityProvider;

        if (securityProvider == null) {
          return const Scaffold(
            body: _AppleShimmer(),
          );
        }

        return ChangeNotifierProvider.value(
          value: securityProvider,
          child: ResponsiveUtils(
            mobile: const DentistSecurityMobile(),
            tablet: DentistSecurityTablet(scrollController: TrackingScrollController()),
            desktop: DentistSecurityDesktop(scrollController: TrackingScrollController()),
          ),
        );
      },
    );
  }
}

class _AppleShimmer extends StatelessWidget {
  const _AppleShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF5F5F7),
      highlightColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 200, height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 140, height: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity, height: 160,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
