import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/models/odontogram-constants.dart';
import 'package:medident/core/models/odontogram-model.dart';
import 'package:medident/core/providers/dentist/dentist-clinic-provider.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'animated-tooth-widget.dart';

class LayerOdontogramEditor extends StatefulWidget {
  final String patientId;
  final String patientName;
  final bool autoSave;

  const LayerOdontogramEditor({
    super.key,
    required this.patientId,
    required this.patientName,
    this.autoSave = true,
  });

  @override
  State<LayerOdontogramEditor> createState() => _LayerOdontogramEditorState();
}

class _LayerOdontogramEditorState extends State<LayerOdontogramEditor> {
  Map<int, ToothData> _teeth = {};
  int? _selectedToothNumber;
  bool _isLoading = true;
  String? _odontogramId;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _initTeeth();
    _loadExisting();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _initTeeth() {
    _teeth = {for (final n in allTeeth) n: ToothData(number: n)};
  }

  Future<void> _loadExisting() async {
    final cp = context.read<DentistClinicProvider>();
    if (cp.clinic == null) return;
    try {
      final odontogram = await cp.getOdontogram(widget.patientId);
      if (odontogram != null && mounted) {
        setState(() {
          _odontogramId = odontogram['id'] as String?;
          final map = odontogram['teethMap'] as Map<String, dynamic>? ?? {};
          for (final entry in map.entries) {
            final n = int.tryParse(entry.key);
            if (n != null && _teeth.containsKey(n)) {
              _teeth[n] = ToothData.fromMap(
                entry.value as Map<String, dynamic>,
                n,
              );
            }
          }
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectTooth(int number) {
    setState(() => _selectedToothNumber = number);
  }

  void _applyLayer(ToothState state) {
    if (_selectedToothNumber == null) return;
    setState(() {
      _teeth[_selectedToothNumber!]!.state = state;
    });
    _scheduleAutoSave();
  }

  void _clearTooth() {
    if (_selectedToothNumber == null) return;
    setState(() {
      _teeth[_selectedToothNumber!]!.state = ToothState.healthy;
    });
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    if (!widget.autoSave) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _saveToFirestore);
  }

  Future<void> _saveToFirestore() async {
    final cp = context.read<DentistClinicProvider>();
    final main = context.read<DentistMainProvider>();
    if (cp.clinic == null) return;

    final teethMap = <String, dynamic>{};
    final hasChanges = _teeth.values.any((t) => t.state != ToothState.healthy);
    if (!hasChanges) return;

    for (final t in _teeth.values) {
      if (t.state != ToothState.healthy) {
        teethMap['${t.number}'] = t.toMap();
      }
    }

    try {
      if (_odontogramId != null) {
        await cp.updateOdontogram(_odontogramId!, teethMap);
      } else {
        await cp.saveOdontogram(
          patientId: widget.patientId,
          patientName: widget.patientName,
          dentistId: main.userId,
          teethMap: teethMap,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(child: _buildChart()),
        _buildLayerPanel(),
      ],
    );
  }

  Widget _buildChart() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildQuadrant('Superior Derecho', upperRightTeeth, true),
          const SizedBox(height: 6),
          _buildQuadrant('Superior Izquierdo', upperLeftTeeth, true),
          const SizedBox(height: 12),
          _buildDivider(),
          const SizedBox(height: 12),
          _buildQuadrant('Inferior Izquierdo', lowerLeftTeeth, false),
          const SizedBox(height: 6),
          _buildQuadrant('Inferior Derecho', lowerRightTeeth, false),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_vert, size: 14, color: Color(0xFF7C3AED)),
              SizedBox(width: 4),
              Text(
                'Arcadas',
                style: TextStyle(fontSize: 10, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  Widget _buildQuadrant(String label, List<int> numbers, bool _) {
    final hasIssues = numbers.any((n) => _teeth[n]?.state != ToothState.healthy);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasIssues) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEA580C),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: numbers.map((n) {
            final tooth = _teeth[n]!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedToothWidget(
                    tooth: tooth,
                    isSelected: _selectedToothNumber == n,
                    onTap: () => _selectTooth(n),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 8,
                      color: _selectedToothNumber == n
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF94A3B8),
                      fontWeight: _selectedToothNumber == n
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLayerPanel() {
    final selectedTooth = _selectedToothNumber != null
        ? _teeth[_selectedToothNumber!]
        : null;
    final currentState = selectedTooth?.state;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedTooth != null
                      ? Color(currentState!.colorValue).withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selectedTooth != null
                            ? Color(currentState!.colorValue)
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      selectedTooth != null
                          ? 'Diente $_selectedToothNumber · ${currentState!.label}'
                          : 'Toca un diente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedTooth != null
                            ? Color(currentState!.colorValue)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (selectedTooth != null && currentState != ToothState.healthy)
                GestureDetector(
                  onTap: _clearTooth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear, size: 12, color: Colors.red),
                        SizedBox(width: 3),
                        Text(
                          'Limpiar',
                          style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: ToothState.values.map((state) {
              final isActive = selectedTooth != null && currentState == state;
              final color = Color(state.colorValue);
              return GestureDetector(
                onTap: selectedTooth != null ? () => _applyLayer(state) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive ? color.withOpacity(0.12) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive ? color : Colors.grey.shade200,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? color : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (widget.autoSave)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_done, size: 10, color: Colors.green.shade300),
                  const SizedBox(width: 3),
                  Text(
                    'Auto-guardado',
                    style: TextStyle(fontSize: 9, color: Colors.green.shade300),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
