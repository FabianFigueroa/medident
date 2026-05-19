import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/screens/role/dentist/widget/tooth-widget.dart';

class OdontogramEditorScreen extends StatefulWidget {
  final PatientModel patient;
  const OdontogramEditorScreen({required this.patient, super.key});

  @override
  State<OdontogramEditorScreen> createState() => _OdontogramEditorScreenState();
}

class _OdontogramEditorScreenState extends State<OdontogramEditorScreen> {
  Map<int, ToothData> _teeth = {};
  int? _selectedToothNumber;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _odontogramId;
  ToothState _selectedState = ToothState.healthy;

  @override
  void initState() {
    super.initState();
    _initTeeth();
    _loadExisting();
  }

  void _initTeeth() {
    _teeth = {for (final n in allTeeth) n: ToothData(number: n)};
  }

  Future<void> _loadExisting() async {
    final cp = context.read<ClinicProvider>();
    if (cp.clinic == null) return;
    final odontogram = await cp.getOdontogram(widget.patient.id);
    if (odontogram != null && mounted) {
      setState(() {
        _odontogramId = odontogram['id'];
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
  }

  void _selectTooth(int number) {
    setState(() => _selectedToothNumber = number);
  }

  void _changeState(ToothState state) {
    if (_selectedToothNumber == null) {
      _selectedState = state;
      setState(() {});
      return;
    }
    setState(() {
      _teeth[_selectedToothNumber!]!.state = state;
      _selectedState = state;
    });
  }

  Future<void> _save() async {
    final cp = context.read<ClinicProvider>();
    final main = context.read<DentistMainProvider>();
    if (cp.clinic == null) return;

    setState(() => _isSaving = true);

    final teethMap = <String, dynamic>{};
    for (final t in _teeth.values) {
      teethMap['${t.number}'] = t.toMap();
    }

    try {
      if (_odontogramId != null) {
        await cp.updateOdontogram(
          _odontogramId!,
          teethMap,
        );
      } else {
        await cp.saveOdontogram(
          patientId: widget.patient.id,
          patientName: widget.patient.fullName,
          dentistId: main.userId,
          teethMap: teethMap,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Odontograma guardado'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Odontograma - ${widget.patient.fullName}',
          style: const TextStyle(fontFamily: 'Ubuntu-Bold', fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmer()
          : Column(
              children: [
                Expanded(child: _buildChart()),
                _buildStateSelector(),
              ],
            ),
    );
  }

  Widget _buildChart() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildRow('Superior derecha', upperRightTeeth),
          const SizedBox(height: 4),
          _buildRow('Superior izquierda', upperLeftTeeth),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildRow('Inferior izquierda', lowerLeftTeeth),
          const SizedBox(height: 4),
          _buildRow('Inferior derecha', lowerRightTeeth),
        ],
      ),
    );
  }

  Widget _buildRow(String label, List<int> numbers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: numbers.map((n) {
            final tooth = _teeth[n]!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToothWidget(
                    tooth: tooth,
                    isSelected: _selectedToothNumber == n,
                    onTap: () => _selectTooth(n),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 9,
                      color: _selectedToothNumber == n ? AppColors.primary : AppColors.grey500,
                      fontWeight: _selectedToothNumber == n ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.grey300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.more_horiz, color: AppColors.grey400, size: 20),
        ),
        Expanded(child: Divider(color: AppColors.grey300)),
      ],
    );
  }

  Widget _buildStateSelector() {
    final selected = _selectedToothNumber != null
        ? _teeth[_selectedToothNumber!]!.state
        : _selectedState;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
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
              Text(
                _selectedToothNumber != null
                    ? 'Diente $_selectedToothNumber'
                    : 'Selecciona un diente',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu-Bold',
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (_selectedToothNumber != null)
                TextButton(
                  onPressed: () => setState(() => _selectedToothNumber = null),
                  child: const Text('Deseleccionar', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ToothState.values.map((state) {
              final isActive = selected == state;
              return GestureDetector(
                onTap: () => _changeState(state),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Color(state.colorValue).withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? Color(state.colorValue)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(state.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? Color(state.colorValue) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
