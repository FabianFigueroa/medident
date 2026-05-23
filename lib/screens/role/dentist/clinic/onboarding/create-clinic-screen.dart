import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';


class CreateClinicScreen extends StatefulWidget {
  const CreateClinicScreen({super.key});

  @override
  State<CreateClinicScreen> createState() => _CreateClinicScreenState();
}

class _CreateClinicScreenState extends State<CreateClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();
  final _tiktokCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String? _logoPath;
  bool _isLoading = false;
  String? _errorMsg;

  final List<String> _weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final Set<String> _selectedDays = {'Lun', 'Mar', 'Mié', 'Jue', 'Vie'};
  final Map<String, TimeOfDay> _openTimes = {};
  final Map<String, TimeOfDay> _closeTimes = {};

  @override
  void initState() {
    super.initState();
    for (final day in _weekDays) {
      _openTimes[day] = const TimeOfDay(hour: 8, minute: 0);
      _closeTimes[day] = const TimeOfDay(hour: 18, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nitCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _tiktokCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Crear Clínica', style: TextStyle(fontFamily: 'Ubuntu-Bold')),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Logo de la clínica'),
              const SizedBox(height: 12),
              _buildLogoPicker(),
              const SizedBox(height: 28),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMsg!, style: TextStyle(color: Colors.red[700], fontSize: 13)),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _errorMsg = null),
                          child: Icon(Icons.close, size: 18, color: Colors.red[300]),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildSectionTitle('Información general'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameCtrl,
                label: 'Nombre de la clínica *',
                icon: Icons.business,
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _nitCtrl,
                label: 'NIT *',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _addressCtrl,
                label: 'Dirección',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneCtrl,
                      label: 'Teléfono',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _buildSectionTitle('Presencia online'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _websiteCtrl,
                label: 'Sitio web',
                icon: Icons.language,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _instagramCtrl,
                label: 'Instagram',
                icon: Icons.camera_alt,
                prefixText: '@',
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _facebookCtrl,
                label: 'Facebook',
                icon: Icons.thumb_up,
                prefixText: '@',
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _tiktokCtrl,
                label: 'TikTok',
                icon: Icons.music_note,
                prefixText: '@',
              ),
              const SizedBox(height: 28),
              _buildSectionTitle('Horario de atención'),
              const SizedBox(height: 12),
              _buildBusinessHoursSelector(),
              const SizedBox(height: 28),
              _buildSectionTitle('Descripción'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descriptionCtrl,
                label: 'Descripción de la clínica',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF1a73e8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            'Crear Clínica',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Ubuntu-Bold',
        color: AppColors.black,
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.primary),
        const SizedBox(height: 4),
        Text('Logo', style: TextStyle(fontSize: 11, color: AppColors.grey600)),
      ],
    );
  }

  Widget _buildLogoPicker() {
    return GestureDetector(
      onTap: _pickLogo,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _logoPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: kIsWeb
                    ? Image.network(_logoPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildLogoPlaceholder())
                    : Image.file(File(_logoPath!), fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.primary),
                  const SizedBox(height: 4),
                  Text(
                    'Logo',
                    style: TextStyle(fontSize: 11, color: AppColors.grey600),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (picked != null) {
      setState(() => _logoPath = picked.path);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.grey500),
          prefixText: prefixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(color: AppColors.grey500, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBusinessHoursSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weekDays.map((day) {
              final selected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.grey700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedDays.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ..._selectedDays.map((day) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(day, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTimeChip(
                      time: _openTimes[day]!,
                      onTap: () => _pickTime(day, isOpen: true),
                      label: 'Abre',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('-', style: TextStyle(color: AppColors.grey500)),
                  ),
                  Expanded(
                    child: _buildTimeChip(
                      time: _closeTimes[day]!,
                      onTap: () => _pickTime(day, isOpen: false),
                      label: 'Cierra',
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeChip({
    required TimeOfDay time,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(String day, {required bool isOpen}) async {
    final current = isOpen ? _openTimes[day]! : _closeTimes[day]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          _openTimes[day] = picked;
        } else {
          _closeTimes[day] = picked;
        }
      });
    }
  }

  Future<void> _onSubmit() async {
    debugPrint('[CREATE_CLINIC] _onSubmit iniciado');

    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('[CREATE_CLINIC] Validación del formulario falló');
      return;
    }
    debugPrint('[CREATE_CLINIC] Validación OK');

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final cp = context.read<DentistClinicProvider>();
      debugPrint('[CREATE_CLINIC] DentistClinicProvider obtenido: ${cp.hashCode}');

      final main = context.read<DentistMainProvider>();
      debugPrint('[CREATE_CLINIC] DentistMainProvider obtenido');
      debugPrint('[CREATE_CLINIC] userId: ${main.userId}');

      if (main.userId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Error de sesión: no se pudo identificar al usuario.';
        });
        debugPrint('[CREATE_CLINIC] userId vacío');
        return;
      }

      Map<String, String>? socialMedia;
      final ig = _instagramCtrl.text.trim();
      final fb = _facebookCtrl.text.trim();
      final tt = _tiktokCtrl.text.trim();
      if (ig.isNotEmpty || fb.isNotEmpty || tt.isNotEmpty) {
        socialMedia = {};
        if (ig.isNotEmpty) socialMedia['instagram'] = ig;
        if (fb.isNotEmpty) socialMedia['facebook'] = fb;
        if (tt.isNotEmpty) socialMedia['tiktok'] = tt;
      }

      Map<String, Map<String, String>>? businessHours;
      if (_selectedDays.isNotEmpty) {
        businessHours = {};
        for (final day in _selectedDays) {
          businessHours[day] = {
            'open': '${_openTimes[day]!.hour.toString().padLeft(2, '0')}:${_openTimes[day]!.minute.toString().padLeft(2, '0')}',
            'close': '${_closeTimes[day]!.hour.toString().padLeft(2, '0')}:${_closeTimes[day]!.minute.toString().padLeft(2, '0')}',
          };
        }
      }

      debugPrint('[CREATE_CLINIC] Llamando cp.createClinic()...');
      final success = await cp.createClinic(
        name: _nameCtrl.text.trim(),
        ownerId: main.userId,
        nit: _nitCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        website: _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
        socialMedia: socialMedia,
        businessHours: businessHours,
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        logoUrl: null,
      );
      debugPrint('[CREATE_CLINIC] createClinic() retornó: $success');
      debugPrint('[CREATE_CLINIC] cp.error: ${cp.error}');
      debugPrint('[CREATE_CLINIC] cp.status: ${cp.status}');

      setState(() => _isLoading = false);

      if (success && mounted) {
        debugPrint('[CREATE_CLINIC] Éxito — inicializando seccion clinic');
        main.initializeSection('clinic');
        if (mounted) {
          debugPrint('[CREATE_CLINIC] Haciendo pop al dashboard');
          Navigator.pop(context);
        }
      } else if (mounted) {
        final errorMsg = cp.error ?? 'Error al crear la clínica. Verifica los datos e intenta de nuevo.';
        debugPrint('[CREATE_CLINIC] Fallo — mostrando error: $errorMsg');
        setState(() {
          _errorMsg = errorMsg;
        });
      }
    } catch (e, stack) {
      debugPrint('[CREATE_CLINIC] EXCEPCIÓN NO CAPTURADA: $e');
      debugPrint('[CREATE_CLINIC] Stack: $stack');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Error inesperado: $e';
        });
      }
    }
  }
}
