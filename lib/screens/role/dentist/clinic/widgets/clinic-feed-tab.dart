import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medident/screens/widgets/post-actions/post-actions-widget.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/clinic/clinic-provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/screens/shared/post-detail-screen.dart';
import 'package:medident/screens/role/dentist/clinic/treatments-screen.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/clinic_attendance_widget.dart';

// ─── Tipos de publicación ─────────────────────────────────────
class _PostTypeOption {
  final IconData icon;
  final String label;
  final Color color;
  final String type;
  const _PostTypeOption(this.icon, this.label, this.color, this.type);
}

const _postTypes = [
  _PostTypeOption(Icons.edit_note, 'Pensar', Color(0xFF1DA1F2), 'penser'),
  _PostTypeOption(Icons.camera_alt_rounded, 'Foto', Color(0xFFE11B48), 'photo'),
  _PostTypeOption(Icons.event_rounded, 'Evento', Color(0xFFF59E0B), 'event'),
  _PostTypeOption(Icons.poll_rounded, 'Encuesta', Color(0xFF10B981), 'poll'),
  _PostTypeOption(Icons.link_rounded, 'Enlace', Color(0xFF6366F1), 'link'),
  _PostTypeOption(Icons.group_add_rounded, 'Apoyo', Color(0xFF06B6D4), 'apoyo'),
  _PostTypeOption(Icons.groups_rounded, 'Grupo', Color(0xFFF97316), 'grupo'),
  _PostTypeOption(Icons.live_tv_rounded, 'Streaming', Color(0xFFEF4444), 'streaming'),
  _PostTypeOption(Icons.videocam_rounded, 'Video', Color(0xFFFF6B6B), 'video'),
];

class ClinicFeedTab extends StatelessWidget {
  const ClinicFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final clinicId = context.select<ClinicProvider, String>((p) => p.clinic?.id ?? '');
    final user = context.watch<AuthenticateProvider>().user;

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: handle),
        SliverToBoxAdapter(child: ClinicAttendanceWidget(clinicId: clinicId)),
        SliverToBoxAdapter(child: _CreatePostSection(user: user, clinicId: clinicId)),
        _ClinicFeed(clinicId: clinicId, isOwner: context.select<ClinicProvider, bool>((p) => p.isOwner), user: user),
        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }
}

// ─── SECCIÓN DE CREACIÓN (grid de opciones) ───────────────────
class _CreatePostSection extends StatefulWidget {
  final UserModel? user;
  final String clinicId;
  const _CreatePostSection({required this.user, required this.clinicId});

  @override
  State<_CreatePostSection> createState() => _CreatePostSectionState();
}

