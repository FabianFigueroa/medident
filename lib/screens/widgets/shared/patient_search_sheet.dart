import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientSearchSheet extends StatefulWidget {
  final String clinicId;
  final void Function(String uid, String name, String? photo) onSelected;
  final String title;

  const PatientSearchSheet({
    super.key,
    required this.clinicId,
    required this.onSelected,
    this.title = 'Seleccionar Paciente',
  });

  @override
  State<PatientSearchSheet> createState() => _PatientSearchSheetState();
}

class _PatientSearchSheetState extends State<PatientSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _allPatients = [];
  String _query = '';
  bool _loaded = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _focusNode.requestFocus();
  }

  Future<void> _loadPatients() async {
    if (widget.clinicId.isEmpty) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .where('clinicId', isEqualTo: widget.clinicId)
          .limit(200)
          .get();
      if (!mounted) return;
      setState(() {
        _allPatients = snap.docs.map((d) {
          final data = d.data();
          return {
            'uid': d.id,
            'name': data['fullName'] ?? '',
            'photo': data['imageUrl'] as String? ?? '',
            'phone': data['phoneNumber'] as String? ?? '',
            'email': data['email'] as String? ?? '',
            'code': data['identificationNumber'] as String? ?? data['uniqueCode'] as String? ?? '',
          };
        }).toList();
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 80), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return _allPatients;
    final q = _query.toLowerCase();
    return _allPatients.where((p) {
      final name = (p['name'] as String).toLowerCase();
      final email = (p['email'] as String).toLowerCase();
      final code = (p['code'] as String).toLowerCase();
      final phone = (p['phone'] as String).toLowerCase();
      if (name.contains(q) || email.contains(q) || code.contains(q) || phone.contains(q)) return true;
      final parts = name.split(RegExp(r'[\s,]+'));
      return parts.any((part) => part.startsWith(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.people, size: 20, color: Color(0xFF0D9488)),
            ),
            const SizedBox(width: 10),
            Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchCtrl,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, email, teléfono o código...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 18, color: Colors.grey[400]),
                      onPressed: () { _searchCtrl.clear(); _onSearchChanged(''); },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              filled: true, fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildResults()),
      ]),
    );
  }

  Widget _buildResults() {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }

    final results = _filtered;

    if (_query.isNotEmpty && results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.person_search, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No se encontraron pacientes', style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('"$_query" no coincide con ningún registro', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'O ingresa nombre manualmente',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.edit, size: 18, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    widget.onSelected('walkin_${DateTime.now().millisecondsSinceEpoch}', v.trim(), null);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              _query.isEmpty
                  ? '${results.length} paciente${results.length == 1 ? '' : 's'}'
                  : '${results.length} resultado${results.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          );
        }
        final p = results[i - 1];
        final name = (p['name'] as String).isNotEmpty ? p['name'] as String : 'Sin nombre';
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              widget.onSelected(p['uid'] as String, name, p['photo'] as String?);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
                  backgroundImage: (p['photo'] as String).isNotEmpty
                      ? NetworkImage(p['photo'] as String) as ImageProvider
                      : null,
                  child: (p['photo'] as String).isEmpty
                      ? Text(name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.w700, fontSize: 16))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 2),
                    Row(children: [
                      if ((p['code'] as String).isNotEmpty) ...[
                        Text(p['code'] as String, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                      ],
                      if ((p['phone'] as String).isNotEmpty)
                        Text(p['phone'] as String, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ]),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Color(0xFF0D9488)),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
