import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medident/core/utils/app-colors.dart';

class ContentType {
  final IconData icon;
  final String label;
  final Color color;
  final Color lightColor;

  const ContentType({
    required this.icon,
    required this.label,
    required this.color,
    required this.lightColor,
  });

  static const post = ContentType(
    icon: Icons.edit_note_rounded,
    label: 'Post',
    color: Color(0xFFA78BFA),
    lightColor: Color(0xFFF3EEFF),
  );
  static const promo = ContentType(
    icon: Icons.card_giftcard_rounded,
    label: 'Promo',
    color: Color(0xFFFBBF24),
    lightColor: Color(0xFFFEF9E7),
  );
  static const story = ContentType(
    icon: Icons.auto_stories_rounded,
    label: 'Historia',
    color: Color(0xFFF472B6),
    lightColor: Color(0xFFFDF2F8),
  );
  static const live = ContentType(
    icon: Icons.videocam_rounded,
    label: 'En vivo',
    color: Color(0xFFFB7185),
    lightColor: Color(0xFFFFF1F2),
  );
  static const poll = ContentType(
    icon: Icons.poll_rounded,
    label: 'Encuesta',
    color: Color(0xFF34D399),
    lightColor: Color(0xFFECFDF5),
  );
  static const event = ContentType(
    icon: Icons.event_rounded,
    label: 'Evento',
    color: Color(0xFF7DD3FC),
    lightColor: Color(0xFFF0F9FF),
  );

  static const List<ContentType> values = [post, promo, story, live, poll, event];
}

class CreatorHubWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhoto;

  const CreatorHubWidget({
    super.key,
    this.userId = '',
    this.userName = '',
    this.userPhoto = '',
  });

  @override
  State<CreatorHubWidget> createState() => _CreatorHubWidgetState();
}

