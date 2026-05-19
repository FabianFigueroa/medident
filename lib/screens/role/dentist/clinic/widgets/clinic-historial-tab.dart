import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/clinic/clinic-provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/models/clinical-record-model.dart';
import 'package:medident/screens/widgets/shared/patient_search_sheet.dart';

class ClinicHistorialTab extends StatefulWidget {
  const ClinicHistorialTab({super.key});

  @override
  State<ClinicHistorialTab> createState() => _ClinicHistorialTabState();
}

class _ClinicHistorialTabState extends State<ClinicHistorialTab> {
  String _selectedFilter = 'todos';

  static const _filters = ['todos', 'consulta', 'tratamiento', 'cirugía', 'estético'];
  static const _filterLabels = ['Todos', 'Consulta', 'Tratamiento', 'Cirugía', 'Estético'];

  Map<String, String> _patientNameCache = {};

  bool _matchesFilter(String? procedure, String filter) {
    if (filter == 'todos') return true;
    if (procedure == null) return false;
    final p = procedure.toLowerCase();
    switch (filter) {
      case 'consulta': return p.contains('consulta') || p.contains('limpieza') || p.contains('revisión');
      case 'tratamiento': return p.contains('tratamiento') || p.contains('endodoncia') || p.contains('ortodoncia') || p.contains('conducto') || p.contains('brackets');
      case 'cirugía': return p.contains('cirugía') || p.contains('extracción') || p.contains('implante') || p.contains('cirugia');
      case 'estético': return p.contains('estético') || p.contains('blanqueamiento') || p.contains('estetico');
      default: return true;
    }
  }