class _CreatePostSectionState extends State<_CreatePostSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  _PostTypeOption? _selectedType;
  final _textCtrl = TextEditingController();
  final _picker = ImagePicker();
  List<String> _uploadedImageUrls = [];
  bool _isPosting = false;

  String get _userId => widget.user?.uid ?? '';
  String get _userName => widget.user?.fullName ?? '';
  String get _userPhoto => widget.user?.imageUrl ?? '';

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final imgs = await _picker.pickMultiImage(maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (imgs.isEmpty) return;
    final storage = FirebaseStorage.instance;
    final ts = DateTime.now().millisecondsSinceEpoch;
    final urls = <String>[];
    for (var i = 0; i < imgs.length && i < 10; i++) {
      final bytes = await imgs[i].readAsBytes();
      final ref = storage.ref('posts/clinics/${widget.clinicId}/${ts}_$i.jpg');
      await ref.putData(bytes);
      urls.add(await ref.getDownloadURL());
    }
    if (mounted) setState(() => _uploadedImageUrls = urls);
  }

  Future<void> _publish() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty && _uploadedImageUrls.isEmpty) return;
    setState(() => _isPosting = true);
    try {
      await context.read<ClinicProvider>().createClinicPost(
        createdBy: _userId,
        userName: _userName,
        userPhoto: _userPhoto,
        type: _selectedType?.type ?? 'penser',
        description: text,
        imageUrls: _uploadedImageUrls.isNotEmpty ? _uploadedImageUrls : null,
      );
      setState(() {
        _textCtrl.clear();
        _uploadedImageUrls = [];
        _selectedType = null;
        _expanded = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('¡Publicado en la clínica!'), backgroundColor: const Color(0xFF0EA5A4)),
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
    final color = _selectedType?.color ?? const Color(0xFF0EA5A4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // ── Botón de expandir / colapsar ──
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: _userPhoto.isNotEmpty ? NetworkImage(_userPhoto) : null,
                    child: _userPhoto.isEmpty
                        ? Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _expanded ? '¿Qué quieres compartir?' : 'Comparte algo con la clínica...',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_up, color: const Color(0xFF0EA5A4), size: 24),
                  ),
                ]),
              ),
            ),

            // ── Grid de tipos y formulario (expandido) ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    // Grid de tipos
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _postTypes.length,
                      itemBuilder: (_, i) {
                        final t = _postTypes[i];
                        final active = _selectedType == t;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = active ? null : t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: active ? t.color : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active ? t.color : Colors.grey[200]!,
                                width: active ? 0 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(t.icon, size: 16, color: active ? Colors.white : Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(t.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: active ? Colors.white : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Campo de texto
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _textCtrl,
                        maxLines: 3,
                        minLines: 2,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                        decoration: InputDecoration(
                          hintText: _selectedType != null
                              ? 'Escribe sobre ${_selectedType!.label.toLowerCase()}...'
                              : '¿Qué quieres compartir?',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    // Images preview
                    if (_uploadedImageUrls.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _uploadedImageUrls.length,
                          itemBuilder: (_, i) => Stack(
                            children: [
                              Container(
                                width: 48, height: 48, margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(_uploadedImageUrls[i]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0, right: 6,
                                child: GestureDetector(
                                  onTap: () => setState(() => _uploadedImageUrls.removeAt(i)),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Botones de acción
                    Row(children: [
                      // Image picker button
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11B48).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.image_outlined, size: 20, color: Color(0xFFE11B48)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Spacer(),
                      // Publicar
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: (_textCtrl.text.trim().isNotEmpty || _uploadedImageUrls.isNotEmpty) && !_isPosting
                              ? _publish : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isPosting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(_selectedType?.icon ?? Icons.send_rounded, size: 16),
                                  const SizedBox(width: 6),
                                  const Text('Publicar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ]),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FEED DE LA CLÍNICA (desde ClinicProvider) ───────────────
class _ClinicFeed extends StatelessWidget {
  final String clinicId;
  final bool isOwner;
  final UserModel? user;
  const _ClinicFeed({required this.clinicId, required this.isOwner, required this.user});

  @override
  Widget build(BuildContext context) {
    if (clinicId.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final feed = context.watch<ClinicProvider>().clinicFeed;

    if (feed.isEmpty) {
      return SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(child: Column(children: [
          Icon(Icons.post_add, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Sin contenido aún. Crea tu primera publicación.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14), textAlign: TextAlign.center),
        ])),
      ));
    }

    final postsCount = feed.length;
    final totalItems = postsCount + (postsCount >= 3 ? 2 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 2 && postsCount >= 3) {
          return _ClinicStatsSection(clinicId: clinicId);
        }
        if (index == postsCount + 1 && postsCount >= 3) {
          return _ClinicServicesCarousel(clinicId: clinicId);
        }
        final postIndex = index > 2 ? index - 2 : index;
        if (postIndex >= postsCount) return const SizedBox.shrink();

        final data = feed[postIndex];
        data['id'] = data['id'];
        final type = data['type'] as String? ?? 'penser';
        final isFeatured = postIndex == 0 && data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty;

        return isFeatured
            ? _FeaturedCard(
                postId: data['id'] as String? ?? '',
                data: data,
                userId: user?.uid ?? '',
                userName: user?.fullName ?? '',
                userPhoto: user?.imageUrl ?? '',
                child: _buildCardContent(type, data, isOwner, user?.uid ?? ''),
              )
            : _CardWrapper(
                postId: data['id'] as String? ?? '',
                data: data,
                userId: user?.uid ?? '',
                userName: user?.fullName ?? '',
                userPhoto: user?.imageUrl ?? '',
                child: _buildCardContent(type, data, isOwner, user?.uid ?? ''),
              );
      }, childCount: totalItems),
    );
  }

  Widget _buildCardContent(String type, Map<String, dynamic> data, bool isOwner, String userUid) {
    switch (type) {
      case 'photo':
      case 'penser':
        return _PostCardContent(data: data);
      case 'event':
        return _EventCardContent(data: data);
      case 'video':
        return _ReelCardContent(data: data);
      case 'poll':
        return _PollCardContent(data: data);
      case 'link':
        return _LinkCardContent(data: data);
      case 'apoyo':
        return _ApoyoCardContent(data: data);
      case 'grupo':
        return _GrupoCardContent(data: data);
      case 'streaming':
        return _StreamingCardContent(data: data);
      default:
        return _PostCardContent(data: data);
    }
  }
}

// ─── CLINIC STATS SECTION ───────────────────────────────

class _ClinicStatsSection extends StatelessWidget {
  final String clinicId;
  const _ClinicStatsSection({required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: 90,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('posts').where('clinicId', isEqualTo: clinicId).snapshots(),
          builder: (context, snap) {
            final totalPosts = snap.data?.docs.length ?? 0;
            return Row(children: [
              _StatCard(icon: Icons.post_add_outlined, label: 'Publicaciones', value: '$totalPosts', color: const Color(0xFF4F46E5)),
              const SizedBox(width: 10),
              _StatCard(icon: Icons.favorite_outline, label: 'Me gusta', value: '--', color: const Color(0xFFE11B48)),
              const SizedBox(width: 10),
              _StatCard(icon: Icons.photo_library_outlined, label: 'Fotos', value: '--', color: const Color(0xFF10B981)),
            ]);
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        ]),
      ),
    );
  }
}

// ─── CLINIC SERVICES CAROUSEL ────────────────────────────

class _ClinicServicesCarousel extends StatelessWidget {
  final String clinicId;
  const _ClinicServicesCarousel({required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.medical_services_outlined, size: 18, color: Color(0xFF0EA5A4)),
            const SizedBox(width: 6),
            const Text('Servicios', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => TreatmentsScreen(clinicId: clinicId),
              )),
              child: Text('Ver todo', style: TextStyle(fontSize: 12, color: const Color(0xFF0EA5A4))),
            ),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('treatments')
                  .where('clinicId', isEqualTo: clinicId)
                  .where('isActive', isEqualTo: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return Center(child: Text('Sin servicios registrados', style: TextStyle(fontSize: 12, color: Colors.grey[400])));
                }
                final docs = snap.data!.docs;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  padding: const EdgeInsets.only(right: 16),
                  itemBuilder: (_, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final name = d['name'] as String? ?? 'Servicio';
                    final price = (d['price'] as num?) ?? 0;
                    final duration = d['durationMinutes'] as int? ?? 30;
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5A4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.medical_services_outlined, size: 20, color: const Color(0xFF0EA5A4)),
                            ),
                            const Spacer(),
                            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Row(children: [
                              Text('\$${price.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0EA5A4))),
                              const Spacer(),
                              Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 2),
                              Text('$duration min', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final String userId;
  final String userName;
  final String userPhoto;
  final Widget child;
  const _FeaturedCard({required this.postId, required this.data, required this.userId, required this.userName, required this.userPhoto, required this.child});

  @override
  Widget build(BuildContext context) {
    final imageUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => PostDetailScreen(
            postId: postId, data: data,
            userId: userId, userName: userName, userPhoto: userPhoto,
          ),
        )),
        child: Container(
          height: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: imageUrls.isNotEmpty
                ? DecorationImage(image: CachedNetworkImageProvider(imageUrls.first), fit: BoxFit.cover)
                : null,
            color: imageUrls.isNotEmpty ? null : Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.transparent],
            ),
          ),
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(radius: 16,
                    backgroundImage: (data['userPhoto'] as String? ?? '').isNotEmpty
                        ? NetworkImage(data['userPhoto'] as String)
                        : null,
                    child: Text(((data['userName'] as String? ?? data['createdBy'] as String? ?? 'U')[0]).toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.white))),
                  const SizedBox(width: 8),
                  Text(data['userName'] as String? ?? data['createdBy'] as String? ?? 'Usuario',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  _FeaturedTypeBadge(type: data['type'] as String? ?? 'penser'),
                ]),
                const SizedBox(height: 8),
                if ((data['description'] as String? ?? '').isNotEmpty)
                  Text(data['description'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, height: 1.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedTypeBadge extends StatelessWidget {
  final String type;
  const _FeaturedTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _typeColor(type).withOpacity(0.85), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_typeIconData(type), size: 11, color: Colors.white),
        const SizedBox(width: 3),
        Text(_typeShortLabel(type), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

String _typeShortLabel(String type) {
  switch (type) {
    case 'photo': return 'FOTO';
    case 'event': return 'EVENTO';
    case 'video': return 'REEL';
    case 'poll': return 'ENCUESTA';
    case 'link': return 'ENLACE';
    case 'apoyo': return 'APOYO';
    case 'grupo': return 'GRUPO';
    case 'streaming': return 'EN VIVO';
    default: return 'POST';
  }
}

IconData _typeIconData(String type) {
  switch (type) {
    case 'photo': return Icons.image_rounded;
    case 'event': return Icons.event_rounded;
    case 'video': return Icons.play_circle_rounded;
    case 'poll': return Icons.poll_rounded;
    case 'link': return Icons.link_rounded;
    case 'apoyo': return Icons.group_add_rounded;
    case 'grupo': return Icons.groups_rounded;
    case 'streaming': return Icons.videocam_rounded;
    default: return Icons.article_rounded;
  }
}

Color _typeColor(String type) {
  switch (type) {
    case 'event': return const Color(0xFFF59E0B);
    case 'video': return const Color(0xFF8B5CF6);
    case 'poll': return const Color(0xFF10B981);
    case 'link': return const Color(0xFF3B82F6);
    case 'apoyo': return const Color(0xFF06B6D4);
    case 'grupo': return const Color(0xFFF97316);
    case 'streaming': return const Color(0xFFEF4444);
    default: return const Color(0xFF6B7280);
  }
}

class _CardWrapper extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final String userId;
  final String userName;
  final String userPhoto;
  final Widget child;
  const _CardWrapper({required this.postId, required this.data, required this.userId, required this.userName, required this.userPhoto, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => PostDetailScreen(
            postId: postId, data: data,
            userId: userId, userName: userName, userPhoto: userPhoto,
          ),
        )),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            child,
            PostActionsWidget(postId: postId, userId: userId, userName: userName, userPhoto: userPhoto),
          ]),
        ),
      ),
    );
  }
}