class _CreatorHubWidgetState extends State<CreatorHubWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _openCreator() {
    HapticFeedback.lightImpact();
    setState(() => _isOpen = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black38,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      builder: (_) => _CreatorSheet(
        userId: widget.userId,
        userName: widget.userName,
        userPhoto: widget.userPhoto,
        onClose: () {
          setState(() => _isOpen = false);
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _isOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Transform.scale(
        scale: _isOpen ? 0.0 : _pulseAnim.value,
        child: AnimatedOpacity(
          opacity: _isOpen ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
      ),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6EC6E8), Color(0xFF4DB8D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6EC6E8).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _openCreator,
            child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ───── SHEET ─────

class _CreatorSheet extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhoto;
  final VoidCallback onClose;

  const _CreatorSheet({
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.onClose,
  });

  @override
  State<_CreatorSheet> createState() => _CreatorSheetState();
}

class _CreatorSheetState extends State<_CreatorSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheetCtrl;
  ContentType? _selectedType;

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }

  void _selectType(ContentType type) {
    HapticFeedback.mediumImpact();
    setState(() => _selectedType = type);
  }

  void _goBack() {
    setState(() => _selectedType = null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sheetCtrl,
      builder: (context, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _sheetCtrl,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (current, previous) {
              return Stack(
                children: [
                  ...previous,
                  if (current != null) current,
                ],
              );
            },
            child: _selectedType == null
                ? _buildSelectionGrid()
                : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        key: const ValueKey('grid'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF6EC6E8).withOpacity(0.15),
                backgroundImage: widget.userPhoto.isNotEmpty
                    ? NetworkImage(widget.userPhoto)
                    : null,
                child: widget.userPhoto.isEmpty
                    ? Text(
                        widget.userName.isNotEmpty
                            ? widget.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFF6EC6E8),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              const Text(
                'Crear contenido',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  widget.onClose();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTypeGrid(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[250],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTypeGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 3;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(ContentType.values.length, (i) {
            final type = ContentType.values[i];
            return _AnimatedTypeCard(
              type: type,
              width: cardWidth,
              delay: i * 60,
              onTap: () => _selectType(type),
            );
          }),
        );
      },
    );
  }

  Widget _buildForm() {
    final type = _selectedType!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        key: ValueKey('form_${type.label}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _goBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: type.lightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back_rounded, size: 18, color: type.color),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type.lightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(type.icon, size: 20, color: type.color),
              ),
              const SizedBox(width: 8),
              Text(
                type.label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: type.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildFormBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBody() {
    return switch (_selectedType!) {
      ContentType.post => _PostForm(
          userId: widget.userId,
          userName: widget.userName,
          userPhoto: widget.userPhoto,
        ),
      ContentType.promo => _PromoForm(userId: widget.userId),
      ContentType.story => _StoryForm(
          userId: widget.userId,
          userPhoto: widget.userPhoto,
        ),
      ContentType.live => _LiveForm(userId: widget.userId),
      ContentType.poll => _PollForm(userId: widget.userId),
      ContentType.event => _EventForm(userId: widget.userId),
      _ => const SizedBox.shrink(),
    };
  }
}

// ───── TYPE CARD ─────

class _AnimatedTypeCard extends StatefulWidget {
  final ContentType type;
  final double width;
  final int delay;
  final VoidCallback onTap;

  const _AnimatedTypeCard({
    required this.type,
    required this.width,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_AnimatedTypeCard> createState() => _AnimatedTypeCardState();
}

class _AnimatedTypeCardState extends State<_AnimatedTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    ));
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: widget.width,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
              decoration: BoxDecoration(
                color: widget.type.lightColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.type.color.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.type.icon, color: widget.type.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.type.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.type.color.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───── FIREBASE MIXIN ─────

mixin _FirebasePublish<T extends StatefulWidget> on State<T> {
  bool _isPublishing = false;

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<String?> _uploadImage(Uint8List bytes, String path) async {
    final ref = _storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Widget _buildLoadingOverlay() {
    return _isPublishing
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(width: 10),
                Text('Publicando...', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  void _showSuccess(String label, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text('$label publicad',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(dynamic e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: const Color(0xFFFB7185),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ───── POST FORM ─────

class _PostForm extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhoto;
  const _PostForm({required this.userId, required this.userName, required this.userPhoto});

  @override
  State<_PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<_PostForm> with _FirebasePublish {
  final _ctrl = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _publish() async {
    HapticFeedback.heavyImpact();
    setState(() => _isPublishing = true);
    try {
      String? imageUrl;
      if (_imageBytes != null) {
        imageUrl = await _uploadImage(
          _imageBytes!,
          'posts/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }
      final data = {
        'userId': widget.userId,
        'title': 'Post',
        'description': _ctrl.text.trim(),
        'imageUrls': imageUrl != null ? [imageUrl] : [],
        'tempPaths': [],
        'likesCount': 0,
        'commentsCount': 0,
        'sharesCount': 0,
        'likedBy': <String>[],
        'city': '',
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('posts').add(data);
      if (mounted) {
        _showSuccess('Post', const Color(0xFFA78BFA));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFA78BFA).withOpacity(0.15),
              backgroundImage: widget.userPhoto.isNotEmpty
                  ? NetworkImage(widget.userPhoto)
                  : null,
              child: widget.userPhoto.isEmpty
                  ? Text(widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : '?',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFA78BFA)))
                  : null,
            ),
            const SizedBox(width: 8),
            Text(widget.userName,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _ctrl,
          maxLines: 5,
          minLines: 3,
          style: const TextStyle(fontSize: 14, height: 1.4),
          decoration: InputDecoration(
            hintText: '¿Qué quieres compartir?',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 10),
        if (_imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.memory(_imageBytes!,
                    height: 140, width: double.infinity, fit: BoxFit.cover),
                Positioned(
                  top: 6, right: 6,
                  child: GestureDetector(
                    onTap: () => setState(() => _imageBytes = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            _ActionButton(
              icon: Icons.image_outlined,
              label: 'Imagen',
              color: const Color(0xFFA78BFA),
              onTap: _pickImage,
            ),
            const Spacer(),
            _buildLoadingOverlay(),
            if (!_isPublishing)
              _PublishButton(
                onTap: _publish,
                color: const Color(0xFFA78BFA),
              ),
          ],
        ),
      ],
    );
  }
}

// ───── PROMO FORM ─────

class _PromoForm extends StatefulWidget {
  final String userId;
  const _PromoForm({required this.userId});

  @override
  State<_PromoForm> createState() => _PromoFormState();
}

class _PromoFormState extends State<_PromoForm> with _FirebasePublish {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200, maxHeight: 1200, imageQuality: 80,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _publish() async {
    HapticFeedback.heavyImpact();
    setState(() => _isPublishing = true);
    try {
      String? imageUrl;
      if (_imageBytes != null) {
        imageUrl = await _uploadImage(
          _imageBytes!,
          'promotions/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }
      final data = {
        'userId': widget.userId,
        'name': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'scope': 'profile',
        'isActive': true,
        'isFeatured': false,
        'imageUrls': imageUrl != null ? [imageUrl] : [],
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('promotions').add(data);
      if (mounted) {
        _showSuccess('Promoción', const Color(0xFFFBBF24));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Field(_titleCtrl, 'Título de la promo', Icons.card_giftcard, const Color(0xFFFBBF24)),
        const SizedBox(height: 10),
        _Field(_descCtrl, 'Descripción', Icons.description, const Color(0xFFFBBF24), maxLines: 3),
        const SizedBox(height: 10),
        _Field(_priceCtrl, 'Precio', Icons.attach_money, const Color(0xFFFBBF24), isNumber: true),
        const SizedBox(height: 10),
        if (_imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.memory(_imageBytes!, height: 120, width: double.infinity, fit: BoxFit.cover),
                Positioned(
                  top: 6, right: 6,
                  child: GestureDetector(
                    onTap: () => setState(() => _imageBytes = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            _ActionButton(icon: Icons.image_outlined, label: 'Imagen',
                color: const Color(0xFFFBBF24), onTap: _pickImage),
            const Spacer(),
            _buildLoadingOverlay(),
            if (!_isPublishing)
              _PublishButton(onTap: _publish, color: const Color(0xFFFBBF24)),
          ],
        ),
      ],
    );
  }
}

// ───── STORY FORM ─────

class _StoryForm extends StatefulWidget {
  final String userId;
  final String userPhoto;
  const _StoryForm({required this.userId, required this.userPhoto});

  @override
  State<_StoryForm> createState() => _StoryFormState();
}

class _StoryFormState extends State<_StoryForm> with _FirebasePublish {
  final _picker = ImagePicker();
  Uint8List? _imageBytes;

  Future<void> _pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200, maxHeight: 1200, imageQuality: 80,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200, maxHeight: 1200, imageQuality: 80,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _publish() async {
    if (_imageBytes == null) return;
    HapticFeedback.heavyImpact();
    setState(() => _isPublishing = true);
    try {
      final imageUrl = await _uploadImage(
        _imageBytes!,
        'stories/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final data = {
        'userId': widget.userId,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
      };
      await _firestore.collection('stories').add(data);
      if (mounted) {
        _showSuccess('Historia', const Color(0xFFF472B6));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _imageBytes == null ? _pickFromGallery : null,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(18),
              image: _imageBytes != null
                  ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                  : null,
              border: Border.all(color: const Color(0xFFF472B6).withOpacity(0.15)),
            ),
            child: _imageBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF472B6).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_photo_alternate_outlined,
                            size: 36, color: const Color(0xFFF472B6).withOpacity(0.6)),
                      ),
                      const SizedBox(height: 10),
                      Text('Agregar imagen',
                          style: TextStyle(color: const Color(0xFFF472B6).withOpacity(0.7))),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 16),
        if (_imageBytes != null) ...[
          _buildLoadingOverlay(),
          if (!_isPublishing)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(icon: Icons.camera_alt_outlined, label: 'Cambiar',
                    color: const Color(0xFFF472B6), onTap: _pickFromCamera),
                const SizedBox(width: 12),
                _ActionButton(icon: Icons.photo_library_outlined, label: 'Galería',
                    color: const Color(0xFFF472B6), onTap: _pickFromGallery),
                const SizedBox(width: 12),
                _PublishButton(onTap: _publish, color: const Color(0xFFF472B6), label: 'Publicar'),
              ],
            ),
        ],
      ],
    );
  }
}

// ───── LIVE FORM ─────

class _LiveForm extends StatefulWidget {
  final String userId;
  const _LiveForm({required this.userId});

  @override
  State<_LiveForm> createState() => _LiveFormState();
}

class _LiveFormState extends State<_LiveForm> with _FirebasePublish {
  final _titleCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _goLive() async {
    HapticFeedback.heavyImpact();
    setState(() => _isPublishing = true);
    try {
      final data = {
        'userId': widget.userId,
        'title': _titleCtrl.text.trim(),
        'isLive': true,
        'startedAt': FieldValue.serverTimestamp(),
        'viewers': 0,
      };
      await _firestore.collection('live').add(data);
      if (mounted) {
        _showSuccess('Transmisión en vivo', const Color(0xFFFB7185));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFB7185).withOpacity(0.15)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LivePulseIndicator(),
                const SizedBox(height: 10),
                Text(
                  'Conecta con tu audiencia\ntiempo real',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFFB7185).withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _Field(_titleCtrl, 'Título de la transmisión', Icons.videocam_rounded,
            const Color(0xFFFB7185)),
        const SizedBox(height: 16),
        _buildLoadingOverlay(),
        if (!_isPublishing)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _goLive,
              icon: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              label: const Text('Iniciar transmisión',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB7185),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
      ],
    );
  }
}

class _LivePulseIndicator extends StatefulWidget {
  @override
  State<_LivePulseIndicator> createState() => _LivePulseIndicatorState();
}

class _LivePulseIndicatorState extends State<_LivePulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFB7185).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFB7185).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color.lerp(
                  const Color(0xFFFB7185),
                  const Color(0xFFE11D48),
                  _ctrl.value,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFB7185).withOpacity(0.4 * _ctrl.value),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'EN VIVO',
            style: TextStyle(
              color: const Color(0xFFFB7185).withOpacity(0.9),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── POLL FORM ─────

class _PollForm extends StatefulWidget {
  final String userId;
  const _PollForm({required this.userId});

  @override
  State<_PollForm> createState() => _PollFormState();
}

class _PollFormState extends State<_PollForm> with _FirebasePublish {
  final _questionCtrl = TextEditingController();
  final _optionCtrl = TextEditingController();
  final List<String> _options = [];

  @override
  void dispose() {
    _questionCtrl.dispose();
    _optionCtrl.dispose();
    super.dispose();
  }

  void _addOption() {
    final t = _optionCtrl.text.trim();
    if (t.isNotEmpty && _options.length < 6) {
      setState(() {
        _options.add(t);
        _optionCtrl.clear();
      });
    }
  }

  void _removeOption(int i) => setState(() => _options.removeAt(i));

  Future<void> _publish() async {
    HapticFeedback.heavyImpact();
    setState(() => _isPublishing = true);
    try {
      final data = {
        'userId': widget.userId,
        'question': _questionCtrl.text.trim(),
        'options': _options.map((o) => {'text': o, 'votes': 0}).toList(),
        'votesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('polls').add(data);
      if (mounted) {
        _showSuccess('Encuesta', const Color(0xFF34D399));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Field(_questionCtrl, 'Tu pregunta', Icons.help_outline, const Color(0xFF34D399),
            maxLines: 2),
        const SizedBox(height: 14),
        ..._options.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF34D399).withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: const Color(0xFF34D399)),
                const SizedBox(width: 8),
                Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13))),
                GestureDetector(
                  onTap: () => _removeOption(e.key),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFFFB7185)),
                ),
              ],
            ),
          ),
        )),
        if (_options.length < 6)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _optionCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Opción ${_options.length + 1}',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onSubmitted: (_) => _addOption(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  onPressed: _addOption,
                ),
              ),
            ],
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('${_options.length}/6 opciones',
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            const Spacer(),
            _buildLoadingOverlay(),
            if (!_isPublishing)
              _PublishButton(onTap: _publish, color: const Color(0xFF34D399), label: 'Crear'),
          ],
        ),
      ],
    );
  }
}

