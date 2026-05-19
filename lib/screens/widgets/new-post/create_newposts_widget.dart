import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medident/screens/shared/promotion-editor-screen.dart';
import 'image_editor_screen.dart';

class PostType {
  final IconData icon;
  final String label;
  final Color color;
  final String collection;
  final int maxImages;

  const PostType._(this.icon, this.label, this.color, this.collection, this.maxImages);

  static const penser = PostType._(Icons.edit_note, 'Pensar', Color(0xFF1DA1F2), 'posts', 0);
  static const photo = PostType._(Icons.camera_alt_rounded, 'Foto', Color(0xFFE11B48), 'posts', 10);
  static const promo = PostType._(Icons.card_giftcard_rounded, 'Promo', Color(0xFF9333EA), 'promotions', 5);
  static const event = PostType._(Icons.event_rounded, 'Evento', Color(0xFFF59E0B), 'events', 5);
  static const poll = PostType._(Icons.poll_rounded, 'Encuesta', Color(0xFF10B981), 'polls', 0);
  static const video = PostType._(Icons.videocam_rounded, 'Video', Color(0xFFFF6B6B), 'reels', 1);
  static const link = PostType._(Icons.link_rounded, 'Enlace', Color(0xFF6366F1), 'posts', 0);
  static const apoyo = PostType._(Icons.group_add_rounded, 'Apoyo', Color(0xFF06B6D4), 'apoyos', 3);
  static const grupo = PostType._(Icons.groups_rounded, 'Grupo', Color(0xFFF97316), 'grupos', 3);
  static const streaming = PostType._(Icons.live_tv_rounded, 'Streaming', Color(0xFFEF4444), 'streaming', 0);

  static const List<PostType> values = [penser, photo, promo, event, poll, video, link, apoyo, grupo, streaming];
}

class CreateNewPostScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userPhoto;
  final String? clinicId;
  final VoidCallback? onPublished;
  final String promoScope;

  const CreateNewPostScreen({
    super.key,
    this.userId,
    this.userName,
    this.userPhoto,
    this.clinicId,
    this.onPublished,
    this.promoScope = 'profile',
  });

  @override
  State<CreateNewPostScreen> createState() => _CreateNewPostScreenState();
}

class _CreateNewPostScreenState extends State<CreateNewPostScreen> {
  PostType _selectedType = PostType.penser;
  final _textCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _focus = FocusNode();
  final _picker = ImagePicker();
  final List<Uint8List> _imageBytes = [];
  final List<String> _tempPaths = [];
  List<String> _uploadedImageUrls = [];
  List<String> _uploadedStoragePaths = [];
  List<String> _pollOptions = [];
  final _pollOptCtrl = TextEditingController();
  bool _isPosting = false;

