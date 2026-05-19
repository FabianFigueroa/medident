import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:medident/core/services/dentist/dentist-home-services.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/dentist/widget/appointments-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/turnos-one-widget.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  bool _showAgenda = true;
  DentistHomeProvider? _provider;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final authProvider = context.read<AuthenticateProvider>();
      final userId = authProvider.user?.uid ?? '';
      if (userId.isNotEmpty) {
        final service = DentistHomeService();
        final provider = DentistHomeProvider(service: service, userId: userId);
        _provider = provider;
        provider.loadAppointments();
        provider.loadTurnos();
      }
    }
  }

  @override
  void dispose() {
    _provider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_EMPLOYEE_PROFILE',
      message: 'Entrando a la pantalla de perfil del empleado.',
      role: 'employee',
      child: Scaffold(
        body: _provider == null
            ? const Center(child: CircularProgressIndicator())
            : ChangeNotifierProvider.value(
                value: _provider!,
                child: _buildContent(),
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildToggleRow(),
        const SizedBox(height: 8),
        Expanded(
          child: Consumer<DentistHomeProvider>(
            builder: (context, provider, _) {
              if (_showAgenda) {
                return Appointments_One_Widget(
                  appointments: provider.appointments,
                  isLoading: provider.isLoading,
                );
              } else {
                return const TurnosOneWidget();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showAgenda = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _showAgenda ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _showAgenda
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: const Center(
                    child: Text(
                      'Agenda',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Ubuntu-Medium',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showAgenda = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_showAgenda ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: !_showAgenda
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: const Center(
                    child: Text(
                      'Turnos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Ubuntu-Medium',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
