import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/core/services/clinic-service.dart';

class TreatmentsScreen extends StatefulWidget {
  final String clinicId;
  const TreatmentsScreen({super.key, required this.clinicId});

  @override
  State<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends State<TreatmentsScreen> with TickerProviderStateMixin {
  final _clinicService = ClinicService();
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const _categories = [
    'Todos', 'Consulta', 'Limpieza', 'Estética',
    'Ortodoncia', 'Endodoncia', 'Cirugía', 'Implantes',
  ];
  static const _categoryIcons = [
    Icons.spa, Icons.medical_services, Icons.cleaning_services, Icons.face,
    Icons.motion_photos_on, Icons.monitor_heart, Icons.content_cut, Icons.mediation,
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length, vsync: this);
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
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
        title: const Text('Tratamientos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryTabs(),
          Expanded(child: _buildTreatmentsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: Colors.white,
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar tratamiento...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18, color: Colors.grey[400]),
                  onPressed: () { _searchCtrl.clear(); },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: const Color(0xFF0EA5A4),
        labelColor: const Color(0xFF0EA5A4),
        unselectedLabelColor: Colors.grey[500],
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: List.generate(_categories.length, (i) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_categoryIcons[i], size: 16),
              const SizedBox(width: 4),
              Text(_categories[i]),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildTreatmentsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _clinicService.streamTreatmentsByClinic(widget.clinicId),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('Sin tratamientos registrados', style: TextStyle(fontSize: 15, color: Colors.grey[500])),
              ],
            ),
          );
        }
        final treatments = docs.map((d) => TreatmentModel.fromJson(d.data(), d.id)).toList();
        final filtered = treatments.where((t) {
          final cat = _searchQuery.isNotEmpty
              ? t.name.toLowerCase().contains(_searchQuery) || t.description.toLowerCase().contains(_searchQuery)
              : true;
          final selectedCat = _categories[_tabCtrl.index];
          final catMatch = selectedCat == 'Todos'
              ? true
              : t.category.toLowerCase() == selectedCat.toLowerCase();
          return cat && catMatch;
        }).toList();
        if (filtered.isEmpty) {
          return Center(
            child: Text('Sin resultados', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          );
        }
        return AnimatedBuilder(
          animation: _tabCtrl,
          builder: (context, _) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _TreatmentCard(
                treatment: filtered[index],
                index: index,
              );
            },
          ),
        );
      },
    );
  }
}

class _TreatmentCard extends StatefulWidget {
  final TreatmentModel treatment;
  final int index;
  const _TreatmentCard({required this.treatment, required this.index});

  @override
  State<_TreatmentCard> createState() => _TreatmentCardState();
}

class _TreatmentCardState extends State<_TreatmentCard> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 50 * widget.index), _animCtrl.forward);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.treatment;
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showTreatmentDetail(context, t),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _buildIcon(t.iconName),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 13, color: Colors.grey[400]),
                              const SizedBox(width: 3),
                              Text('${t.durationMinutes} min', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              const SizedBox(width: 12),
                              Icon(Icons.category_outlined, size: 13, color: Colors.grey[400]),
                              const SizedBox(width: 3),
                              Text(t.category, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildPrice(t),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String iconName) {
    IconData icon;
    Color color;
    switch (iconName) {
      case 'cleaning': icon = Icons.cleaning_services; color = const Color(0xFF0EA5A4); break;
      case 'whitening': icon = Icons.face; color = const Color(0xFFF59E0B); break;
      case 'braces': icon = Icons.motion_photos_on; color = const Color(0xFF8B5CF6); break;
      case 'surgery': icon = Icons.content_cut; color = const Color(0xFFEF4444); break;
      case 'implant': icon = Icons.mediation; color = const Color(0xFF3B82F6); break;
      case 'root_canal': icon = Icons.monitor_heart; color = const Color(0xFFEC4899); break;
      default: icon = Icons.medical_services; color = const Color(0xFF0EA5A4);
    }
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildPrice(TreatmentModel t) {
    if (t.hasDiscount) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('\$${t.discountPrice!.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0EA5A4))),
          Text('\$${t.price.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[400], decoration: TextDecoration.lineThrough)),
        ],
      );
    }
    return Text('\$${t.price.toStringAsFixed(0)}',
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0EA5A4)));
  }

  void _showTreatmentDetail(BuildContext context, TreatmentModel t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TreatmentDetailSheet(treatment: t),
    );
  }
}

class _TreatmentDetailSheet extends StatelessWidget {
  final TreatmentModel treatment;
  const _TreatmentDetailSheet({required this.treatment});

  @override
  Widget build(BuildContext context) {
    final t = treatment;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF0EA5A4).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.medical_services, color: Color(0xFF0EA5A4), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('${t.durationMinutes} min', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(width: 16),
                    Icon(Icons.category_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(t.category, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          if (t.description.isNotEmpty) ...[
            Text(t.description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              if (t.hasDiscount) ...[
                Text('\$${t.discountPrice!.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0EA5A4))),
                const SizedBox(width: 10),
                Text('\$${t.price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400], decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${((1 - t.discountPrice! / t.price) * 100).round()}% OFF',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              ] else
                Text('\$${t.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0EA5A4))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5A4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Solicitar turno', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