  String get _userId => widget.userId?.isNotEmpty == true ? widget.userId! : 'user_dentist_1';
  String get _userName => widget.userName ?? 'Usuario Demo';
  String get _userPhoto => widget.userPhoto?.isNotEmpty == true ? widget.userPhoto! : '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focus.requestFocus());
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _questionCtrl.dispose();
    _linkCtrl.dispose();
    _titleCtrl.dispose();
    _focus.dispose();
    _pollOptCtrl.dispose();
    super.dispose();
  }

  int get _maxImages => _selectedType.maxImages;

  void _pickCamera() async {
    if (_imageBytes.length >= _maxImages) {
      _showMaxAlert();
      return;
    }
    final img = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (img != null) _addImage(img);
  }

  void _pickGallery() async {
    if (_imageBytes.length >= _maxImages) {
      _showMaxAlert();
      return;
    }
    final remaining = _maxImages - _imageBytes.length;
    final imgs = await _picker.pickMultiImage(maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    for (final img in imgs.take(remaining)) _addImage(img);
    if (imgs.length > remaining && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solo se permiten $_maxImages imágenes. Se agregaron $remaining.')),
      );
    }
  }

  void _addImage(XFile file) async {
    if (_imageBytes.length >= _maxImages) return;
    try {
      _imageBytes.add(await file.readAsBytes());
      _tempPaths.add(file.path);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _showMaxAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Máximo $_maxImages imágenes para este tipo de publicación.')),
    );
  }

  void _removeImage(int i) {
    _imageBytes.removeAt(i);
    _tempPaths.removeAt(i);
    if (mounted) setState(() {});
  }

  void _addPollOpt() {
    final t = _pollOptCtrl.text.trim();
    if (t.isNotEmpty && _pollOptions.length < 6) {
      setState(() => _pollOptions.add(t));
      _pollOptCtrl.clear();
    }
  }

  Future<List<String>> _uploadImages() async {
    final urls = <String>[];
    final storage = FirebaseStorage.instance;
    final ts = DateTime.now().millisecondsSinceEpoch;
    final isClinic = widget.clinicId != null && widget.clinicId!.isNotEmpty;
    for (var i = 0; i < _imageBytes.length; i++) {
      final dest = isClinic
          ? 'posts/clinics/${widget.clinicId}/${ts}_$i.jpg'
          : 'posts/users/$_userId/${ts}_$i.jpg';
      final ref = storage.ref(dest);
      await ref.putData(_imageBytes[i], SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await ref.getDownloadURL());
      _uploadedStoragePaths.add(dest);
    }
    return urls;
  }

  Map<String, dynamic> _buildData() {
    final base = <String, dynamic>{'createdAt': FieldValue.serverTimestamp()};
    final isClinic = widget.clinicId != null && widget.clinicId!.isNotEmpty;
    if (isClinic) base['clinicId'] = widget.clinicId;

    switch (_selectedType) {
      case PostType.penser:
        return {...base, 'type': 'penser', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'description': _textCtrl.text.trim(), 'likesCount': 0, 'commentsCount': 0, 'sharesCount': 0, 'likedBy': <String>[], 'city': ''};
      case PostType.photo:
        return {...base, 'type': 'photo', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'description': _textCtrl.text.trim(), 'imageUrls': _uploadedImageUrls, 'likesCount': 0, 'commentsCount': 0, 'likedBy': <String>[]};
      case PostType.promo:
        return {...base, 'type': 'promo', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'description': _textCtrl.text.trim(), 'likesCount': 0, 'commentsCount': 0};
      case PostType.event:
        return {...base, 'type': 'event', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'description': _textCtrl.text.trim(), 'likesCount': 0, 'commentsCount': 0};
      case PostType.poll:
        return {...base, 'type': 'poll', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'question': _questionCtrl.text.trim(), 'options': _pollOptions.map((o) => {'text': o, 'votes': 0}).toList(), 'votesCount': 0};
      case PostType.video:
        return {...base, 'type': 'video', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'description': _textCtrl.text.trim(), 'likesCount': 0, 'commentsCount': 0};
      case PostType.link:
        return {...base, 'type': 'link', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'url': _linkCtrl.text.trim(), 'description': _textCtrl.text.trim(), 'likesCount': 0, 'commentsCount': 0};
      case PostType.apoyo:
        return {...base, 'type': 'apoyo', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'name': _titleCtrl.text.trim(), 'description': _textCtrl.text.trim(), 'contact': _linkCtrl.text.trim(), 'imageUrls': _uploadedImageUrls, 'likesCount': 0, 'commentsCount': 0, 'membersCount': 0};
      case PostType.grupo:
        return {...base, 'type': 'grupo', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'name': _titleCtrl.text.trim(), 'description': _textCtrl.text.trim(), 'imageUrls': _uploadedImageUrls, 'likesCount': 0, 'commentsCount': 0, 'membersCount': 0};
      case PostType.streaming:
        return {...base, 'type': 'streaming', 'createdBy': _userId, 'userName': _userName, 'userPhoto': _userPhoto, 'name': _titleCtrl.text.trim(), 'description': _textCtrl.text.trim(), 'streamUrl': _linkCtrl.text.trim(), 'imageUrls': _uploadedImageUrls, 'likesCount': 0, 'commentsCount': 0, 'isLive': false};
    }
    return base;
  }

  bool _hasContent() {
    switch (_selectedType) {
      case PostType.penser: return _textCtrl.text.trim().isNotEmpty;
      case PostType.photo: return _imageBytes.isNotEmpty || _textCtrl.text.trim().isNotEmpty;
      case PostType.event: return _textCtrl.text.trim().isNotEmpty;
      case PostType.poll: return _pollOptions.isNotEmpty;
      case PostType.video: return _textCtrl.text.trim().isNotEmpty;
      case PostType.link: return _linkCtrl.text.trim().isNotEmpty;
      case PostType.apoyo: return _titleCtrl.text.trim().isNotEmpty;
      case PostType.grupo: return _titleCtrl.text.trim().isNotEmpty;
      case PostType.streaming: return _titleCtrl.text.trim().isNotEmpty;
      default: return false;
    }
  }

  Future<void> _publish() async {
    if (!_hasContent()) return;
    setState(() => _isPosting = true);
    try {
      if (_imageBytes.isNotEmpty) {
        _uploadedImageUrls = await _uploadImages();
      }
      await FirebaseFirestore.instance.collection(_selectedType.collection).add(_buildData());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Publicado!'), backgroundColor: Color(0xFF0EA5A4)),
        );
      }
      widget.onPublished?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.close, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _selectedType.color.withOpacity(0.12),
            backgroundImage: _userPhoto.isNotEmpty ? NetworkImage(_userPhoto) : null,
            child: _userPhoto.isEmpty
                ? Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : '?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _selectedType.color))
                : null,
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text('Crear ${_selectedType.label}', style: TextStyle(fontSize: 11, color: _selectedType.color.withOpacity(0.7))),
          ]),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isPosting || !_hasContent() ? null : _publish,
              child: _isPosting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Publicar', style: TextStyle(fontWeight: FontWeight.w600, color: _hasContent() ? const Color(0xFF0EA5A4) : Colors.grey[400])),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          const Divider(height: 1),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildBody(),
          )),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: PostType.values.length,
          itemBuilder: (_, i) {
            final type = PostType.values[i];
            final active = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                width: active ? 68 : 56,
                decoration: BoxDecoration(
                  color: active ? type.color : Colors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: active ? type.color : Colors.grey[200]!, width: active ? 0 : 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(type.icon, size: active ? 22 : 18, color: active ? Colors.white : Colors.grey[500]),
                    const SizedBox(height: 2),
                    Text(type.label, style: TextStyle(fontSize: active ? 9 : 8, fontWeight: FontWeight.w600, color: active ? Colors.white : Colors.grey[600])),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedType == PostType.promo) return _buildPromoRedirect();
    switch (_selectedType) {
      case PostType.penser: return _textForm(icon: Icons.edit_note, color: const Color(0xFF1DA1F2));
      case PostType.photo: return _photoForm();
      case PostType.event: return _textForm(hint: 'Describe tu evento...', icon: Icons.event_rounded, color: const Color(0xFFF59E0B));
      case PostType.poll: return _pollForm();
      case PostType.video: return _textForm(hint: 'Describe tu video...', icon: Icons.videocam_rounded, color: const Color(0xFFFF6B6B));
      case PostType.link: return _linkForm();
      case PostType.apoyo: return _namedForm('Nombre del grupo de apoyo', Icons.group_add_rounded, const Color(0xFF06B6D4));
      case PostType.grupo: return _namedForm('Nombre del grupo', Icons.groups_rounded, const Color(0xFFF97316));
      case PostType.streaming: return _namedForm('Título del streaming', Icons.live_tv_rounded, const Color(0xFFEF4444));
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildPromoRedirect() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF9333EA).withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.card_giftcard_rounded, size: 56, color: Color(0xFF9333EA)),
          ),
          const SizedBox(height: 20),
          const Text('Crea promociones con múltiples imágenes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text('Cada imagen puede tener su propio título, precio y texto',
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: ElevatedButton.icon(
              onPressed: _openPromoEditor,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Crear promoción'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPromoEditor() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PromotionEditorScreen(
          userId: _userId,
          userName: _userName,
          userPhoto: _userPhoto,
          clinicId: widget.clinicId,
        ),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context);
      widget.onPublished?.call();
    }
  }

  Widget _textForm({String hint = '¿Qué estás pensando?', required IconData icon, required Color color}) {
    return TextField(
      controller: _textCtrl,
      focusNode: _focus,
      maxLines: 8,
      minLines: 4,
      style: const TextStyle(fontSize: 15, height: 1.5),
      decoration: _decoration(hint, icon, color),
    );
  }

  Widget _photoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(color: const Color(0xFFE11B48)),
        const SizedBox(height: 12),
        TextField(
          controller: _textCtrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 15),
          decoration: _decoration('Añade un texto...', Icons.camera_alt_rounded, const Color(0xFFE11B48)),
        ),
      ],
    );
  }

  Widget _pollForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _questionCtrl,
          focusNode: _focus,
          maxLines: 2,
          style: const TextStyle(fontSize: 15),
          decoration: _decoration('Escribe tu pregunta...', Icons.poll_rounded, const Color(0xFF10B981)),
        ),
        const SizedBox(height: 16),
        const Text('Opciones', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        ..._pollOptions.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.15)),
          ),
          child: Row(children: [
            Icon(Icons.check_circle, size: 16, color: const Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(child: Text(e.value, style: const TextStyle(fontSize: 14))),
            GestureDetector(
              onTap: () => setState(() => _pollOptions.removeAt(e.key)),
              child: Icon(Icons.close, size: 16, color: Colors.grey[400]),
            ),
          ]),
        )),
        if (_pollOptions.length < 6)
          Row(children: [
            Expanded(child: TextField(
              controller: _pollOptCtrl,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Nueva opción',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                filled: true, fillColor: const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _addPollOpt(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addPollOpt,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ]),
      ],
    );
  }

  Widget _linkForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _linkCtrl,
          focusNode: _focus,
          style: const TextStyle(fontSize: 15),
          decoration: _decoration('URL del enlace...', Icons.link_rounded, const Color(0xFF6366F1)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textCtrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 15),
          decoration: _decoration('Descripción...', Icons.description_outlined, const Color(0xFF6366F1)),
        ),
      ],
    );
  }

  Widget _namedForm(String hint, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(color: color),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtrl,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: _decoration(hint, icon, color),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textCtrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 15),
          decoration: _decoration('Descripción...', Icons.description_outlined, color),
        ),
        if (_selectedType == PostType.apoyo) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _linkCtrl,
            style: const TextStyle(fontSize: 15),
            decoration: _decoration('Contacto (teléfono/email)', Icons.contact_phone_outlined, color),
          ),
        ],
      ],
    );
  }

  Widget _buildImageSection({required Color color}) {
    if (_imageBytes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _mediaBtn(Icons.camera_alt, 'Cámara', color, _pickCamera),
              const SizedBox(width: 16),
              _mediaBtn(Icons.photo_library, 'Galería', color, _pickGallery),
            ]),
            const SizedBox(height: 6),
            if (_maxImages > 0)
              Text('Máximo $_maxImages imágenes', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
      );
    }

    final atLimit = _imageBytes.length >= _maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _imageBytes.length + (atLimit ? 0 : 1),
          itemBuilder: (_, i) {
            if (!atLimit && i == _imageBytes.length) {
              return GestureDetector(
                onTap: _pickGallery,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400], size: 28),
                        const SizedBox(height: 4),
                        Text('Agregar', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
              );
            }
            return GestureDetector(
              onTap: () => _previewImage(i),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_imageBytes[i], fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(i),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Editar', textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.image, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text('${_imageBytes.length} de $_maxImages imágenes · Toca para editar',
              style: TextStyle(fontSize: 11, color: atLimit ? color : Colors.grey[400])),
          ],
        ),
      ],
    );
  }

  Future<void> _previewImage(int index) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenImagePreview(
          bytes: _imageBytes[index],
          onReplace: () async {
            final picker = ImagePicker();
            final img = await picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 1200,
              maxHeight: 1200,
              imageQuality: 80,
            );
            if (img != null) return await img.readAsBytes();
            return null;
          },
          onDelete: () => Navigator.pop(context, 'delete'),
        ),
      ),
    );

    if (result == 'delete') {
      _removeImage(index);
    } else if (result is Uint8List) {
      setState(() => _imageBytes[index] = result);
    }
  }

  Widget _mediaBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon, Color color) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
    );
  }
}