// ─── HELPERS ──────────────────────────────────────────────

Widget _userHeader(Map<String, dynamic> data) {
  final name = data['userName'] as String? ?? data['createdBy'] as String? ?? 'Usuario';
  final photo = data['userPhoto'] as String? ?? '';
  final time = data['createdAt'] != null ? _formatTime(data['createdAt']) : '';
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      CircleAvatar(radius: 15, backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null, child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 12))),
      const SizedBox(width: 8),
      Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const Spacer(),
      if (time.isNotEmpty) Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
    ]),
  );
}

String _formatTime(dynamic value) {
  if (value == null) return '';
  DateTime dt;
  if (value is Timestamp) {
    dt = value.toDate();
  } else if (value is DateTime) {
    dt = value;
  } else {
    return '';
  }
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

// ─── POST (text/image) ───────────────────────────────────

class _PostCardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PostCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final imgUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    final desc = data['description'] as String? ?? '';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: _userHeader(data)),
      if (desc.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text(desc, style: const TextStyle(fontSize: 14, height: 1.4))),
      if (imgUrls.isNotEmpty)
        ClipRRect(borderRadius: BorderRadius.circular(0),
          child: SizedBox(height: 250, width: double.infinity,
            child: CachedNetworkImage(imageUrl: imgUrls.first, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)))),
        ),
    ]);
  }
}

