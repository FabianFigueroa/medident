import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:medident/core/models/turno-model.dart';
import 'package:medident/core/providers/dentist/dentist-clinic-provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';

class ClinicTurnosTab extends StatefulWidget {
  const ClinicTurnosTab({super.key});

  @override
  State<ClinicTurnosTab> createState() => _ClinicTurnosTabState();
}

class _ClinicTurnosTabState extends State<ClinicTurnosTab> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final turnos = context.select<DentistClinicProvider, List<TurnoModel>>((p) => p.turnos);
    final turnosByDay = _groupByDay(turnos);

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: handle),
        SliverToBoxAdapter(child: _CalendarHeader(
            month: _selectedMonth,
            onPrev: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
            onNext: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
          )),
          SliverToBoxAdapter(child: _MonthGrid(
            month: _selectedMonth,
            turnosByDay: turnosByDay,
            onDayTap: (day) {
              _showDayEmployees(context, day, turnos.where((t) =>
                t.date.year == day.year && t.date.month == day.month && t.date.day == day.day
              ).toList());
            },
          )),
          SliverToBoxAdapter(child: _UpcomingList(turnos: turnos)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      );
  }

  Map<String, List<TurnoModel>> _groupByDay(List<TurnoModel> turnos) {
    final map = <String, List<TurnoModel>>{};
    for (final t in turnos) {
      final key = '${t.date.year}-${t.date.month}-${t.date.day}';
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  void _showDayEmployees(BuildContext context, DateTime day, List<TurnoModel> dayTurnos) {
    final clinicProv = context.read<DentistClinicProvider>();
    final userId = context.read<AuthenticateProvider>().user?.uid ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DayEmployeeSheet(
        day: day,
        turnos: dayTurnos,
        clinicProv: clinicProv,
        userId: userId,
        onRefresh: () => setState(() {}),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev, onNext;

  const _CalendarHeader({required this.month, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        Text(_monthFormatter.format(month), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        const Spacer(),
        IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left), constraints: const BoxConstraints()),
        const SizedBox(width: 4),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right), constraints: const BoxConstraints()),
      ]),
    );
  }
}

final DateFormat _monthFormatter = DateFormat('MMMM yyyy', 'es');

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<String, List<TurnoModel>> turnosByDay;
  final void Function(DateTime) onDayTap;

  const _MonthGrid({required this.month, required this.turnosByDay, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final totalDays = lastDay.day;
    final today = DateTime.now();

    final List<Widget> dayWidgets = [];
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }
    for (int d = 1; d <= totalDays; d++) {
      final date = DateTime(month.year, month.month, d);
      final key = '${date.year}-${date.month}-${date.day}';
      final count = turnosByDay[key]?.length ?? 0;
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      dayWidgets.add(_DayCell(day: d, count: count, isToday: isToday, onTap: () => onDayTap(date)));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              Text('Turnos del mes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const Spacer(),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1,
              children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'].map((d) =>
                Center(child: Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500])))
              ).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1,
              children: dayWidgets,
            ),
          ),
        ]),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final int count;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({required this.day, required this.count, required this.isToday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: count > 0 ? Colors.teal.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: Colors.teal, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: isToday ? Colors.teal : Colors.grey[700],
            )),
            if (count > 0)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(6)),
                child: Text('$count', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  final List<TurnoModel> turnos;
  const _UpcomingList({required this.turnos});

  @override
  Widget build(BuildContext context) {
    final upcoming = turnos.where((t) => t.isUpcoming).toList()..sort((a, b) => a.date.compareTo(b.date));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(children: [
          const Icon(Icons.event_note, size: 18, color: Color(0xFF1A1A1A)),
          const SizedBox(width: 8),
          Text('Próximos turnos', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const Spacer(),
          Text('${upcoming.length} turno(s)', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ]),
      ),
      if (upcoming.isEmpty)
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Column(children: [
            Icon(Icons.schedule, size: 36, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text('Sin turnos próximos', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ])),
        )
      else
        ...upcoming.take(10).map((t) => _TurnoCard(turno: t)),
    ]);
  }
}

class _TurnoCard extends StatelessWidget {
  final TurnoModel turno;
  const _TurnoCard({required this.turno});

  @override
  Widget build(BuildContext context) {
    final t = turno;
    String statusText;
    Color statusColor;
    switch (t.status) {
      case 'active': statusText = 'Activo'; statusColor = Colors.green; break;
      case 'completed': statusText = 'Completado'; statusColor = Colors.blue; break;
      case 'cancelled': statusText = 'Cancelado'; statusColor = Colors.red; break;
      default: statusText = 'Programado'; statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.badge, color: Colors.teal, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.employeeName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 2),
            Text('${t.startTime} - ${t.endTime}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (!t.isToday)
              Text('${t.date.day}/${t.date.month}/${t.date.year}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ])),
          PopupMenuButton<String>(
            onSelected: (action) async {
              try {
                if (action == 'start') {
                  await context.read<DentistClinicProvider>().updateTurnoStatus(t.id, 'active');
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno iniciado'), backgroundColor: Colors.green));
                } else if (action == 'complete') {
                  await context.read<DentistClinicProvider>().updateTurnoStatus(t.id, 'completed');
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno completado'), backgroundColor: Colors.blue));
                } else if (action == 'cancel') {
                  await context.read<DentistClinicProvider>().updateTurnoStatus(t.id, 'cancelled');
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno cancelado'), backgroundColor: Colors.orange));
                } else if (action == 'delete') {
                  final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar turno'),
                    content: const Text('¿Estás seguro?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                    ],
                  ));
                  if (ok == true) {
                    await context.read<DentistClinicProvider>().deleteTurno(t.id);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno eliminado'), backgroundColor: Colors.red));
                  }
                }
              } catch (_) {}
            },
            itemBuilder: (_) => [
              if (t.status != 'active' && t.status != 'completed') const PopupMenuItem(value: 'start', child: ListTile(leading: Icon(Icons.play_arrow, color: Colors.green), title: Text('Iniciar'))),
              if (t.status == 'active') const PopupMenuItem(value: 'complete', child: ListTile(leading: Icon(Icons.check_circle, color: Colors.blue), title: Text('Completar'))),
              if (t.status != 'cancelled' && t.status != 'completed') const PopupMenuItem(value: 'cancel', child: ListTile(leading: Icon(Icons.cancel, color: Colors.orange), title: Text('Cancelar'))),
              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Eliminar'))),
            ],
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ]),
      ),
    );
  }
}

