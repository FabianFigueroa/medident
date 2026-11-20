import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:path/path.dart' as path;

class CreateStoryScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserPhoto;
  final DentistHomeProvider provider;

  const CreateStoryScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserPhoto,
    required this.provider,
  });

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  static const _accent = Color(0xFF4F46E5);

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();

  XFile? _file;
  Uint8List? _bytes;
  bool _isVideo = false;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool _looksLikeVideo(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.avi');
  }

  Future<void> _handlePicked(XFile? file) async {
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _file = file;
        _bytes = bytes;
        _isVideo = _looksLikeVideo(file.name) ||
            _looksLikeVideo(file.path) ||
            (file.mimeType?.startsWith('video/') ?? false);
        _uploadProgress = 0;
      });
    } catch (e) {
      _showError('No se pudo leer el archivo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 2160,
        maxHeight: 3840,
      );
      await _handlePicked(file);
    } catch (e) {
      _showError('Error al abrir la galería: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
      await _handlePicked(file);
    } catch (e) {
      _showError('Error al abrir la galería de videos: $e');
    }
  }

  Future<void> _takePhoto({CameraDevice device = CameraDevice.rear}) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: device,
        imageQuality: 88,
      );
      await _handlePicked(file);
    } catch (e) {
      _showError('No se pudo abrir la cámara: $e');
    }
  }

  void _clearMedia() {
    setState(() {
      _file = null;
      _bytes = null;
      _isVideo = false;
      _uploadProgress = 0;
    });
  }

  Future<String?> _upload() async {
    final file = _file;
    final bytes = _bytes;
    if (file == null || bytes == null) return null;

    final ext = path.extension(file.name).isNotEmpty
        ? path.extension(file.name)
        : (_isVideo ? '.mp4' : '.jpg');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final ref = firebase_storage.FirebaseStorage.instance
        .ref('stories/${widget.currentUserId}/$fileName');

    final task = ref.putData(
      bytes,
      firebase_storage.SettableMetadata(
        contentType: _isVideo ? 'video/mp4' : 'image/jpeg',
      ),
    );
    task.snapshotEvents.listen((snapshot) {
      final total = snapshot.totalBytes;
      if (total > 0 && mounted) {
        setState(() => _uploadProgress = snapshot.bytesTransferred / total);
      }
    });
    final snapshot = await task;
    return snapshot.ref.getDownloadURL();
  }

  Future<void> _publishStory() async {
    if (_file == null || _bytes == null) {
      _showError('Selecciona una foto o un video');
      return;
    }
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final downloadUrl = await _upload();
      if (downloadUrl == null) {
        throw Exception('No se pudo subir el archivo');
      }
      final caption = _textController.text.trim();
      await widget.provider.createStory(
        imageUrl: downloadUrl,
        text: caption.isEmpty ? null : caption,
      );
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Historia publicada')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        _showError('No se pudo publicar: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _file == null ? _buildPicker() : _buildPreview(),
            _buildTopBar(),
            if (_isUploading) _buildUploadOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF0EA5A4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nueva historia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Comparte un momento con tus pacientes',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PickerOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galería',
                    onTap: _pickFromGallery,
                  ),
                  const SizedBox(width: 20),
                  _PickerOption(
                    icon: Icons.videocam_rounded,
                    label: 'Video',
                    onTap: _pickVideo,
                  ),
                  const SizedBox(width: 20),
                  _PickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Cámara',
                    onTap: () => _takePhoto(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isVideo)
            Container(
              color: const Color(0xFF111827),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 52),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _file?.name ?? 'Video',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            )
          else if (_bytes != null)
            Image.memory(_bytes!, fit: BoxFit.cover),

          if (_isVideo)
            Positioned(
              top: 72,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('VIDEO',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),

          // Caption overlay (preview)
          if (_textController.text.trim().isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _textController.text.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    shadows: [
                      Shadow(color: Colors.black87, blurRadius: 16),
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom editor
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextField(
                      controller: _textController,
                      onChanged: (_) => setState(() {}),
                      maxLength: 150,
                      maxLines: 2,
                      minLines: 1,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        hintText: 'Añade un texto a tu historia...',
                        hintStyle:
                            TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PreviewAction(
                        icon: Icons.photo_library_outlined,
                        label: 'Cambiar',
                        onTap: _pickFromGallery,
                      ),
                      const SizedBox(width: 12),
                      _PreviewAction(
                        icon: Icons.delete_outline,
                        label: 'Quitar',
                        onTap: _clearMedia,
                      ),
                      const SizedBox(width: 12),
                      _PreviewAction(
                        icon: Icons.camera_alt_outlined,
                        label: 'Cámara',
                        onTap: () => _takePhoto(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: _isUploading ? null : () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            const Text(
              'Nueva historia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_file != null)
              FilledButton(
                onPressed: _isUploading ? null : _publishStory,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Publicar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Publicando historia...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(_accent),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_uploadProgress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PreviewAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PreviewAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
