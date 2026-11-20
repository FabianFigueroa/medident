import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medident/screens/widgets/new-post/image_editor_screen.dart';
import 'package:medident/screens/widgets/new-post/local_video_preview.dart';
import 'package:medident/screens/widgets/new-post/video_editor_screen.dart';
import 'package:medident/screens/widgets/new-post/video_trim_result.dart';
import 'package:medident/screens/widgets/new-post/video_trim_service.dart';

const Color _kAccent = Color(0xFF0EA5A4);

/// Abre la pantalla unica para crear una publicacion.
Future<void> showCreatePostSheet(
  BuildContext context, {
  required String userId,
  required String userName,
  String? userPhoto,
  String? clinicId,
  String? authorUserId,
  VoidCallback? onPublished,
  String promoScope = 'profile',
  bool startWithGallery = false,
  bool startAsPromotion = false,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      builder: (_) => CreateNewPostScreen(
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        clinicId: clinicId,
        authorUserId: authorUserId,
        onPublished: onPublished,
        promoScope: promoScope,
        startWithGallery: startWithGallery,
        startAsPromotion: startAsPromotion,
      ),
    ),
  );
}

enum _ComposerMode { media, text }

class _PickedMedia {
  Uint8List bytes;
  String name;
  bool isVideo;
  String path;
  Duration? duration;

  _PickedMedia({
    required this.bytes,
    required this.name,
    required this.isVideo,
    this.path = '',
    this.duration,
  });

  String get extension {
    final lower = name.toLowerCase();
    final dot = lower.lastIndexOf('.');
    if (dot == -1 || dot == lower.length - 1) {
      return isVideo ? 'mp4' : 'jpg';
    }
    return lower.substring(dot + 1);
  }

  String get contentType {
    if (isVideo) {
      switch (extension) {
        case 'mov':
          return 'video/quicktime';
        case 'webm':
          return 'video/webm';
        default:
          return 'video/mp4';
      }
    }
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String get sizeLabel {
    final mb = bytes.length / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = bytes.length / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }
}

/// Tarjeta "Que quieres compartir?" usada en los homes.
class Create_Newposts_Widget extends StatelessWidget {
  final String? userId;
  final String? userName;
  final String? userPhoto;
  final String? clinicId;
  final VoidCallback? onPublished;
  final String promoScope;

  const Create_Newposts_Widget({
    super.key,
    this.userId,
    this.userName,
    this.userPhoto,
    this.clinicId,
    this.onPublished,
    this.promoScope = 'profile',
  });

  String get _userId => userId?.isNotEmpty == true ? userId! : 'user_dentist_1';
  String get _userName => userName ?? 'Usuario Demo';
  String get _userPhoto => userPhoto?.isNotEmpty == true ? userPhoto! : '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showCreatePostSheet(
            context,
            userId: _userId,
            userName: _userName,
            userPhoto: _userPhoto,
            clinicId: clinicId,
            onPublished: onPublished,
            promoScope: promoScope,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _Avatar(name: _userName, photo: _userPhoto),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Que quieres compartir?',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kAccent, Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String photo;

  const _Avatar({required this.name, required this.photo});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFE2F7F6),
      backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
      onBackgroundImageError: photo.isNotEmpty ? (_, __) {} : null,
      child: photo.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _kAccent,
              ),
            )
          : null,
    );
  }
}

/// Pantalla unica de creacion de publicaciones.
///
/// Flujo simple: se abre el selector de camara/galeria, se agregan fotos o un
/// video, se previsualizan en un scroll horizontal, se pueden editar o quitar y
/// finalmente se publican. La descripcion es opcional.
class CreateNewPostScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userPhoto;
  final String? clinicId;
  final String? authorUserId;
  final VoidCallback? onPublished;
  final String promoScope;
  final bool startWithGallery;
  final bool startAsPromotion;

  const CreateNewPostScreen({
    super.key,
    this.userId,
    this.userName,
    this.userPhoto,
    this.clinicId,
    this.authorUserId,
    this.onPublished,
    this.promoScope = 'profile',
    this.startWithGallery = false,
    this.startAsPromotion = false,
  });

  @override
  State<CreateNewPostScreen> createState() => _CreateNewPostScreenState();
}

