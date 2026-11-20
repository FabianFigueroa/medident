import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:medident/screens/role/dentist/widget/layer-odontogram-editor.dart';

class PatientDetailScreen extends StatefulWidget {
  final PatientModel patient;
  const PatientDetailScreen({required this.patient, super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PatientModel? _detail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enrichPatient());
  }

  Future<void> _enrichPatient() async {
    try {
      final full = await context
          .read<DentistClinicProvider>()
          .getPatientDetail(widget.patient.id);
      if (mounted && full != null) setState(() => _detail = full);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPatientQr(PatientModel patient) {
    final code = (patient.patientCode ?? '').isNotEmpty
        ? patient.patientCode!
        : patient.id;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('QR del paciente',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text(patient.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            SelectableText(code,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.2)),
            const SizedBox(height: 6),
            Text('Muéstralo en recepción para agendar más rápido.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = _detail ?? widget.patient;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          patient.fullName,
          style: const TextStyle(fontFamily: 'Ubuntu-Bold', fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2, color: AppColors.primary),
            tooltip: 'QR del paciente',
            onPressed: () => _showPatientQr(patient),
          ),
          IconButton(
            icon: const Icon(Icons.account_tree, color: AppColors.primary),
            tooltip: 'Odontograma',
            onPressed: () => _openOdontogram(),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: () => _showEditDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(patient),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey600,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Ubuntu-Medium',
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'Ubuntu-Regular',
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'Historial'),
              Tab(text: 'Notas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(patient),
                _buildHistoryTab(patient),
                _buildNotesTab(patient),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(PatientModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          p.photo != null && p.photo!.isNotEmpty
              ? CircleAvatar(
                  radius: 40,
                  backgroundImage: CachedNetworkImageProvider(p.photo!),
                )
              : CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 32,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          const SizedBox(height: 12),
          Text(
            p.fullName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Ubuntu-Bold'),
          ),
          const SizedBox(height: 4),
          if (p.email.isNotEmpty || p.phone != null)
            Text(
              [p.phone, p.email].where((e) => e != null && e.isNotEmpty).join('  ·  '),
              style: TextStyle(fontSize: 13, color: AppColors.grey600),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(PatientModel p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Información personal'),
          _infoCard([
            _infoRow('Tipo de sangre', p.bloodType ?? '—'),
            _infoRow('Teléfono', p.phone ?? '—'),
            _infoRow('Email', p.email.isEmpty ? '—' : p.email),
          ]),
          const SizedBox(height: 16),
          if (p.allergies.isNotEmpty) ...[
            _sectionTitle('Alergias'),
            _chipList(p.allergies, Colors.orange),
            const SizedBox(height: 16),
          ],
          if (p.medications.isNotEmpty) ...[
            _sectionTitle('Medicamentos'),
            _chipList(p.medications, Colors.blue),
            const SizedBox(height: 16),
          ],
          _sectionTitle('Seguro médico'),
          _infoCard([
            _infoRow('Proveedor', p.insuranceProvider ?? '—'),
            _infoRow('N° Póliza', p.insuranceId ?? '—'),
          ]),
          const SizedBox(height: 16),
          _sectionTitle('Historial médico'),
          _infoCard(
            p.medicalHistory.isNotEmpty
                ? p.medicalHistory.map((h) => _infoRow('•', h)).toList()
                : [_infoRow('', 'Sin condiciones registradas')],
          ),
          const SizedBox(height: 16),
          _sectionTitle('Historial dental'),
          _infoCard(
            p.dentalHistory.isNotEmpty
                ? p.dentalHistory.map((h) => _infoRow('•', h)).toList()
                : [_infoRow('', 'Sin procedimientos previos')],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(PatientModel p) {
    final cp = context.read<DentistClinicProvider>();
    if (cp.clinic == null) return const SizedBox.shrink();
    final clinicId = cp.clinic!.id;
    return StreamBuilder(
      stream: cp.streamClinicalRecords(clinicId, p.id),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerList();
        }
        if (snapshot.hasError) {
          return _buildHistoryError('${snapshot.error}');
        }
        final docs = (snapshot.data?.docs ?? []).where((d) {
          final cid = d.data()['clinicId'];
          return cid == null || cid == clinicId;
        }).toList()
          ..sort((a, b) {
            final da = DateTime.tryParse('${a.data()['date']}') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final db = DateTime.tryParse('${b.data()['date']}') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return db.compareTo(da);
          });
        if (docs.isEmpty) {
          return _buildEmptyHistory();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 8),
                child: Row(
                  children: [
                    Text(
                      '${docs.length} registros',
                      style: TextStyle(fontSize: 13, color: AppColors.grey600),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showAddRecordDialog(p),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Nuevo registro'),
                    ),
                  ],
                ),
              );
            }
            final data = docs[index - 1].data();
            final record = ClinicalRecord.fromMap(data, docs[index - 1].id);
            return _buildRecordCard(record, p);
          },
        );
      },
    );
  }

  Widget _buildHistoryError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.grey300),
            const SizedBox(height: 12),
            const Text('No se pudo cargar el historial',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.grey500)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesTab(PatientModel p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Notas generales'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              p.notes?.isNotEmpty == true ? p.notes! : 'Sin notas registradas.',
              style: TextStyle(
                fontSize: 14,
                color: p.notes?.isNotEmpty == true ? Colors.black87 : AppColors.grey500,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _showEditNotesDialog(p),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Editar notas'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(ClinicalRecord record, PatientModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(record.date),
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Ubuntu-Medium'),
              ),
              const Spacer(),
              _buildRecordMenu(record, p),
            ],
          ),
          const SizedBox(height: 8),
          if (record.diagnosis != null && record.diagnosis!.isNotEmpty) ...[
            _recordField('Diagnóstico', record.diagnosis!),
            const SizedBox(height: 4),
          ],
          if (record.treatment != null && record.treatment!.isNotEmpty) ...[
            _recordField('Tratamiento', record.treatment!),
            const SizedBox(height: 4),
          ],
          if (record.procedure != null && record.procedure!.isNotEmpty)
            _recordField('Procedimiento', record.procedure!),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _recordField('Notas', record.notes!),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person_outline, size: 12, color: AppColors.grey500),
              const SizedBox(width: 4),
              Text(
                record.dentistName,
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
              if (record.attachments.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(Icons.attach_file, size: 12, color: AppColors.grey500),
                Text(
                  '${record.attachments.length}',
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordMenu(ClinicalRecord record, PatientModel p) {
    return PopupMenuButton<String>(
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Editar')),
        const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
      ],
      onSelected: (action) {
        final cp = context.read<DentistClinicProvider>();
        if (action == 'edit') {
          _showEditRecordDialog(record, p);
        } else if (action == 'delete') {
          cp.deleteClinicalRecord(record.id);
        }
      },
    );
  }

  void _showEditRecordDialog(ClinicalRecord record, PatientModel p) {
    final diagnosisCtrl = TextEditingController(text: record.diagnosis ?? '');
    final treatmentCtrl = TextEditingController(text: record.treatment ?? '');
    final procedureCtrl = TextEditingController(text: record.procedure ?? '');
    final notesCtrl = TextEditingController(text: record.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Editar registro clínico',
            style: TextStyle(fontFamily: 'Ubuntu-Bold', fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: procedureCtrl, decoration: const InputDecoration(labelText: 'Procedimiento', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: diagnosisCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Diagnóstico', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: treatmentCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Tratamiento', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final cp = context.read<DentistClinicProvider>();
              cp.updateClinicalRecord(record.id, {
                'procedure': procedureCtrl.text.trim().isEmpty ? null : procedureCtrl.text.trim(),
                'diagnosis': diagnosisCtrl.text.trim().isEmpty ? null : diagnosisCtrl.text.trim(),
                'treatment': treatmentCtrl.text.trim().isEmpty ? null : treatmentCtrl.text.trim(),
                'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registro actualizado'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _recordField(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.grey600, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'Ubuntu-Bold',
        ),
      ),
    );
  }

  Widget _chipList(List<String> items, Color color) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: items.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(item, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      )).toList(),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedFile01,
            size: 60,
            color: AppColors.grey300,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin historial clínico',
            style: TextStyle(fontSize: 16, color: AppColors.grey600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddRecordDialog(widget.patient),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar registro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  // ── Diálogos ──

  void _showEditDialog() {
    final p = widget.patient;
    final nameCtrl = TextEditingController(text: p.fullName);
    final phoneCtrl = TextEditingController(text: p.phone ?? '');
    final emailCtrl = TextEditingController(text: p.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Editar paciente', style: TextStyle(fontFamily: 'Ubuntu-Bold')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final cp = context.read<DentistClinicProvider>();
              cp.updatePatientUser(p.id, {
                'fullName': nameCtrl.text.trim(),
                'phoneNumber': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                'email': emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditNotesDialog(PatientModel p) {
    final notesCtrl = TextEditingController(text: p.notes ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Notas', style: TextStyle(fontFamily: 'Ubuntu-Bold')),
        content: TextField(
          controller: notesCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Escribe notas sobre el paciente...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final cp = context.read<DentistClinicProvider>();
              cp.updatePatientProfile(p.id, {
                'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog(PatientModel p) {
    final diagnosisCtrl = TextEditingController();
    final treatmentCtrl = TextEditingController();
    final procedureCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Nuevo registro clínico', style: TextStyle(fontFamily: 'Ubuntu-Bold', fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: diagnosisCtrl, decoration: const InputDecoration(labelText: 'Diagnóstico', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: treatmentCtrl, decoration: const InputDecoration(labelText: 'Tratamiento', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: procedureCtrl, decoration: const InputDecoration(labelText: 'Procedimiento', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final cp = context.read<DentistClinicProvider>();
              final auth = context.read<AuthenticateProvider>();
              final dentistName = auth.user?.fullName ?? auth.user?.userName ?? 'Desconocido';
              if (cp.clinic == null) return;
              cp.addClinicalRecord(
                clinicId: cp.clinic!.id,
                patientId: p.id,
                dentistName: dentistName,
                date: DateTime.now(),
                diagnosis: diagnosisCtrl.text.trim().isEmpty ? null : diagnosisCtrl.text.trim(),
                treatment: treatmentCtrl.text.trim().isEmpty ? null : treatmentCtrl.text.trim(),
                procedure: procedureCtrl.text.trim().isEmpty ? null : procedureCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
              );
              cp.updatePatientUser(p.id, {
                'lastVisit': Timestamp.fromDate(DateTime.now()),
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _openOdontogram() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Odontograma - ${widget.patient.fullName}',
              style: const TextStyle(fontFamily: 'Ubuntu-Bold', fontSize: 15),
            ),
          ),
          body: LayerOdontogramEditor(
            patientId: widget.patient.id,
            patientName: widget.patient.fullName,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Eliminar paciente'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final cp = context.read<DentistClinicProvider>();
      await cp.deletePatient(widget.patient.id);
      if (mounted) Navigator.pop(context);
    }
  }
}
