import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/screens/widgets/appbar/appbar-center.dart';
import 'package:provider/provider.dart';

class ContractAcceptance_Widget extends StatefulWidget {
  const ContractAcceptance_Widget({super.key});

  @override
  State<ContractAcceptance_Widget> createState() => _ContractAcceptance_WidgetState();
}

class _ContractAcceptance_WidgetState extends State<ContractAcceptance_Widget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _signatureKey = GlobalKey<_SignaturePadState>();
  bool _isLoading = false;

  static const _accent = Color(0xFF007AFF);
  static const _darkText = Color(0xFF1D1D1F);
  static const _mediumText = Color(0xFF86868B);
  static const _cardBg = Color(0xFFF5F5F7);

  Future<void> _selectDate() async {
    debugPrint('[ContractAcceptance] _selectDate() llamado');
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _accent,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _darkText,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _accent),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    debugPrint('[ContractAcceptance] _selectTime() llamado');
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _accent,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _darkText,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _accent),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _acceptContract() async {
    debugPrint('[ContractAcceptance] _acceptContract() iniciado');
    if (!_signatureKey.currentState!.hasSignature) {
      debugPrint('[ContractAcceptance] Firma no presente, mostrando error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor firma el contrato antes de aceptar')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      debugPrint('[ContractAcceptance] Fecha/hora no seleccionada');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora para la instalación')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      debugPrint('[ContractAcceptance] Llamando provider.acceptContract()');
      final provider = context.read<DentistSecurityProvider>();
      final sigBytes = _signatureKey.currentState?.getSignatureData();
      final sigBase64 = sigBytes != null ? base64Encode(sigBytes) : null;

      final userModel = context.read<AuthenticateProvider>().user;
      final dentistName = userModel?.fullName ?? '';
      final dentistEmail = userModel?.email ?? '';

      await provider.acceptContract(
        installationDate: _selectedDate!,
        installationTime: _selectedTime!,
        dentistName: dentistName,
        dentistEmail: dentistEmail,
        signatureBase64: sigBase64,
      );
      debugPrint('[ContractAcceptance] provider.acceptContract() completado');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada. Esperá la aprobación del administrador.'),
            backgroundColor: Color(0xFF007AFF),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e, stack) {
      debugPrint('[ContractAcceptance] Error en aceptar contrato: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          //padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Appbar_Center_Widget(
                titleWidget: Text(
                  'Seguridad IoT', 
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Colors.white
                    )),
                backgroundColor: const ui.Color.fromARGB(255, 6, 199, 196),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  '- Contrato de Seguridad IoT',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  'Activá las funciones de seguridad inteligente para tu clínica. Monitoreo en tiempo real, control de acceso RFID y alertas automáticas.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: _mediumText,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Benefits
              _sectionTitle('Beneficios'),
              const SizedBox(height: 12),
              _benefitRow(Icons.sensors_outlined, 'Monitoreo en tiempo real de tus instalaciones'),
              _benefitRow(Icons.credit_card_outlined, 'Gestión de acceso con tarjetas RFID'),
              _benefitRow(Icons.notifications_outlined, 'Alertas instantáneas ante eventos'),
              _benefitRow(Icons.devices_outlined, 'Integración con dispositivos IoT'),
              const SizedBox(height: 28),

              // Pricing
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.card_giftcard_outlined, color: Color(0xFF34C759), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Primer mes gratis',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _darkText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Después \$10.000 COP/mes',
                                  style: TextStyle(fontSize: 13, color: _mediumText),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'GRATIS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF34C759),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9500).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.build_outlined, color: Color(0xFFFF9500), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Instalación única',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _darkText,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Incluye dispositivos y configuración ',
                                  style: TextStyle(fontSize: 13, color: _mediumText),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '\$120.000 COP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _darkText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Schedule installation
              _sectionTitle('Programar instalación'),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                children: [
                  Expanded(
                    child: _outlinedButton(
                      icon: Icons.calendar_today_outlined,
                      label: _selectedDate == null
                          ? 'Fecha'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _outlinedButton(
                      icon: Icons.access_time_outlined,
                      label: _selectedTime == null
                          ? 'Hora'
                          : _selectedTime!.format(context),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              ),
              if (_selectedDate != null && _selectedTime != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Visita: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} a las ${_selectedTime!.format(context)}',
                  style: const TextStyle(fontSize: 13, color: _accent, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 28),

              // Terms
              _sectionTitle('Términos del servicio'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Al aceptar, autorizás a Medident a instalar y configurar los dispositivos de seguridad IoT en tu clínica. Tus datos están protegidos bajo nuestros estándares de seguridad. Podés cancelar en cualquier momento desde la configuración.',
                  style: TextStyle(fontSize: 14, color: _mediumText, height: 1.5),
                ),
              ),
              const SizedBox(height: 28),

              // Signature
              _sectionTitle('Firma digital'),
              const SizedBox(height: 12),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    SignaturePad(key: _signatureKey),
                    if (!(_signatureKey.currentState?.hasSignature ?? false))
                      const Center(
                        child: Text(
                          'Firmá aquí',
                          style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 16),
                        ),
                      ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () => _signatureKey.currentState?.clear(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.refresh, size: 18, color: _mediumText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Accept button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedDate != null && _selectedTime != null && !_isLoading)
                      ? _acceptContract
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E5EA),
                    disabledForegroundColor: const Color(0xFFC7C7CC),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Aceptar y Activar',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Podés revisar los términos en la sección de ayuda')),
                    );
                  },
                  child: const Text(
                    'Más información',
                    style: TextStyle(color: _mediumText, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _darkText,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check, color: Color(0xFF34C759), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: _darkText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E5EA)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: _darkText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Signature Pad ────────────────────────────────────────────────────────────

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  bool get hasSignature => _strokes.isNotEmpty;

  void clear() {
    debugPrint('[SignaturePad] clear()');
    setState(() {
      _strokes = [];
      _currentStroke = [];
    });
  }

  Uint8List? getSignatureData() {
    debugPrint('[SignaturePad] getSignatureData()');
    if (_strokes.isEmpty) return null;
    final list = _strokes
        .map((s) => s.map((o) => {'x': o.dx, 'y': o.dy}).toList())
        .toList();
    return base64Decode(base64Encode(utf8.encode(list.toString())));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        debugPrint('[SignaturePad] onPanStart: ${details.localPosition}');
        setState(() {
          _currentStroke = [details.localPosition];
          _strokes.add(_currentStroke);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _currentStroke.add(details.localPosition);
        });
      },
      onPanEnd: (_) {
        debugPrint('[SignaturePad] onPanEnd - total strokes: ${_strokes.length}');
        _currentStroke = [];
      },
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) => CustomPaint(
            painter: _SignaturePainter(_strokes),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D1D1F)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter old) => true;
}