class _CreateNewPostScreenState extends State<CreateNewPostScreen> {
  final _textCtrl = TextEditingController();
  final _captionFocus = FocusNode();
  final _picker = ImagePicker();

  final List<_PickedMedia> _media = [];
  _ComposerMode _mode = _ComposerMode.media;

  bool _isPosting = false;
  double _progress = 0;
  int _uploaded = 0;
  int _totalToUpload = 0;
  String _clinicName = '';

  final _pageCtrl = PageController();
  int _mediaIndex = 0;
  bool _isPromotion = false;
  bool _showPromoFields = false;
  final _promoTitleCtrl = TextEditingController();
  final _promoPriceCtrl = TextEditingController();
  final _promoDiscountCtrl = TextEditingController();
  DateTime? _promoValidUntil;

  static const int _maxImages = 10;

  String get _userId =>
      widget.userId?.isNotEmpty == true ? widget.userId! : 'user_dentist_1';
  String get _userName => widget.userName ?? 'Usuario Demo';
  String get _userPhoto =>
      widget.userPhoto?.isNotEmpty == true ? widget.userPhoto! : '';
  bool get _isClinic => widget.clinicId != null && widget.clinicId!.isNotEmpty;
  String get _displayName => _isClinic
      ? (_clinicName.isNotEmpty ? _clinicName : 'Clínica')
      : _userName;
  int get _imageCount => _media.where((m) => !m.isVideo).length;

  bool get _hasContent {
    if (_isPromotion) {
      return _promoTitleCtrl.text.trim().isNotEmpty &&
          (double.tryParse(_promoPriceCtrl.text.trim().replaceAll(',', '.')) ??
                  0) >
              0 &&
          _imageCount > 0;
    }
    if (_textCtrl.text.trim().isNotEmpty) return true;
    return _mode == _ComposerMode.media && _media.isNotEmpty;
  }

  _PickedMedia? get _currentMedia {
    if (_media.isEmpty) return null;
    final index = _mediaIndex.clamp(0, _media.length - 1);
    return _media[index];
  }