class _DayEmployeeSheet extends StatefulWidget {
  final DateTime day;
  final List<TurnoModel> turnos;
  final DentistClinicProvider clinicProv;
  final String userId;
  final VoidCallback onRefresh;

  const _DayEmployeeSheet({
    required this.day, required this.turnos,
    required this.clinicProv, required this.userId, required this.onRefresh,
  });

  @override
  State<_DayEmployeeSheet> createState() => _DayEmployeeSheetState();
}

class _DayEmployeeSheetState extends State<_DayEmployeeSheet> {
  List<Map<String, dynamic>> _availableDoctors = [];
  bool _loadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final clinicId = widget.clinicProv.clinic?.id;
      if (clinicId == null) {
        if (mounted) setState(() => _loadingDoctors = false);
        return;
      }
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('clinicId', isEqualTo: clinicId)
          .where('role', whereIn: ['doctor', 'dentist'])
          .limit(30)
          .get();
      if (!mounted) return;
      setState(() {
        _availableDoctors = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loadingDoctors = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final t = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: t);
    if (picked != null) {
      ctrl.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayStr = '${widget.day.day}/${widget.day.month}/${widget.day.year}';
    final weekdays = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final weekday = weekdays[widget.day.weekday % 7];

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              Text('$weekday, ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(dayStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const Spacer(),
              Text('${widget.turnos.length} turno(s)', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ]),
            const SizedBox(height: 16),
            if (widget.turnos.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Icon(Icons.people_outline, size: 36, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text('Sin empleados asignados este día', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: () => _showAddEmployee(context),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Vincular empleado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: () => _showLinkDoctor(context),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('Vincular doctor existente'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )),
                ]),
              )
            else
              ...widget.turnos.map((t) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  child: Text(t.employeeName[0].toUpperCase(), style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                ),
                title: Text(t.employeeName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('${t.startTime} - ${t.endTime}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(t.status, style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.w600)),
                ),
              )),
          ],
        ),
      ),
    );
  }

  void _showAddEmployee(BuildContext ctx) {
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '08:00');
    final endCtrl = TextEditingController(text: '17:00');

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx2) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Nuevo empleado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(
                  controller: startCtrl,
                  readOnly: true,
                  onTap: () => _pickTime(startCtrl),
                  decoration: const InputDecoration(labelText: 'Inicio', prefixIcon: Icon(Icons.access_time), border: OutlineInputBorder()),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextField(
                  controller: endCtrl,
                  readOnly: true,
                  onTap: () => _pickTime(endCtrl),
                  decoration: const InputDecoration(labelText: 'Fin', prefixIcon: Icon(Icons.access_time), border: OutlineInputBorder()),
                )),
              ]),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  try {
                    await widget.clinicProv.createTurno(
                      dentistId: widget.userId,
                      employeeId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                      employeeName: nameCtrl.text.trim(),
                      date: widget.day,
                      startTime: startCtrl.text.trim(),
                      endTime: endCtrl.text.trim(),
                    );
                    if (ctx2.mounted) Navigator.pop(ctx2);
                    widget.onRefresh();
                  } catch (e) {
                    if (ctx2.mounted) ScaffoldMessenger.of(ctx2).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Guardar y asignar turno', style: TextStyle(fontWeight: FontWeight.w600)),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showLinkDoctor(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx2) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx2).size.height * 0.6),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Vincular doctor a la clínica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Selecciona un doctor o dentista registrado. No cambiará su rol.', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 16),
              if (_loadingDoctors)
                const Center(child: CircularProgressIndicator())
              else if (_availableDoctors.isEmpty)
                Center(child: Text('No hay doctores disponibles', style: TextStyle(color: Colors.grey[500], fontSize: 13)))
              else
                Flexible(child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableDoctors.length,
                  itemBuilder: (_, i) {
                    final doc = _availableDoctors[i];
                    final name = doc['fullName'] ?? 'Sin nombre';
                    final speciality = doc['speciality'] ?? doc['role'] ?? '';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        child: Text(name.toString()[0].toUpperCase(), style: const TextStyle(color: Colors.teal)),
                      ),
                      title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(speciality.toString(), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      trailing: const Icon(Icons.add_circle_outline, color: Colors.teal),
                      onTap: () async {
                        try {
                          final clinicId = widget.clinicProv.clinic?.id ?? '';
                          final uid = doc['id'] as String;
                          await FirebaseFirestore.instance.collection('users').doc(uid).update({
                            'clinicId': clinicId,
                          });
                          if (ctx2.mounted) Navigator.pop(ctx2);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${name} vinculado a la clínica'),
                            backgroundColor: Colors.green,
                          ));
                          setState(() => _loadingDoctors = true);
                          _loadDoctors();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                        }
                      },
                    );
                  },
                )),
            ],
          ),
        ),
      ),
    );
  }
}