// ─── Draft Storage ────────────────────────────────────────────────────────

class _DraftStore {
  static final Map<String, String> _drafts = {};
  static String? get(String userId) => _drafts[userId];
  static void set(String userId, String text) => _drafts[userId] = text;
  static void remove(String userId) => _drafts.remove(userId);
}

// ─── Full-Screen Image Preview ───────────────────────────────────────────

class _FullScreenImagePreview extends StatefulWidget {
  final Uint8List bytes;
  final Future<Uint8List?> Function() onReplace;
  final VoidCallback onDelete;

  const _FullScreenImagePreview({
    required this.bytes,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  State<_FullScreenImagePreview> createState() => _FullScreenImagePreviewState();
}

class _FullScreenImagePreviewState extends State<_FullScreenImagePreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.memory(widget.bytes, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionBtn(Icons.camera_alt, 'Reemplazar', () async {
                    final newBytes = await widget.onReplace();
                    if (newBytes != null && mounted) {
                      Navigator.pop(context, newBytes);
                    }
                  }),
                  const SizedBox(width: 16),
                  _actionBtn(Icons.crop, 'Ajustar', () async {
                    final edited = await Navigator.push<Uint8List>(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => ImageEditorScreen(imageBytes: widget.bytes),
                      ),
                    );
                    if (edited != null && mounted) {
                      Navigator.pop(context, edited);
                    }
                  }),
                  const SizedBox(width: 16),
                  _actionBtn(Icons.delete_outline, 'Eliminar', widget.onDelete),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_formatBytes(widget.bytes.length)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─── Card Widget ──────────────────────────────────────────────────────────

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

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => _CreatePostSheet(
        userId: _userId,
        userName: _userName,
        userPhoto: _userPhoto,
        clinicId: clinicId,
        onPublished: onPublished,
        promoScope: promoScope,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: _userPhoto.isNotEmpty ? NetworkImage(_userPhoto) : null,
                  onBackgroundImageError: _userPhoto.isNotEmpty ? (_, __) {} : null,
                  child: _userPhoto.isEmpty && _userName.isNotEmpty
                      ? Text(_userName[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0EA5A4)))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('¿Qué quieres compartir?',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0EA5A4), Color(0xFF06B6D4)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF0EA5A4).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
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

// ─── Bottom Sheet ─────────────────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhoto;
  final String? clinicId;
  final VoidCallback? onPublished;
  final String promoScope;