  @override
  void initState() {
    super.initState();
    if (_isClinic) _loadClinicIdentity();
    if (widget.startAsPromotion) {
      _isPromotion = true;
      _showPromoFields = true;
    }
    if (widget.startWithGallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pickGalleryMedia();
      });
    }
  }

  Future<void> _loadClinicIdentity() async {
    final source = await _clinicSource();
    if (!mounted) return;
    setState(() {
      _clinicName = source['name'] ?? '';
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _captionFocus.dispose();
    _pageCtrl.dispose();
    _promoTitleCtrl.dispose();
    _promoPriceCtrl.dispose();
    _promoDiscountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages(ImageSource source) async {
    if (source == ImageSource.gallery) {
      await _pickGalleryMedia();
      return;
    }
    if (_media.length >= _maxImages) {
      _showError('Máximo $_maxImages archivos por publicación.');
      return;
    }
    try {
      final img = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (img != null) await _addImage(img);
      if (mounted) setState(() => _mode = _ComposerMode.media);
    } catch (e) {
      _showError('No se pudo abrir la cámara: $e');
    }
  }

  Future<void> _pickGalleryMedia() async {
    if (_media.length >= _maxImages) {
      _showError('Máximo $_maxImages archivos por publicación.');
      return;
    }
    try {
      final remaining = _maxImages - _media.length;
      final files = await _picker.pickMultipleMedia(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
        limit: remaining,
      );
      for (final file in files.take(remaining)) {
        await _addMediaFile(file);
      }
      if (files.length > remaining) {
        _showError('Solo se permiten $_maxImages archivos.');
      }
      if (mounted) setState(() => _mode = _ComposerMode.media);
    } catch (e) {
      _showError('No se pudo abrir la galería: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (video == null) return;
      await _addMediaFile(video);
      if (mounted) setState(() => _mode = _ComposerMode.media);
    } catch (e) {
      _showError('No se pudo seleccionar el video: $e');
    }
  }

  Future<void> _addImage(XFile file) async {
    await _addMediaFile(file, forceImage: true);
  }

  Future<void> _addMediaFile(XFile file, {bool forceImage = false}) async {
    if (_media.length >= _maxImages) return;
    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final lower = file.name.toLowerCase();
      final isVideo =
          !forceImage &&
          (file.mimeType?.startsWith('video/') == true ||
              lower.endsWith('.mp4') ||
              lower.endsWith('.mov') ||
              lower.endsWith('.webm') ||
              lower.endsWith('.avi') ||
              lower.endsWith('.mkv'));
      final duration = isVideo ? await probeVideoDuration(file.path) : null;
      if (!mounted) return;
      setState(() {
        _media.add(
          _PickedMedia(
            bytes: bytes,
            name: file.name,
            isVideo: isVideo,
            path: file.path,
            duration: duration,
          ),
        );
        _mediaIndex = _media.length - 1;
        _mode = _ComposerMode.media;
      });
      if (_pageCtrl.hasClients) {
        _pageCtrl.jumpToPage(_mediaIndex);
      }
    } catch (e) {
      _showError('No se pudo leer el archivo: $e');
    }
  }

  void _removeMedia(int index) {
    if (index < 0 || index >= _media.length) return;
    setState(() {
      _media.removeAt(index);
      if (_media.isEmpty) {
        _mediaIndex = 0;
      } else if (_mediaIndex >= _media.length) {
        _mediaIndex = _media.length - 1;
      }
      if (_isPromotion && _imageCount == 0) {
        _showPromoFields = true;
      }
    });
    if (_pageCtrl.hasClients && _media.isNotEmpty) {
      _pageCtrl.jumpToPage(_mediaIndex);
    }
  }

  Future<void> _editMedia(int index) async {
    if (index < 0 || index >= _media.length) return;
    final item = _media[index];
    if (item.isVideo) {
      _showVideoOptions(index);
      return;
    }
    final edited = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditorScreen(imageBytes: item.bytes),
      ),
    );
    if (edited == null || !mounted) return;
    setState(() {
      _media[index] = _PickedMedia(
        bytes: edited,
        name: 'editada_${DateTime.now().millisecondsSinceEpoch}.png',
        isVideo: false,
      );
    });
  }

  Future<void> _openVideoEditor(int index) async {
    if (index < 0 || index >= _media.length) return;
    final item = _media[index];
    final result = await Navigator.push<VideoTrimResult>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoEditorScreen(
          path: item.path,
          bytes: item.bytes,
          name: item.name,
          duration: item.duration,
        ),
      ),
    );
    if (!mounted || result == null || !result.hasBytes) return;
    setState(() {
      _media[index] = _PickedMedia(
        bytes: result.bytes!,
        name: result.fileName ?? item.name,
        isVideo: true,
        duration: result.duration ?? item.duration,
      );
    });
  }

  void _showVideoOptions(int index) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.content_cut_rounded, color: _kAccent),
              title: const Text('Recortar video'),
              subtitle: const Text('Elige el inicio y el final'),
              onTap: () {
                Navigator.pop(sheetContext);
                _openVideoEditor(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library_rounded, color: _kAccent),
              title: const Text('Cambiar video'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickVideo(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Quitar video',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _removeMedia(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _clinicSource() async {
    if (!_isClinic) {
      return {'name': _userName, 'photo': _userPhoto};
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .get();
      final data = doc.data();
      final name = (data?['name'] ?? '').toString().trim();
      return {
        'name': name.isNotEmpty ? name : 'Clínica',
        'photo': (data?['logoUrl'] ?? '').toString(),
      };
    } catch (_) {
      return {'name': 'Clínica', 'photo': ''};
    }
  }

  Future<String> _uploadMedia(_PickedMedia item, int index) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final base = _isClinic
        ? 'posts/clinics/${widget.clinicId}'
        : 'posts/users/$_userId';
    final dest = '$base/${ts}_$index.${item.extension}';
    final ref = FirebaseStorage.instance.ref(dest);
    await ref.putData(
      item.bytes,
      SettableMetadata(
        contentType: item.contentType,
        cacheControl: 'public, max-age=31536000, immutable',
        customMetadata: {'uploadedBy': _userId},
      ),
    );
    return ref.getDownloadURL();
  }

  Future<List<String>> _uploadAll(List<_PickedMedia> items) async {
    _totalToUpload = items.length;
    _uploaded = 0;
    if (_totalToUpload == 0) return <String>[];

    final futures = <Future<String>>[];
    for (var i = 0; i < items.length; i++) {
      futures.add(() async {
        final url = await _uploadMedia(items[i], i);
        _uploaded++;
        if (mounted) {
          setState(() => _progress = _uploaded / _totalToUpload);
        }
        return url;
      }());
    }
    return Future.wait(futures);
  }

  Future<void> _publish() async {
    if (!_hasContent || _isPosting) return;
    setState(() {
      _isPosting = true;
      _progress = 0;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      final source = await _clinicSource();
      final items = _mode == _ComposerMode.media
          ? List<_PickedMedia>.from(_media)
          : <_PickedMedia>[];
      final urls = await _uploadAll(items);

      final imageUrls = <String>[];
      final mediaList = <Map<String, dynamic>>[];
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final url = urls[i];
        mediaList.add({
          'url': url,
          'type': item.isVideo ? 'video' : 'image',
          'name': item.name,
          if (item.isVideo) 'mimeType': item.contentType,
        });
        if (!item.isVideo) imageUrls.add(url);
      }

      final hasVideo = items.any((m) => m.isVideo);
      final type = hasVideo
          ? 'video'
          : imageUrls.isNotEmpty
          ? 'photo'
          : 'penser';
      final description = _textCtrl.text.trim();

      final authorId = _isClinic ? widget.clinicId! : _userId;
      final authorName = _isClinic
          ? ((source['name']?.isNotEmpty ?? false)
                ? source['name']!
                : 'Clínica')
          : _userName;
      final authorPhoto = _isClinic ? (source['photo'] ?? '') : _userPhoto;
      final auditUserId = (widget.authorUserId?.isNotEmpty ?? false)
          ? widget.authorUserId
          : _userId;

      final data = <String, dynamic>{
        'type': type,
        'userId': authorId,
        'createdBy': authorId,
        'userName': authorName,
        'userPhoto': authorPhoto,
        'sourceType': _isClinic ? 'clinic' : 'user',
        'sourceId': _isClinic ? widget.clinicId : _userId,
        'sourceName': authorName,
        'sourcePhoto': authorPhoto,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        'sharesCount': 0,
        'likedBy': <String>[],
        'isActive': true,
        'isPromotion': _isPromotion,
        if (_isClinic) 'clinicId': widget.clinicId,
        if (_isClinic) 'createdByUserId': auditUserId,
        if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (mediaList.isNotEmpty) 'media': mediaList,
      };

      await FirebaseFirestore.instance.collection('posts').add(data);

      if (_isPromotion) {
        final promoName = _promoTitleCtrl.text.trim();
        final price =
            double.tryParse(_promoPriceCtrl.text.trim().replaceAll(',', '.')) ??
            0;
        final discountPct =
            double.tryParse(
              _promoDiscountCtrl.text.trim().replaceAll(',', '.'),
            ) ??
            0;
        final discountPrice = discountPct > 0
            ? price - (price * discountPct / 100)
            : null;

        await FirebaseFirestore.instance.collection('promotions').add({
          'type': 'promo',
          'userId': _userId,
          'createdBy': authorId,
          'createdByUserId': auditUserId,
          'name': promoName,
          'description': description.isNotEmpty ? description : promoName,
          'price': price,
          'discountPrice': discountPrice,
          'imageUrls': imageUrls,
          'slides': imageUrls
              .map(
                (url) => {
                  'imageUrl': url,
                  'title': promoName,
                  'subtitle': description,
                  'price': price,
                  'discountPrice': discountPrice,
                },
              )
              .toList(),
          'category': _isClinic ? 'Promoción de clínica' : 'Promoción personal',
          'clinicId': _isClinic ? widget.clinicId : '',
          'clinicName': _isClinic ? authorName : null,
          'clinicLogo': _isClinic ? authorPhoto : null,
          'source': _isClinic ? 'clinic' : 'user',
          'sourceName': authorName,
          'sourcePhoto': authorPhoto,
          'scope': _isClinic ? 'global' : 'profile',
          'isActive': true,
          'isFeatured': false,
          'isAvailable': true,
          'expiresAt': _promoValidUntil != null
              ? Timestamp.fromDate(_promoValidUntil!)
              : null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      widget.onPublished?.call();
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Publicacion creada'),
          backgroundColor: _kAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isPosting = false);
      _showError('Error al publicar: $e');
      return;
    }
    if (mounted) {
      setState(() {
        _isPosting = false;
        _progress = 0;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: _buildStage()),
          Positioned.fill(child: IgnorePointer(child: _buildStageGradients())),
          SafeArea(
            child: Stack(
              children: [
                Align(alignment: Alignment.topCenter, child: _buildTopBar()),
                Positioned(
                  right: 10,
                  bottom: 220 + bottomInset,
                  child: _buildRail(),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(bottomInset),
          ),
          if (_isPosting) _buildPostingOverlay(),
        ],
      ),
    );
  }

  Widget _buildStageGradients() {
    return Column(
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC000000), Color(0x00000000)],
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 360,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xF2000000), Color(0x00000000)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStage() {
    if (_media.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tu momento empieza aquí',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isPromotion
                    ? 'Agrega una foto para crear la promoción de la clínica'
                    : 'Graba un video o elige fotos para publicar',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ghostAction(
                    Icons.photo_library_rounded,
                    'Galería',
                    () => _pickImages(ImageSource.gallery),
                  ),
                  const SizedBox(width: 12),
                  _ghostAction(
                    Icons.photo_camera_rounded,
                    'Cámara',
                    () => _pickImages(ImageSource.camera),
                  ),
                  const SizedBox(width: 12),
                  _ghostAction(
                    Icons.videocam_rounded,
                    'Video',
                    () => _pickVideo(ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageCtrl,
      itemCount: _media.length,
      onPageChanged: (i) => setState(() => _mediaIndex = i),
      itemBuilder: (_, index) {
        final item = _media[index];
        if (item.isVideo) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              LocalVideoPreview(
                path: item.path,
                bytes: item.bytes,
                name: item.name,
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.sizeLabel,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return GestureDetector(
          onTap: () => _editMedia(index),
          child: Container(
            color: Colors.black,
            child: Center(
              child: Image.memory(
                item.bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ghostAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 26,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.35),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                _isPromotion ? 'Nueva promoción' : 'Nueva publicación',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isClinic ? 'Como $_displayName' : _displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: _isPosting || !_hasContent ? null : _publish,
            style: TextButton.styleFrom(
              backgroundColor: _hasContent
                  ? _kAccent
                  : Colors.white.withValues(alpha: 0.14),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: _isPosting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Publicar',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRail() {
    final media = _currentMedia;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _railButton(
          Icons.photo_library_rounded,
          'Fotos',
          () => _pickImages(ImageSource.gallery),
        ),
        _railButton(
          Icons.photo_camera_rounded,
          'Cámara',
          () => _pickImages(ImageSource.camera),
        ),
        _railButton(
          Icons.videocam_rounded,
          'Video',
          () => _pickVideo(ImageSource.gallery),
        ),
        if (media != null)
          _railButton(
            media.isVideo ? Icons.swap_horiz_rounded : Icons.tune_rounded,
            media.isVideo ? 'Cambiar' : 'Editar',
            () => _editMedia(_mediaIndex),
          ),
        if (media != null)
          _railButton(
            Icons.delete_outline_rounded,
            'Quitar',
            () => _removeMedia(_mediaIndex),
          ),
      ],
    );
  }

  Widget _railButton(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: Colors.white, size: 21),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(double bottomInset) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + bottomInset + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_media.isNotEmpty) ...[
              _buildGalleryStrip(),
              const SizedBox(height: 12),
            ],
            _buildPromotionToggle(),
            if (_isPromotion) ...[
              const SizedBox(height: 10),
              _buildPromoFields(),
            ],
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    focusNode: _captionFocus,
                    minLines: 1,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: _mode == _ComposerMode.text
                          ? 'Escribe lo que quieres compartir...'
                          : 'Describe tu publicación...',
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_media.isEmpty)
                  GestureDetector(
                    onTap: _pickGalleryMedia,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Toca una foto para editarla o un video para reproducirlo. Usa los botones de la miniatura para editar o quitar.',
              style: TextStyle(color: Colors.white38, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionToggle() {
    return GestureDetector(
      onTap: () => _togglePromotion(!_isPromotion),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _isPromotion
              ? _kAccent.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _isPromotion
                ? _kAccent.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_rounded,
              size: 15,
              color: _isPromotion ? _kAccent : Colors.white70,
            ),
            const SizedBox(width: 7),
            Text(
              _isPromotion ? 'Promoción activada' : 'Publicar como promoción',
              style: TextStyle(
                color: _isPromotion ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 7),
            Icon(
              _isPromotion
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              size: 16,
              color: _isPromotion ? _kAccent : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  void _togglePromotion(bool value) {
    setState(() {
      _isPromotion = value;
      _showPromoFields = value;
      if (value) _mode = _ComposerMode.media;
    });
    if (value && _imageCount == 0) {
      _pickImages(ImageSource.gallery);
    }
  }

  Widget _buildPromoFields() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPromoFields = !_showPromoFields),
            child: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: _kAccent, size: 16),
                const SizedBox(width: 7),
                const Text(
                  'Datos de la promoción',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showPromoFields
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
          if (_showPromoFields) ...[
            const SizedBox(height: 8),
            _promoField(
              controller: _promoTitleCtrl,
              hint: 'Título de la promoción (obligatorio)',
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: _promoField(
                    controller: _promoPriceCtrl,
                    hint: 'Precio',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _promoField(
                    controller: _promoDiscountCtrl,
                    hint: 'Descuento %',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: _pickPromoDate,
              icon: const Icon(Icons.event_rounded, color: _kAccent, size: 16),
              label: Text(
                _promoValidUntil == null
                    ? 'Vigente hasta (opcional)'
                    : 'Vigente hasta ${_promoValidUntil!.day}/${_promoValidUntil!.month}/${_promoValidUntil!.year}',
                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _promoField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _pickPromoDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _promoValidUntil ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _promoValidUntil = picked);
  }

  Widget _buildGalleryStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.photo_library_rounded,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 6),
            const Text(
              'Galería',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${_media.length}/$_maxImages',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _pickGalleryMedia,
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
              label: const Text('Añadir'),
              style: TextButton.styleFrom(
                foregroundColor: _kAccent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 30),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _media.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              if (index == _media.length) {
                return GestureDetector(
                  onTap: _pickGalleryMedia,
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 26),
                        SizedBox(height: 3),
                        Text(
                          'Galería',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final item = _media[index];
              final selected = index == _mediaIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _mediaIndex = index);
                  if (_pageCtrl.hasClients) {
                    _pageCtrl.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Container(
                  width: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? _kAccent
                          : Colors.white.withValues(alpha: 0.2),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.isVideo)
                        Container(
                          color: const Color(0xFF1E293B),
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        )
                      else
                        Image.memory(item.bytes, fit: BoxFit.cover),
                      Positioned(
                        top: 3,
                        right: 3,
                        child: GestureDetector(
                          onTap: () => _removeMedia(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 3,
                        bottom: 3,
                        child: GestureDetector(
                          onTap: () => _editMedia(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              item.isVideo
                                  ? Icons.videocam_rounded
                                  : Icons.tune_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.62),
        child: Center(
          child: Container(
            width: 230,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
                ),
                const SizedBox(height: 14),
                Text(
                  _totalToUpload == 0
                      ? 'Preparando publicación...'
                      : 'Subiendo $_uploaded de $_totalToUpload archivos...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (_totalToUpload > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 5,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(_kAccent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