// ─── EVENTO ──────────────────────────────────────────────

class _EventCardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _EventCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final imgUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    final desc = data['description'] as String? ?? '';
    final date = (data['eventDate'] as Timestamp?)?.toDate();
    final location = data['location'] as String?;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: Color(0xFFF59E0B), borderRadius: BorderRadius.vertical(top: Radius.circular(13))),
        child: Row(children: [
          const Icon(Icons.event_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(date != null ? '${date.day}/${date.month}/${date.year}' : 'Evento', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (location != null) Text(location, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 14, height: 1.4)),
        if (imgUrls.isNotEmpty) ...[const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(height: 180, width: double.infinity,
            child: CachedNetworkImage(imageUrl: imgUrls.first, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[200])))),
        ],
      ])),
    ]);
  }
}

// ─── REEL ─────────────────────────────────────────────────

class _ReelCardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ReelCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final desc = data['description'] as String? ?? '';
    final imgUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: _userHeader(data)),
      Stack(alignment: Alignment.center, children: [
        if (imgUrls.isNotEmpty)
          ClipRRect(borderRadius: BorderRadius.circular(0), child: SizedBox(height: 250, width: double.infinity,
            child: CachedNetworkImage(imageUrl: imgUrls.first, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[200])))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text('Ver Reel', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
      if (desc.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text(desc, style: const TextStyle(fontSize: 13))),
    ]);
  }
}

