import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/dentist/clinic/onboarding/create-clinic-screen.dart';
import 'package:medident/screens/role/dentist/clinic/onboarding/join-clinic-screen.dart';

class ClinicOnboardingScreen extends StatefulWidget {
  const ClinicOnboardingScreen({super.key});

  @override
  State<ClinicOnboardingScreen> createState() => _ClinicOnboardingScreenState();
}

class _ClinicOnboardingScreenState extends State<ClinicOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFF6F7F9),
              Color(0xFFF6F7F9),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildRoleCard(
                      icon: HugeIcons.strokeRoundedHospital01,
                      title: 'Soy Propietario',
                      description: 'Crea y administra tu propia clínica dental.\nControl total sobre tu negocio.',
                      color: AppColors.primary,
                      onTap: () => _navigateToCreate(context),
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      icon: HugeIcons.strokeRoundedUserGroup,
                      title: 'Soy Empleado',
                      description: 'Únete a una clínica existente con el código\n o escaneando el QR.',
                      color: Colors.green,
                      onTap: () => _navigateToJoin(context),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.6),
                const Color(0xFF1a73e8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedHospital01,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tu Clínica Dental',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu-Bold',
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Selecciona tu tipo de perfil para continuar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.grey600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required dynamic icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: HugeIcon(
                icon: icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Ubuntu-Bold',
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    debugPrint('[ONBOARDING] _navigateToCreate');
    try {
      final main = context.read<DentistMainProvider>();
      final cp = context.read<ClinicProvider>();
      debugPrint('[ONBOARDING] Providers ok — status: ${cp.status}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: main),
              ChangeNotifierProvider.value(value: cp),
            ],
            child: const CreateClinicScreen(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[ONBOARDING] ERROR al obtener providers: $e');
    }
  }

  void _navigateToJoin(BuildContext context) {
    debugPrint('[ONBOARDING] _navigateToJoin');
    try {
      final main = context.read<DentistMainProvider>();
      final cp = context.read<ClinicProvider>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: main),
              ChangeNotifierProvider.value(value: cp),
            ],
            child: const JoinClinicScreen(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[ONBOARDING] ERROR al obtener providers: $e');
    }
  }
}
