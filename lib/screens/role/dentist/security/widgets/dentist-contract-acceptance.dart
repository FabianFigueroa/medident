// c:\Users\DELL\StudioProjects\medident\lib\screens\role\dentist\security\widgets\contract_acceptance_widget.dart
import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:provider/provider.dart';

class ContractAcceptanceWidget extends StatefulWidget {
  const ContractAcceptanceWidget({super.key});

  @override
  State<ContractAcceptanceWidget> createState() => _ContractAcceptanceWidgetState();
}

class _ContractAcceptanceWidgetState extends State<ContractAcceptanceWidget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Color primario inspirado en la imagen de referencia
  static const Color _primaryColor = Color.fromARGB(255, 212, 17, 10); // Un tono de teal/cyan

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor, // Color del encabezado del calendario
              onPrimary: Colors.white, // Color del texto en el encabezado
              onSurface: Colors.black, // Color del texto en el cuerpo del calendario
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _primaryColor), // Color de los botones
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  ////////////////////////////////////////////////////////////// hour-widget
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 26, 195, 144), // Color del encabezado del selector de hora
              onPrimary: Color.fromARGB(255, 255, 255, 255), // Color del texto en el encabezado
              onSurface: Colors.black, // Color del texto en el cuerpo del selector de hora
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 242, 245, 244)), // Color de los botones
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DentistSecurityProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido a la Seguridad Inteligente de Medident!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
          ),
          const SizedBox(height: 15),
          Text(
            'Para activar las funciones de seguridad IoT en tu clínica, es necesario aceptar nuestro contrato de servicio. Esto te permitirá gestionar sensores, tarjetas RFID y monitorear la seguridad en tiempo real.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 25),
          _buildSectionTitle(context, 'Beneficios Clave:'),
          _buildBenefitItem(context, 'Monitoreo en tiempo real de tus instalaciones.'),
          _buildBenefitItem(context, 'Gestión de acceso con tarjetas RFID para personal autorizado.'),
          _buildBenefitItem(context, 'Alertas instantáneas ante eventos de seguridad.'),
          _buildBenefitItem(context, 'Integración sencilla con tus dispositivos IoT.'),
          const SizedBox(height: 25),
          _buildSectionTitle(context, 'Términos de Uso:'),
          Text(
            'Al aceptar este contrato, usted se compromete a cumplir con las políticas de uso justo de la plataforma Medident, a mantener la confidencialidad de sus credenciales y a utilizar los servicios de seguridad de manera responsable. Medident se compromete a proteger sus datos y a proporcionar un servicio ininterrumpido en la medida de lo posible.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 25),
          _buildSectionTitle(context, 'Valor del Servicio:'),
          Text(
            'El costo mensual del servicio de seguridad IoT es de \$25.00 USD. Este monto será facturado automáticamente a su método de pago registrado. Puede cancelar el servicio en cualquier momento desde la configuración de su cuenta.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
          ),
          const SizedBox(height: 30),
          _buildSectionTitle(context, 'Programar Visita de Instalación:'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDate == null
                        ? 'Seleccionar Fecha'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    backgroundColor: _primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: _primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectTime(context),
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _selectedTime == null
                        ? 'Seleccionar Hora'
                        : _selectedTime!.format(context),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    backgroundColor: _primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: _primaryColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedDate != null && _selectedTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                'Visita programada para: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} a las ${_selectedTime!.format(context)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _primaryColor),
              ),
            ),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton.icon(
              onPressed: (_selectedDate != null && _selectedTime != null)
                  ? () async {
                      // Lógica para aceptar el contrato
                      // Aquí podrías pasar _selectedDate y _selectedTime al provider
                      await provider.acceptContract();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contrato aceptado y visita programada.')),
                      );
                    }
                  : null, // Deshabilitar botón si no se ha seleccionado fecha y hora
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aceptar Contrato y Activar Servicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Puede revisar los términos completos en la sección de ayuda.')),
                );
              },
              child: Text(
                'Rechazar o Más Información',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: _primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