// ───── EVENT FORM ─────

class _EventForm extends StatefulWidget {
  final String userId;
  const _EventForm({required this.userId});

  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> with _FirebasePublish {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF7DD3FC)),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF7DD3FC)),
        ),
        child: child!,
      ),
    );
    if (time != null && mounted) setState(() => _selectedTime = time);
  }

  Future<void> _publish() async {
    HapticFeedback.heavyImpact();
    setState(() => _isPublishing = true);
    try {
      final data = {
        'userId': widget.userId,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'time': _selectedTime != null
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('events').add(data);
      if (mounted) {
        _showSuccess('Evento', const Color(0xFF7DD3FC));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Field(_titleCtrl, 'Título del evento', Icons.event, const Color(0xFF7DD3FC)),
        const SizedBox(height: 10),
        _Field(_descCtrl, 'Descripción', Icons.description, const Color(0xFF7DD3FC), maxLines: 3),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _DateTile(
              icon: Icons.calendar_today,
              label: _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}'
                  : 'Fecha',
              hasValue: _selectedDate != null,
              onTap: _pickDate,
            )),
            const SizedBox(width: 8),
            Expanded(child: _DateTile(
              icon: Icons.access_time,
              label: _selectedTime != null
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : 'Hora',
              hasValue: _selectedTime != null,
              onTap: _pickTime,
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Spacer(),
            _buildLoadingOverlay(),
            if (!_isPublishing)
              _PublishButton(onTap: _publish, color: const Color(0xFF7DD3FC), label: 'Crear evento'),
          ],
        ),
      ],
    );
  }
}

// ───── SHARED WIDGETS ─────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color color;
  final int maxLines;
  final bool isNumber;

  const _Field(this.controller, this.hint, this.icon, this.color,
      {this.maxLines = 1, this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          child: Icon(icon, size: 18, color: color.withOpacity(0.6)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool hasValue;
  final VoidCallback onTap;

  const _DateTile({
    required this.icon, required this.label,
    required this.hasValue, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: hasValue
              ? const Color(0xFF7DD3FC).withOpacity(0.08)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: hasValue
              ? Border.all(color: const Color(0xFF7DD3FC).withOpacity(0.2))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: hasValue
                ? const Color(0xFF7DD3FC)
                : Colors.grey[400]),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              fontSize: 13,
              color: hasValue ? const Color(0xFF3B82F6) : Colors.grey[500],
              fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}

class _PublishButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  final String label;

  const _PublishButton({
    required this.onTap,
    required this.color,
    this.label = 'Publicar',
  });

  @override
  State<_PublishButton> createState() => _PublishButtonState();
}

class _PublishButtonState extends State<_PublishButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}
