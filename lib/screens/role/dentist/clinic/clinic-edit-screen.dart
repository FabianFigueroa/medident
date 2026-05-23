import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class ClinicEditScreen extends StatefulWidget {
  const ClinicEditScreen({super.key});

  @override
  State<ClinicEditScreen> createState() => _ClinicEditScreenState();
}

class _ClinicEditScreenState extends State<ClinicEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _descriptionCtrl;
  final _serviceNameCtrl = TextEditingController();
  final _servicePriceCtrl = TextEditingController();
  final _serviceDurationCtrl = TextEditingController();
  bool _loading = false;
  String _selectedColor = '#007AFF';

  static const _palette = [
    '#007AFF', '#5856D6', '#AF52DE', '#FF2D55', '#FF3B30',
    '#FF9500', '#FFCC00', '#34C759', '#00C7BE', '#5AC8FA',
    '#8E8E93', '#1C1C1E',
  ];

  ClinicModel? _getClinic() {
    try {
      return context.read<DentistMainProvider>().clinicStatusProvider?.clinic;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    final clinic = _getClinic();
    _nameCtrl = TextEditingController(text: clinic?.name ?? '');
    _addressCtrl = TextEditingController(text: clinic?.address ?? '');
    _phoneCtrl = TextEditingController(text: clinic?.phone ?? '');
    _emailCtrl = TextEditingController(text: clinic?.email ?? '');
    _websiteCtrl = TextEditingController(text: clinic?.website ?? '');
    _descriptionCtrl = TextEditingController(text: clinic?.description ?? '');
    if (clinic?.primaryColor != null) {
      _selectedColor = clinic!.primaryColor!;
    }
    context.read<DentistMainProvider>().clinicStatusProvider?.loadTreatments();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _descriptionCtrl.dispose();
    _serviceNameCtrl.dispose();
    _servicePriceCtrl.dispose();
    _serviceDurationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final clinic = _getClinic();
    if (clinic == null) return;
    setState(() => _loading = true);
    try {
      final clinicProvider = context.read<DentistMainProvider>().clinicStatusProvider;
      if (clinicProvider != null) {
        await clinicProvider.updateClinic({
          'name': _nameCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'website': _websiteCtrl.text.trim(),
          'description': _descriptionCtrl.text.trim(),
          'primaryColor': _selectedColor,
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clínica actualizada'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Editar Clínica', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection('Información general', [
              _buildField('Nombre', _nameCtrl),
              _buildField('Dirección', _addressCtrl, maxLines: 2),
              _buildField('Teléfono', _phoneCtrl, keyboardType: TextInputType.phone),
              _buildField('Email', _emailCtrl, keyboardType: TextInputType.emailAddress),
              _buildField('Sitio web', _websiteCtrl, keyboardType: TextInputType.url),
              _buildField('Descripción', _descriptionCtrl, maxLines: 4),
            ]),
            const SizedBox(height: 16),
            _buildColorSection(),
            const SizedBox(height: 16),
            _buildServicesSection(),
            const SizedBox(height: 16),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> fields) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
          const SizedBox(height: 16),
          ...fields,
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {TextInputType? keyboardType, int maxLines = 1}) {
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
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color.fromARGB(255, 5, 172, 180)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: Color(int.parse(_selectedColor.replaceFirst('#', ''), radix: 16)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Color de la clínica', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _palette.map((hex) {
              final color = Color(int.parse(hex.replaceFirst('#', ''), radix: 16));
              final selected = _selectedColor == hex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: selected
                        ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                  child: selected
                      ? const Center(child: Icon(Icons.check, color: Colors.white, size: 18))
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final clinic = _getClinic();
    final clinicProvider = context.watch<DentistMainProvider>().clinicStatusProvider;
    final treatments = clinicProvider?.treatments ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Servicios', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
          const SizedBox(height: 12),
          if (clinic != null) ...[
            ...treatments.map((t) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(t.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text('\$${t.price.toStringAsFixed(0)} · ${t.durationMinutes} min',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[300]),
                  onPressed: () => clinicProvider?.deactivateTreatment(t.id),
                ),
              );
            }),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _serviceNameCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Nombre del servicio',
                                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                filled: true, fillColor: const Color(0xFFF8F9FA),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 70,
                            child: TextField(
                              controller: _servicePriceCtrl,
                              style: const TextStyle(fontSize: 13),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '\$0', hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                filled: true, fillColor: const Color(0xFFF8F9FA),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: _serviceDurationCtrl,
                              style: const TextStyle(fontSize: 13),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'min', hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                filled: true, fillColor: const Color(0xFFF8F9FA),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _addService,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 5, 172, 180),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
        ],
      ),
    );
  }

  Future<void> _addService() async {
    if (_serviceNameCtrl.text.trim().isEmpty) return;
    final price = double.tryParse(_servicePriceCtrl.text.trim()) ?? 0;
    final duration = int.tryParse(_serviceDurationCtrl.text.trim()) ?? 30;
    final clinicProvider = context.read<DentistMainProvider>().clinicStatusProvider;
    await clinicProvider?.addTreatment(
      name: _serviceNameCtrl.text.trim(),
      price: price,
      durationMinutes: duration,
    );
    _serviceNameCtrl.clear();
    _servicePriceCtrl.clear();
    _serviceDurationCtrl.clear();
  }

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Zona de peligro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(),
              icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18),
              label: const Text('Eliminar clínica', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar clínica'),
        content: const Text('¿Estás seguro? Todos los datos de la clínica serán eliminados permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final clinicProvider = context.read<DentistMainProvider>().clinicStatusProvider;
              if (clinicProvider != null) {
                await clinicProvider.deactivateClinic();
                if (mounted) Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
