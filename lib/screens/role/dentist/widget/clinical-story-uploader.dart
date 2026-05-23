import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:medident/core/models/patient-model.dart';
import 'package:provider/provider.dart';

class ClinicalStoryUploader extends StatefulWidget {
  final List<PatientModel> patients;
  final String? preSelectedPatientId;

  const ClinicalStoryUploader({
    super.key,
    required this.patients,
    this.preSelectedPatientId,
  });

  @override
  State<ClinicalStoryUploader> createState() => _ClinicalStoryUploaderState();
}

class _ClinicalStoryUploaderState extends State<ClinicalStoryUploader> {
  final _picker = ImagePicker();
  File? _selectedImage;
  String? _selectedPatientId;
  String? _caption;
  bool _isUploading = false;
  bool _showPatientSelector = false;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.preSelectedPatientId;
  }

  PatientModel? get _selectedPatient {
    if (_selectedPatientId == null) return null;
    return widget.patients.firstWhere(
      (p) => p.id == _selectedPatientId,
      orElse: () => widget.patients.first,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _upload() async {
    if (_selectedImage == null || _selectedPatient == null) return;

    setState(() => _isUploading = true);

    try {
      final storage = FirebaseStorage.instance;
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = storage.ref(
        'clinical_stories/${_selectedPatient!.id}/$ts.jpg',
      );
      await ref.putFile(_selectedImage!);
      final imageUrl = await ref.getDownloadURL();

      if (!mounted) return;

      final patient = _selectedPatient!;
      await context.read<DentistHomeProvider>().createStory(
        imageUrl: imageUrl,
        text: _caption?.trim().isNotEmpty == true ? _caption!.trim() : null,
        sourceType: 'clinical',
        sourceId: patient.id,
        sourceName: patient.fullName,
        sourcePhoto: patient.photo,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Momento clínico agregado'),
            backgroundColor: Color(0xFF0EA5A4),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFF0EA5A4)),
                const SizedBox(width: 8),
                const Text(
                  'Nuevo Momento Clínico',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPatientSelector(),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 16),
                _buildCaptionInput(),
                const SizedBox(height: 20),
                _buildUploadButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSelector() {
    if (widget.patients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.amber),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No hay pacientes registrados. Agrega pacientes primero.',
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showPatientSelector = !_showPatientSelector,
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
              backgroundColor: const Color(0xFF0EA5A4).withOpacity(0.1),
              child: const Icon(Icons.person, size: 16, color: Color(0xFF0EA5A4)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedPatient?.fullName ?? 'Seleccionar paciente',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _selectedPatient != null ? const Color(0xFF0F172A) : Colors.grey[500],
                ),
              ),
            ),
            AnimatedRotation(
              turns: _showPatientSelector ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.file(
              _selectedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImage = null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _ImageSourceButton(
            icon: Icons.camera_alt_rounded,
            label: 'Cámara',
            color: const Color(0xFF0EA5A4),
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ImageSourceButton(
            icon: Icons.photo_library_rounded,
            label: 'Galería',
            color: const Color(0xFF3B82F6),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptionInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        onChanged: (v) => _caption = v,
        maxLines: 2,
        minLines: 1,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Describe el momento clínico (opcional)',
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    final canUpload = _selectedImage != null && _selectedPatient != null && !_isUploading;
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: canUpload ? _upload : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5A4),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isUploading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Publicar Momento Clínico',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