// ─── POLL ─────────────────────────────────────────────────

class _PollCardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PollCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final question = data['description'] as String? ?? data['question'] as String? ?? '';
    final options = (data['options'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: Row(children: [
        const Icon(Icons.poll_rounded, size: 18, color: Color(0xFF10B981)),
        const SizedBox(width: 6),
        const Text('Encuesta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
      ])),
      if (question.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: Text(question, style: const TextStyle(fontSize: 14))),
      ...options.take(4).map((opt) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Text(opt['text'] as String? ?? '', style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Text('${opt['votes'] ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ]),
        ),
      )),
      const SizedBox(height: 8),
    ]);
  }
}

// ─── LINK ─────────────────────────────────────────────────

class _LinkCardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _LinkCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final url = data['url'] as String? ?? '';
    final desc = data['description'] as String? ?? '';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: _userHeader(data)),
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text(desc, style: const TextStyle(fontSize: 14))),
      if (url.isNotEmpty)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
          child: Row(children: [
            const Icon(Icons.link, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(url, style: const TextStyle(color: Colors.blue, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
    ]);
  }
}

// ─── APOYO ───────────────────────────────────────────────

class _ApoyoCardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ApoyoCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '';
    final desc = data['description'] as String? ?? '';
    final contact = data['contact'] as String? ?? '';
    final members = data['membersCount'] as int? ?? 0;
    final imgUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: Color(0xFF06B6D4), borderRadius: BorderRadius.vertical(top: Radius.circular(13))),
        child: Row(children: [
          const Icon(Icons.group_add_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(child: Text(name.isNotEmpty ? name : 'Grupo de Apoyo', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 14, height: 1.4)),
        if (imgUrls.isNotEmpty) ...[const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(height: 160, width: double.infinity,
            child: CachedNetworkImage(imageUrl: imgUrls.first, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[200])))),
        ],
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.people, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text('$members miembros', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          if (contact.isNotEmpty) ...[
            const Spacer(),
            Icon(Icons.contact_phone_outlined, size: 16, color: const Color(0xFF06B6D4)),
            const SizedBox(width: 4),
            Text(contact, style: const TextStyle(fontSize: 12, color: Color(0xFF06B6D4))),
          ],
        ]),
      ])),
    ]);
  }
}

// ─── GRUPO ───────────────────────────────────────────────

class _GrupoCardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _GrupoCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '';
    final desc = data['description'] as String? ?? '';
    final members = data['membersCount'] as int? ?? 0;
    final imgUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: Color(0xFFF97316), borderRadius: BorderRadius.vertical(top: Radius.circular(13))),
        child: Row(children: [
          const Icon(Icons.groups_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(child: Text(name.isNotEmpty ? name : 'Grupo', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 14, height: 1.4)),
        if (imgUrls.isNotEmpty) ...[const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(height: 160, width: double.infinity,
            child: CachedNetworkImage(imageUrl: imgUrls.first, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[200])))),
        ],
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.people, size: 16, color: Color(0xFFF97316)),
          const SizedBox(width: 4),
          Text('$members miembros', style: const TextStyle(fontSize: 12, color: Color(0xFFF97316))),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(6)),
            child: const Text('Unirse', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      ])),
    ]);
  }
}

// ─── STREAMING ───────────────────────────────────────────

class _StreamingCardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _StreamingCardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '';
    final desc = data['description'] as String? ?? '';
    final streamUrl = data['streamUrl'] as String? ?? '';
    final isLive = data['isLive'] as bool? ?? false;
    final imgUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: Color(0xFFEF4444), borderRadius: BorderRadius.vertical(top: Radius.circular(13))),
        child: Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('EN VIVO', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(name.isNotEmpty ? name : 'Streaming', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 14, height: 1.4)),
        if (imgUrls.isNotEmpty) ...[const SizedBox(height: 12),
          Stack(alignment: Alignment.center, children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(height: 200, width: double.infinity,
              child: CachedNetworkImage(imageUrl: imgUrls.first, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[200])))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 6),
                Text(isLive ? 'Ver ahora' : 'Ver grabación', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ],
        if (streamUrl.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.link, size: 14, color: Color(0xFFEF4444)),
              const SizedBox(width: 6),
              Expanded(child: Text(streamUrl, style: TextStyle(color: Colors.blue, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ],
      ])),
    ]);
  }
}
