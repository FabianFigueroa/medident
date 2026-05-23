import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medident/core/models/promotion-slide-model.dart';

class PromotionEditorScreen extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userPhoto;
  final String? clinicId;

  const PromotionEditorScreen({
    super.key,
    required this.userId,
    this.userName,
    this.userPhoto,
    this.clinicId,
  });

  @override
  State<PromotionEditorScreen> createState() => _PromotionEditorScreenState();
}

class _PromotionEditorScreenState extends State<PromotionEditorScreen> with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  late TabController _tabCtrl;
  final _picker = ImagePicker();

  List<_SlideData> _slides = [];
  bool _isPosting = false;
  DateTime? _validUntil;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _categoryCtrl.dispose();
    _termsCtrl.dispose();
    _tabCtrl.dispose();
    for (final s in _slides) {
      s.imageBytes?.clear();
    }
    super.dispose();
  }

  bool get _hasSlides => _slides.isNotEmpty;
  bool get _hasInfo => _nameCtrl.text.trim().isNotEmpty;

  Future<void> _addSlideFromCamera() async {
    final img = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (img != null) _addSlide(img);
  }

  Future<void> _addSlideFromGallery() async {
    final imgs = await _picker.pickMultiImage(maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    for (final img in imgs.take(10)) _addSlide(img);
  }

  void _addSlide(XFile file) {
    if (_slides.length >= 10) return;
    setState(() {
      _slides.add(_SlideData(
        file: file,
        titleCtrl: TextEditingController(),
        subtitleCtrl: TextEditingController(),
        priceCtrl: TextEditingController(),
        ctaCtrl: TextEditingController(),
      ));
      _tabCtrl.animateTo(1);
    });
  }

  void _removeSlide(int i) {
    setState(() {
      _slides[i].imageBytes?.clear();
      _slides[i].titleCtrl.dispose();
      _slides[i].subtitleCtrl.dispose();
      _slides[i].priceCtrl.dispose();
      _slides[i].ctaCtrl.dispose();
      _slides.removeAt(i);
    });
  }

  Future<List<PromotionSlide>> _uploadSlides() async {
    final storage = FirebaseStorage.instance;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final isClinic = widget.clinicId != null && widget.clinicId!.isNotEmpty;
    final results = <PromotionSlide>[];
    for (var i = 0; i < _slides.length; i++) {
      final s = _slides[i];
      if (s.file == null) continue;
      final ext = s.file!.path.split('.').last;
      final destination = isClinic
          ? 'promotions/clinics/${widget.clinicId}/slide_${timestamp}_$i.$ext'
          : 'promotions/users/${widget.userId}/slide_${timestamp}_$i.$ext';
      final ref = storage.ref(destination);
      await ref.putData(await s.file!.readAsBytes(), SettableMetadata(contentType: 'image/$ext'));
      final url = await ref.getDownloadURL();
      final price = double.tryParse(s.priceCtrl.text.trim());
      results.add(PromotionSlide(
        imageUrl: url,
        title: s.titleCtrl.text.trim().isNotEmpty ? s.titleCtrl.text.trim() : null,
        subtitle: s.subtitleCtrl.text.trim().isNotEmpty ? s.subtitleCtrl.text.trim() : null,
        price: price,
        discountPrice: _discountedPrice(price),
        ctaText: s.ctaCtrl.text.trim().isNotEmpty ? s.ctaCtrl.text.trim() : null,
        overlayPosition: s.overlayPosition,
        sortOrder: i,
      ));
    }
    return results;
  }

  double? _discountedPrice(double? price) {
    final disc = double.tryParse(_discountCtrl.text.trim());
    if (disc == null || price == null) return null;
    return price - (price * disc / 100);
  }

  Future<void> _publish() async {
    if (!_hasInfo || !_hasSlides) return;
    setState(() => _isPosting = true);
    try {
      final slides = await _uploadSlides();
      final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
      final imageUrls = slides.map((s) => s.imageUrl).toList();
      final isClinic = widget.clinicId != null && widget.clinicId!.isNotEmpty;
      final category = _categoryCtrl.text.trim();

      await FirebaseFirestore.instance.collection('promotions').add({
        'type': 'promo',
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': price,
        'discountPrice': _discountedPrice(price),
        'imageUrls': imageUrls,
        'slides': slides.map((s) => s.toMap()).toList(),
        'category': category.isNotEmpty ? category : null,
        'createdBy': widget.userId,
        'userName': widget.userName,
        'userPhoto': widget.userPhoto,
        'clinicId': isClinic ? widget.clinicId : '',
        'clinicName': null,
        'source': isClinic ? 'clinic' : 'user',
        'terms': _termsCtrl.text.trim().isNotEmpty ? _termsCtrl.text.trim() : null,
        'isFeatured': false,
        'isAvailable': true,
        'isActive': true,
        'scope': 'profile',
        'rating': null,
        'reviewsCount': 0,
        'expiresAt': _validUntil != null ? Timestamp.fromDate(_validUntil!) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Promoción publicada!'), backgroundColor: Color(0xFF0EA5A4)),
        );
      }
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
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nueva Promoción', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isPosting || !_hasInfo || !_hasSlides ? null : _publish,
              child: _isPosting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Publicar', style: TextStyle(fontWeight: FontWeight.w600, color: _hasInfo && _hasSlides ? const Color(0xFF0EA5A4) : Colors.grey[400])),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: const Color(0xFF0EA5A4),
              labelColor: const Color(0xFF0EA5A4),
              unselectedLabelColor: Colors.grey[500],
              tabs: const [
                Tab(icon: Icon(Icons.info_outline, size: 18), text: 'Información'),
                Tab(icon: Icon(Icons.view_carousel, size: 18), text: 'Slides'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildInfoTab(),
                _buildSlidesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card([
            _field('Nombre', _nameCtrl),
            _field('Descripción', _descCtrl, maxLines: 3),
            _field('Precio', _priceCtrl, keyboardType: TextInputType.number, prefix: '\$'),
            _field('Descuento %', _discountCtrl, keyboardType: TextInputType.number, suffix: '%'),
            _field('Categoría', _categoryCtrl),
            _field('Términos y condiciones', _termsCtrl, maxLines: 2),
          ]),
          const SizedBox(height: 12),
          _card([
            Row(
              children: [
                const Text('Válido hasta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _validUntil != null
                        ? '${_validUntil!.day}/${_validUntil!.month}/${_validUntil!.year}'
                        : 'Seleccionar fecha',
                    style: TextStyle(fontSize: 13, color: _validUntil != null ? const Color(0xFF0EA5A4) : Colors.grey[500]),
                  ),
                ),
                if (_validUntil != null)
                  IconButton(
                    icon: Icon(Icons.clear, size: 16, color: Colors.grey[400]),
                    onPressed: () => setState(() => _validUntil = null),
                  ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _validUntil = picked);
  }

  Widget _buildSlidesTab() {
    if (_slides.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Agrega imágenes para tu promoción', style: TextStyle(fontSize: 15, color: Colors.grey[500])),
            const SizedBox(height: 8),
            Text('Cada imagen puede tener su propio título y precio', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
            const SizedBox(height: 24),
            _addImageButtons(),
          ],
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('${_slides.length} slide${_slides.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              const Spacer(),
              _addImageButtons(compact: true),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _slides.length,
            itemBuilder: (_, i) => _buildSlideCard(i),
          ),
        ),
      ],
    );
  }

  Widget _addImageButtons({bool compact = false}) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _addSlideFromGallery,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF0EA5A4).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.photo_library_outlined, color: Color(0xFF0EA5A4), size: 18),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _addSlideFromCamera,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF0EA5A4).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF0EA5A4), size: 18),
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _imageButton('Galería', Icons.photo_library_outlined, _addSlideFromGallery),
        const SizedBox(width: 16),
        _imageButton('Cámara', Icons.camera_alt_outlined, _addSlideFromCamera),
      ],
    );
  }

  Widget _imageButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0EA5A4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF0EA5A4), size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF0EA5A4), fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideCard(int index) {
    final s = _slides[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: s.imageBytes != null
                    ? Image.memory(s.imageBytes!, fit: BoxFit.cover, width: double.infinity)
                    : FutureBuilder<Uint8List>(
                        future: s.file!.readAsBytes(),
                        builder: (_, snap) {
                          if (snap.hasData) {
                            s.imageBytes = snap.data;
                            return Image.memory(snap.data!, fit: BoxFit.cover, width: double.infinity);
                          }
                          return Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
                        },
                      ),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () => _removeSlide(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF0EA5A4).withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                  child: Text('Slide ${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _slideField('Título del slide', s.titleCtrl),
                const SizedBox(height: 8),
                _slideField('Subtítulo', s.subtitleCtrl, maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _slideField('Precio', s.priceCtrl, prefix: '\$', keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _overlayPositionDropdown(s),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _slideField('Texto del botón (CTA)', s.ctaCtrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlayPositionDropdown(_SlideData s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: s.overlayPosition,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          items: const [
            DropdownMenuItem(value: 'bottom', child: Text('Texto abajo')),
            DropdownMenuItem(value: 'center', child: Text('Texto centro')),
            DropdownMenuItem(value: 'top', child: Text('Texto arriba')),
            DropdownMenuItem(value: 'bottom-left', child: Text('Abajo izq.')),
          ],
          onChanged: (v) => setState(() => s.overlayPosition = v ?? 'bottom'),
        ),
      ),
    );
  }

  Widget _slideField(String hint, TextEditingController ctrl, {String? prefix, int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        prefixText: prefix,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? keyboardType, String? prefix, String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixText: prefix,
              suffixText: suffix,
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF0EA5A4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _SlideData {
  final XFile? file;
  Uint8List? imageBytes;
  final TextEditingController titleCtrl;
  final TextEditingController subtitleCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController ctaCtrl;
  String overlayPosition = 'bottom';

  _SlideData({
    this.file,
    required this.titleCtrl,
    required this.subtitleCtrl,
    required this.priceCtrl,
    required this.ctaCtrl,
  });
}
