import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';

class ClinicShimmer extends StatelessWidget {
  const ClinicShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class ClinicErrorWidget extends StatelessWidget {
  final String? error;
  const ClinicErrorWidget({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(error ?? 'Error desconocido'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.read<DentistMainProvider>()
              ..clearSection('clinicStatus')
              ..initializeSection('clinicStatus');
          },
          child: const Text('Reintentar'),
        ),
      ])),
    );
  }
}
