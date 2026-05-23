import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medident/core/models/treatment-confession-model.dart';
import 'package:medident/core/models/patient-model.dart';
import 'package:medident/core/providers/treatment-confession-provider.dart';
import 'package:provider/provider.dart';

class TreatmentConfessionUploader extends StatefulWidget {
  final String clinicId;
  final String userId;
  final List<PatientModel> patients;

  const TreatmentConfessionUploader({
    super.key,
    required this.clinicId,
    required this.userId,
    required this.patients,
  });

  @override
  State<TreatmentConfessionUploader> createState() =>
      _TreatmentConfessionUploaderState();
}

class _TreatmentConfessionUploaderState
    extends State<TreatmentConfessionUploader> {
  final _picker = ImagePicker();
  final _descCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();

  File? _videoFile;
  File? _beforeFile;
  File? _afterFile;
  PatientModel? _selectedPatient;
  double _rating = 5.0;
  bool _isUploading = false;
  bool _showPatientDropdown = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _treatmentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (picked != null) {
      setState(() => _videoFile = File(picked.path));
    }
  }

  Future<void> _pickPhoto(ImageSource source, bool isBefore) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        if (isBefore) {
          _beforeFile = File(picked.path);
        } else {
          _afterFile = File(picked.path);
        }
      });
    }
  }

  Future<void> _upload() async {
    if (_videoFile == null || _selectedPatient == null) return;

    setState(() => _isUploading = true);

    try {
      final storage = FirebaseStorage.instance;
      final ts = DateTime.now().millisecondsSinceEpoch;
      final pid = _selectedPatient!.id;
      final treatmentName = _treatmentCtrl.text.trim().isNotEmpty
          ? _treatmentCtrl.text.trim()
          : 'Tratamiento dental';

      final videoRef = storage.ref('treatment_confessions/$pid/video_$ts.mp4');
      await videoRef.putFile(_videoFile!);
      final videoUrl = await videoRef.getDownloadURL();

      String? beforeUrl;
      if (_beforeFile != null) {
        final beforeRef =
            storage.ref('treatment_confessions/$pid/before_$ts.jpg');
        await beforeRef.putFile(_beforeFile!);
        beforeUrl = await beforeRef.getDownloadURL();
      }

      String? afterUrl;
      if (_afterFile != null) {
        final afterRef =
            storage.ref('treatment_confessions/$pid/after_$ts.jpg');
        await afterRef.putFile(_afterFile!);
        afterUrl = await afterRef.getDownloadURL();
      }

      if (!mounted) return;

      final confession = TreatmentConfessionModel(
        id: '',
        clinicId: widget.clinicId,
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.fullName,
        patientPhoto: _selectedPatient!.photo,
        treatmentName: treatmentName,
        videoUrl: videoUrl,
        beforePhoto: beforeUrl,
        afterPhoto: afterUrl,
        description: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : null,
        rating: _rating,
        createdBy: widget.userId,
        createdAt: DateTime.now(),
      );

      await context
          .read<TreatmentConfessionProvider>()
          .create(confession);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Testimonio agregado correctamente'),
            backgroundColor: Color(0xFF7C3AED),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.star_rate_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Nuevo Testimonio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPatientSelector(),
                  const SizedBox(height: 14),
                  _buildTreatmentField(),
                  const SizedBox(height: 14),
                  _buildVideoPicker(),
                  const SizedBox(height: 12),
                  _buildBeforeAfter(),
                  const SizedBox(height: 14),
                  _buildDescription(),
                  const SizedBox(height: 14),
                  _buildRatingSelector(),
                  const SizedBox(height: 20),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSelector() {
    return GestureDetector(
      onTap: () => setState(() => _showPatientDropdown = !_showPatientDropdown),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
              child: const Icon(Icons.person, size: 16, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedPatient?.fullName ?? 'Seleccionar paciente',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _selectedPatient != null
                      ? const Color(0xFF0F172A)
                      : Colors.grey[500],
                ),
              ),
            ),
            AnimatedRotation(
              turns: _showPatientDropdown ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child:
                  Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _treatmentCtrl,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Tratamiento (ej: Blanqueamiento, Implante...)',
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          prefixIcon: const Icon(Icons.medical_services_outlined,
              size: 18, color: Color(0xFF7C3AED)),
        ),
      ),
    );
  }

  Widget _buildVideoPicker() {
    if (_videoFile != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF7C3AED).withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.videocam, color: Color(0xFF7C3AED), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video seleccionado',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Listo para subir',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _videoFile = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF7C3AED).withOpacity(0.15),
              style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.videocam_rounded, size: 36, color: const Color(0xFF7C3AED).withOpacity(0.5)),
            const SizedBox(height: 8),
            const Text(
              'Toca para seleccionar video',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Máximo 60 segundos',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeAfter() {
    return Row(
      children: [
        Expanded(
          child: _PhotoSlot(
            label: 'Antes',
            icon: Icons.brightness_1_outlined,
            file: _beforeFile,
            color: const Color(0xFFF59E0B),
            onPick: () => _pickPhoto(ImageSource.gallery, true),
            onClear: () => setState(() => _beforeFile = null),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PhotoSlot(
            label: 'Después',
            icon: Icons.brightness_1,
            file: _afterFile,
            color: const Color(0xFF10B981),
            onPick: () => _pickPhoto(ImageSource.gallery, false),
            onClear: () => setState(() => _afterFile = null),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _descCtrl,
        maxLines: 3,
        minLines: 2,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: '¿Qué dice el paciente sobre su experiencia?',
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Satisfacción del paciente',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final starValue = i + 1;
            final filled = starValue <= _rating.round();
            return GestureDetector(
              onTap: () => setState(() => _rating = starValue.toDouble()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedScale(
                  scale: filled ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    filled
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36,
                    color: filled
                        ? const Color(0xFFF59E0B)
                        : Colors.grey[300],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit =
        _videoFile != null && _selectedPatient != null && !_isUploading;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: canSubmit ? _upload : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isUploading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Publicar Testimonio',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String label;
  final IconData icon;
  final File? file;
  final Color color;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _PhotoSlot({
    required this.label,
    required this.icon,
    this.file,
    required this.color,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              file!,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color.withOpacity(0.5)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
