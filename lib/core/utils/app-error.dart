import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Pantalla de error profesional con opciones de recuperación
class ErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final bool isCritical;
  
  const ErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
    this.isCritical = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildMessage(),
                  const SizedBox(height: 32),
                  _buildRetryButton(),
                  if (isCritical) ...[
                    const SizedBox(height: 16),
                    _buildExitButton(context),
                  ],
                  if (error.toString().contains('firebase') && !isCritical) ...[
                    const SizedBox(height: 32),
                    _buildTechnicalDetails(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCritical ? Icons.error_outline : Icons.cloud_off_rounded,
        size: 80,
        color: isCritical ? Colors.red.shade700 : Colors.blue.shade700,
      ),
    );
  }
  
  Widget _buildTitle() {
    return Text(
      isCritical ? 'Error Crítico' : 'Error de Conexión',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
  
  Widget _buildMessage() {
    return Text(
      isCritical 
          ? 'La aplicación no pudo iniciar correctamente.\nPor favor, contacta al soporte técnico.'
          : 'No se pudo establecer conexión con los servidores.\nVerifica tu conexión a internet y reintenta.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
        height: 1.4,
      ),
    );
  }
  
  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: const Text('Reintentar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(200, 48),
      ),
    );
  }
  
  Widget _buildExitButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        if (kIsWeb) {
          // En web, abrir documentación o mostrar diálogo
          _showWebInstructionsDialog(context);
        } else {
          // En móvil/desktop, salir de la app
          // ignore: deprecated_member_use
          SystemNavigator.pop();
        }
      },
      icon: const Icon(Icons.help_outline),
      label: const Text('Ayuda'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  void _showWebInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instrucciones'),
        content: const Text(
          'Si el problema persiste después de reintentar:\n\n'
          '1. Limpia la caché del navegador\n'
          '2. Recarga la página presionando F5\n'
          '3. Verifica que tu conexión a internet esté activa',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTechnicalDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Detalles técnicos:\n${error.toString().split('\n').first}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade500,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