  Future<void> _loadPatientNames(List<ClinicalRecord> records) async {
    final ids = records.map((r) => r.patientId).where((id) => id.isNotEmpty && !id.startsWith('walkin_') && !_patientNameCache.containsKey(id)).toSet().toList();
    if (ids.isEmpty) return;
    try {
      final batches = <String>[for (var i = 0; i < ids.length; i += 10) ids.sublist(i, (i + 10 > ids.length) ? ids.length : i + 10).join(',')];
      for (final batch in batches) {
        final idsInBatch = batch.split(',');
        final snap = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: idsInBatch).get();
        for (final doc in snap.docs) {
          _patientNameCache[doc.id] = doc.data()['fullName'] ?? doc.id;
        }
      }
    } catch (_) {}
  }

  void _showAddRecordDialog(BuildContext context) {
    final procedureCtrl = TextEditingController();
    final diagnosisCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final clinicProv = context.read<ClinicProvider>();
    final clinicId = clinicProv.clinic?.id ?? '';
    final user = context.read<AuthenticateProvider>().user;
    String selectedPatientId = '';
    String selectedPatientName = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: StatefulBuilder(builder: (ctx, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Nuevo Registro Clínico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => PatientSearchSheet(
                      clinicId: clinicId,
                      onSelected: (id, name, _) {
                        setDialogState(() {
                          selectedPatientId = id;
                          selectedPatientName = name;
                        });
                      },
                    ),
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Paciente',
                    prefixIcon: Icon(Icons.person_outline, color: selectedPatientName.isNotEmpty ? Colors.teal : null),
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.search),
                  ),
                  child: Text(selectedPatientName.isNotEmpty ? selectedPatientName : 'Toca para buscar...'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: procedureCtrl, decoration: const InputDecoration(labelText: 'Procedimiento', prefixIcon: Icon(Icons.medical_services_outlined), border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: diagnosisCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Diagnóstico', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
                onPressed: () async {
                  if (selectedPatientName.isEmpty) return;
                  final pid = selectedPatientId.isNotEmpty ? selectedPatientId : 'walkin_${DateTime.now().millisecondsSinceEpoch}';
                  try {
                    await clinicProv.addClinicalRecord(
                      clinicId: clinicId,
                      patientId: pid,
                      dentistName: user?.fullName ?? '',
                      date: DateTime.now(),
                      procedure: procedureCtrl.text.trim(),
                      diagnosis: diagnosisCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                    );
                    setState(() => _patientNameCache[pid] = selectedPatientName);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro creado'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Guardar Registro', style: TextStyle(fontWeight: FontWeight.w600)),
              )),
            ],
          )),
        ),
      ),
    );
  }

  Future<void> _deleteRecord(BuildContext context, String recordId) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Eliminar registro'),
      content: const Text('¿Estás seguro?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
      ],
    ));
    if (ok == true) {
      try {
        await context.read<ClinicProvider>().deleteClinicalRecord(recordId);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro eliminado'), backgroundColor: Colors.red));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final clinicId = context.select<ClinicProvider, String>((p) => p.clinic?.id ?? '');
    final patientCount = context.select<ClinicProvider, int>((p) => p.uniquePatientsCount);

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: handle),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              Text('Historial Clínico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              const Spacer(),
              Text('$patientCount paciente(s)', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(_filters.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: _filterLabels[i], selected: _selectedFilter == _filters[i],
                    onTap: () => setState(() => _selectedFilter = _filters[i]),
                  ),
                );
              }),
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: clinicId.isNotEmpty
                ? context.read<ClinicProvider>().streamClinicClinicalRecords(clinicId)
                : null,
            builder: (context, snapshot) {
              if (clinicId.isEmpty || snapshot.connectionState == ConnectionState.none) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Column(children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Error al cargar historial', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    Text('${snapshot.error}', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ])),
                ));
              }
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ));
              }
              final allRecords = snapshot.data!.docs.map((d) {
                return ClinicalRecord.fromMap(d.data() as Map<String, dynamic>, d.id);
              }).toList();
              final filtered = allRecords.where((r) => _matchesFilter(r.procedure, _selectedFilter)).toList();

              WidgetsBinding.instance.addPostFrameCallback((_) => _loadPatientNames(filtered));

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Column(children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Sin registros para este filtro', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    TextButton.icon(onPressed: () => _showAddRecordDialog(context), icon: const Icon(Icons.add), label: const Text('Agregar registro')),
                  ])),
                ));
              }

              final records = filtered;
              return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                final item = records[index];
                final patientName = item.patientId.startsWith('walkin_') ? 'Paciente' : (_patientNameCache[item.patientId] ?? item.patientId);
                Color badgeColor;
                IconData badgeIcon;
                final p = (item.procedure ?? '').toLowerCase();
                if (p.contains('cirugía') || p.contains('extracción') || p.contains('implante') || p.contains('cirugia')) {
                  badgeColor = Colors.red; badgeIcon = Icons.content_cut;
                } else if (p.contains('tratamiento') || p.contains('endodoncia') || p.contains('ortodoncia') || p.contains('conducto') || p.contains('brackets')) {
                  badgeColor = Colors.blue; badgeIcon = Icons.healing;
                } else if (p.contains('estético') || p.contains('blanqueamiento') || p.contains('estetico')) {
                  badgeColor = Colors.purple; badgeIcon = Icons.auto_awesome;
                } else {
                  badgeColor = Colors.teal; badgeIcon = Icons.medical_services;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                  child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(badgeIcon, color: badgeColor, size: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A))),
                        Text(formattedDate(item.date), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(item.procedure ?? 'General', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor)),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) { if (v == 'delete') _deleteRecord(context, item.id); },
                        itemBuilder: (_) => [const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Eliminar')))],
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Container(width: double.infinity, padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (item.diagnosis != null && item.diagnosis!.isNotEmpty)
                          Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('Diagnóstico: ${item.diagnosis}', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500))),
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Text(item.notes!, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
                        if (item.dentistName.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [
                          Icon(Icons.person, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(item.dentistName, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500)),
                        ])),
                      ]),
                    ),
                  ])),
                );
              },
              childCount: filtered.length,
            ),
          );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      );
  }

  String formattedDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes}m';
    if (diff.inDays < 1) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1A1A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.grey[600],
          )),
        ),
      ),
    );
  }
}
