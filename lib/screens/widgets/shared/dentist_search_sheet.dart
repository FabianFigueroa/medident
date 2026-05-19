import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DentistSearchSheet extends StatefulWidget {
  final String clinicId;
  final void Function(String uid, String name, String? photo) onSelected;
  final String title;

  const DentistSearchSheet({
    super.key,
    required this.clinicId,
    required this.onSelected,
    this.title = 'Seleccionar Especialista',
  });

  @override
  State<DentistSearchSheet> createState() => _DentistSearchSheetState();
}

class _DentistSearchSheetState extends State<DentistSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(children: [
            Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
            decoration: InputDecoration(
              hintText: 'Buscar especialista...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true, fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: widget.clinicId.isNotEmpty
                ? FirebaseFirestore.instance
                    .collection('users')
                    .where('role', whereIn: ['doctor', 'dentist'])
                    .where('clinicId', isEqualTo: widget.clinicId)
                    .snapshots()
                : null,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var dentists = snap.data!.docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                return {
                  'uid': d.id,
                  'name': data['fullName'] ?? 'Sin nombre',
                  'photo': data['imageUrl'] as String? ?? '',
                  'specialty': data['specialty'] as String? ?? '',
                };
              }).toList();

              if (_query.isNotEmpty) {
                dentists = dentists.where((d) => (d['name'] as String).toLowerCase().contains(_query)).toList();
              }

              if (dentists.isEmpty) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.person_search, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Sin resultados', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ]));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dentists.length,
                itemBuilder: (_, i) {
                  final d = dentists[i];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundImage: (d['photo'] as String).isNotEmpty ? NetworkImage(d['photo'] as String) as ImageProvider : null,
                        child: (d['photo'] as String).isEmpty ? Text((d['name'] as String)[0].toUpperCase()) : null,
                      ),
                      title: Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: (d['specialty'] as String).isNotEmpty ? Text(d['specialty'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 13)) : null,
                      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                      onTap: () {
                        widget.onSelected(d['uid'] as String, d['name'] as String, d['photo'] as String?);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
