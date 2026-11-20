import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import 'package:medident/main_export.dart';
import 'package:medident/screens/role/dentist/clinic/onboarding/create-clinic-screen.dart';
import 'package:medident/screens/role/dentist/clinic/onboarding/join-clinic-screen.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/dentist_clinic_dashboard.dart';

class ClinicConnectScreen extends StatelessWidget {
  final String userId;
  final DentistClinicProvider clinicProvider;

  const ClinicConnectScreen({
    super.key,
    required this.userId,
    required this.clinicProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Si el usuario ya está vinculado a una clínica, la sección muestra la
    // clínica como identidad propia (Regla de Oro 1). Solo si aún no tiene
    // clínica se ofrece crear o unirse escaneando QR / ingresando código.
    return ListenableBuilder(
      listenable: clinicProvider,
      builder: (context, _) {
        if (clinicProvider.clinic != null) {
          return ChangeNotifierProvider.value(
            value: clinicProvider,
            child: const DentistClinic_Dashboard(),
          );
        }
        return _buildConnect(context);
      },
    );
  }

  Widget _buildConnect(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mi Clinica',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildOptionCard(
              context,
              icon: HugeIcons.strokeRoundedHospital01,
              title: 'Crear mi clinica',
              description:
                  'Soy el propietario. Crea la clinica y administra doctores, empleados y pacientes.',
              color: AppColors.primary,
              onTap: () => _openCreate(context),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              icon: HugeIcons.strokeRoundedUserGroup,
              title: 'Unirme con codigo',
              description:
                  'Ya trabajo en una clinica. Ingresa el codigo o escanea el QR para vincularme.',
              color: Colors.green,
              onTap: () => _openJoin(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required dynamic icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: HugeIcon(icon: icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey600),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: clinicProvider,
          child: CreateClinicScreen(userId: userId, onCreated: () {}),
        ),
      ),
    );
  }

  void _openJoin(BuildContext context) {
    final rootNavigator = Navigator.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: clinicProvider,
          child: JoinClinicScreen(
            userId: userId,
            onJoined: () {
              rootNavigator.popUntil((route) => route.isFirst);
            },
          ),
        ),
      ),
    );
  }
}