  const _CreatePostSheet({
    required this.userId,
    required this.userName,
    this.userPhoto = '',
    this.clinicId,
    this.onPublished,
    this.promoScope = 'profile',
  });

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> with SingleTickerProviderStateMixin {
  PostType _selectedType = PostType.penser;
  final _textCtrl = TextEditingController();
  final _focus = FocusNode();
  bool _isPosting = false;
  late AnimationController _springCtrl;
  late Animation<double> _springAnim;

  String get _userId => widget.userId;
  String get _userName => widget.userName;
  String get _userPhoto => widget.userPhoto;

  @override
  void initState() {
    super.initState();
    final draft = _DraftStore.get(_userId);
    if (draft != null) {
      _textCtrl.text = draft;
    }
    _textCtrl.addListener(_onTextChanged);

    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _springAnim = CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut);
    _springCtrl.forward();
  }

  @override
  void dispose() {
    _textCtrl.removeListener(_onTextChanged);
    _textCtrl.dispose();
    _focus.dispose();
    _springCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textCtrl.text;
    if (text.isNotEmpty) {
      _DraftStore.set(_userId, text);
    } else {
      _DraftStore.remove(_userId);
    }
  }

  void _onTypeSelected(PostType type) {
    setState(() => _selectedType = type);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _focus.requestFocus();
    });
  }

  Future<void> _showNewPatientDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _PersonFormDialog(type: 'patient'),
    );
    if (result != null && mounted) {
      try {
        await FirebaseFirestore.instance.collection('users').add({
          ...result,
          'role': 'patient',
          'createdBy': _userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paciente creado exitosamente'),
              backgroundColor: Color(0xFF0EA5A4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          );
        }
      } catch (e) {
        if (mounted) _showError('Error al crear paciente: $e');
      }
    }
  }

  Future<void> _showNewEmployeeDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _PersonFormDialog(type: 'employee'),
    );
    if (result != null && mounted) {
      try {
        await FirebaseFirestore.instance.collection('users').add({
          ...result,
          'role': 'employee',
          'createdBy': _userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empleado creado exitosamente'),
              backgroundColor: Color(0xFFF59E0B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          );
        }
      } catch (e) {
        if (mounted) _showError('Error al crear empleado: $e');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
  }

  Future<void> _publish() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isPosting = true);
    try {
      final base = <String, dynamic>{
        'type': _selectedType.label.toLowerCase(),
        'description': text,
        'createdBy': _userId,
        'userName': _userName,
        'userPhoto': _userPhoto,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        'likedBy': <String>[],
      };
      if (widget.clinicId != null && widget.clinicId!.isNotEmpty) {
        base['clinicId'] = widget.clinicId;
      }
      await FirebaseFirestore.instance.collection(_selectedType.collection).add(base);
      _DraftStore.remove(_userId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicado!'),
            backgroundColor: Color(0xFF0EA5A4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
      }
      widget.onPublished?.call();
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      onTap: () => _focus.unfocus(),
      child: FadeTransition(
        opacity: _springAnim,
        child: Container(
          padding: EdgeInsets.only(bottom: bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(width: 40, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Crear publicación',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), letterSpacing: -0.3)),
                    ),
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[100]),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      _buildGrid(),
                      const SizedBox(height: 20),
                      _buildTextField(),
                      const SizedBox(height: 16),
                      _buildPublishButton(),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSpecialCard(
              icon: Icons.person_add,
              label: 'Nuevo Paciente',
              color: const Color(0xFF0EA5A4),
              onTap: _showNewPatientDialog,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildSpecialCard(
              icon: Icons.badge,
              label: 'Nuevo Empleado',
              color: const Color(0xFFF59E0B),
              onTap: _showNewEmployeeDialog,
            )),
          ],
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Publicar',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B), letterSpacing: 0.5)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: PostType.values.length,
          itemBuilder: (_, i) {
            final type = PostType.values[i];
            final active = _selectedType == type;
            return _GridCard(
              icon: type.icon,
              label: type.label,
              color: type.color,
              active: active,
              onTap: () => _onTypeSelected(type),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecialCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ),
            Icon(Icons.chevron_right, size: 18, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _textCtrl,
        focusNode: _focus,
        maxLines: 4,
        minLines: 2,
        style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: _selectedType == PostType.penser
              ? '¿Qué quieres compartir?'
              : 'Comparte sobre ${_selectedType.label.toLowerCase()}...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    final hasText = _textCtrl.text.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasText
              ? [BoxShadow(color: const Color(0xFF0EA5A4).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: ElevatedButton(
          onPressed: hasText && !_isPosting ? _publish : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0EA5A4),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[200],
            disabledForegroundColor: Colors.grey[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isPosting
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5, strokeCap: StrokeCap.round))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_selectedType.icon, size: 18),
                    const SizedBox(width: 8),
                    const Text('Publicar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _GridCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color: active ? color : Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color : Colors.grey[200]!,
            width: active ? 0 : 1,
          ),
          boxShadow: active
              ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(icon, size: 20, color: active ? Colors.white : Colors.grey[500]),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.grey[600],
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Person Form Dialog ───────────────────────────────────────────────────

class _PersonFormDialog extends StatefulWidget {
  final String type;
  const _PersonFormDialog({required this.type});

  @override
  State<_PersonFormDialog> createState() => _PersonFormDialogState();
}

class _PersonFormDialogState extends State<_PersonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  bool _isSaving = false;

  String get _title => widget.type == 'patient' ? 'Nuevo Paciente' : 'Nuevo Empleado';
  Color get _accent => widget.type == 'patient' ? const Color(0xFF0EA5A4) : const Color(0xFFF59E0B);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _accent.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(
                  widget.type == 'patient' ? Icons.person_add : Icons.badge,
                  size: 28, color: _accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(_title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.person_outline, size: 20, color: _accent.withOpacity(0.6)),
                  filled: true, fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _accent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.phone_outlined, size: 20, color: _accent.withOpacity(0.6)),
                  filled: true, fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _accent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),
              if (widget.type == 'patient')
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.email_outlined, size: 20, color: _accent.withOpacity(0.6)),
                    filled: true, fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _accent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
              if (widget.type == 'employee') ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _roleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Rol / Puesto',
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.work_outline, size: 20, color: _accent.withOpacity(0.6)),
                    filled: true, fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _accent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text('Crear', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = <String, String>{
      'fullName': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    };
    if (widget.type == 'patient') {
      data['email'] = _emailCtrl.text.trim();
    } else {
      data['role'] = _roleCtrl.text.trim();
    }
    Navigator.pop(context, data);
  }
}
