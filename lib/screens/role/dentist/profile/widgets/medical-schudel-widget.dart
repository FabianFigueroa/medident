import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/models/roles/user_role.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MedicalSchedulerWidget extends StatefulWidget {
  final List<UserModel> allUsers;

  const MedicalSchedulerWidget({super.key, required this.allUsers});

  @override
  State<MedicalSchedulerWidget> createState() => _MedicalSchedulerWidgetState();
}

class _MedicalSchedulerWidgetState extends State<MedicalSchedulerWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  
  // Simulamos una base de datos de citas ya agendadas   ****aca debemos agregar mas tiempos para seleccionar la hora o media hora
  // Estructura: { "2026-04-20": ["09:00 AM", "10:30 AM"] }
  final Map<String, List<Map<String, dynamic>>> _bookedAppointments = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointmentsForDate(DateTime.now());
    });
  }

  Future<void> _loadAppointmentsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    try {
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final key = DateFormat('yyyy-MM-dd').format(date);
      final Map<String, List<Map<String, dynamic>>> loadedAppts = {};

      for (final doc in snap.docs) {
        final data = doc.data();
        final timeSlot = data['timeSlot'] as String? ?? 'Sin horario';
        final patientName = data['patientName'] as String? ?? 'Paciente';
        final patientPhoto = data['patientPhoto'] as String?;

        final user = UserModel(
          uid: data['patientId'] as String? ?? '',
          email: '',
          fullName: patientName,
          role: UserRole.patient,
          phoneNumber: data['patientPhone'] as String?,
          imageUrl: patientPhoto,
        );

        if (!loadedAppts.containsKey(key)) {
          loadedAppts[key] = [];
        }
        loadedAppts[key]!.add({'time': timeSlot, 'user': user});
      }

      if (mounted) {
        setState(() {
          _bookedAppointments.clear();
          _bookedAppointments.addAll(loadedAppts);
        });
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        color: const Color.fromARGB(255, 2, 170, 170),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMinimalHeader(),
          const SizedBox(height: 10),
          _buildCalendarSection(),
          const SizedBox(height: 10),
          _buildAgendaTitle(),
          const SizedBox(height: 10),
          _buildDailyAgenda(),
        ],
      ),
    );
  }

  // 1. Header Limpio (Sin redundancia)
  Widget _buildMinimalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Gestión de Agenda",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            //***  remover el text y aca debemos agregar un icono para configurar el calendario (horas disponibles, tiempo de consulta, etc))
            child: const Text("V1.0", style: TextStyle(color: Colors.white, fontSize: 10)),
          )
        ],
      ),
    );
  }

  // 2. Calendario con PopUp al tocar
  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TableCalendar(
        locale: 'es_ES',
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(color: Color.fromARGB(255, 83, 238, 223), shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: Color.fromARGB(255, 15, 236, 26), shape: BoxShape.circle),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _loadAppointmentsForDate(selectedDay);
          _showNewAppointmentSheet(context, selectedDay);
        },
      ),
    );
  }

  Widget _buildAgendaTitle() {
    String fechaLabel = DateFormat.yMMMMd('es_ES').format(_selectedDay!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Text(
            "Citas para: $fechaLabel",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // 3. Lista de Citas Reales
  Widget _buildDailyAgenda() {
    String key = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    List<Map<String, dynamic>> appointments = _bookedAppointments[key] ?? [];

    if (appointments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Text("No hay citas agendadas.", style: TextStyle(color: Colors.white70)),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: appointments.length,
        itemBuilder: (context, i) {
          final cita = appointments[i];
          final UserModel user = cita['user'];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Text(cita['time'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(width: 15),
                CircleAvatar(radius: 15, backgroundImage: NetworkImage(user.imageUrl ?? '')),
                const SizedBox(width: 10),
                Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. Pop-up (Bottom Sheet) para agendar
  void _showNewAppointmentSheet(BuildContext context, DateTime date) {
    UserModel? selectedUser;
    String? selectedTime;
    final List<String> availableHours = [
    '08:00 AM',
    '08:30 AM', 
    '09:00 AM', 
    '09:30 AM',
    '10:00 AM', 
    '11:00 AM', 
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
    ];
    
    // Filtrar horas ya ocupadas para ese día
    String key = DateFormat('yyyy-MM-dd').format(date);
    List<String> occupied = (_bookedAppointments[key] ?? []).map((e) => e['time'] as String).toList();
    List<String> freeHours = availableHours.where((h) => !occupied.contains(h)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("NUEVA CITA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // Buscador de Pacientes
              Autocomplete<UserModel>(
                displayStringForOption: (user) => user.fullName,
                optionsBuilder: (textValue) {
                  if (textValue.text.isEmpty) return const Iterable<UserModel>.empty();
                  return widget.allUsers.where((u) => u.fullName.toLowerCase().contains(textValue.text.toLowerCase()));
                },
                onSelected: (user) => setModalState(() => selectedUser = user),
                fieldViewBuilder: (ctx, ctrl, focus, onConfirm) => TextField(
                  controller: ctrl,
                  focusNode: focus,
                  decoration: InputDecoration(
                    hintText: "Buscar paciente...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),

              if (selectedUser != null) ...[
                const SizedBox(height: 15),
                Builder(
                  builder: (context) {
                    final user = selectedUser!;
                    return ListTile(
                      tileColor: Colors.grey[100],
                      leading: CircleAvatar(backgroundImage: NetworkImage(user.imageUrl ?? '')),
                      title: Text(user.fullName),
                      subtitle: Text(user.speciality ?? 'Paciente'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    );
                  },
                ),
                const SizedBox(height: 15),
                const Text("Seleccionar Hora Disponible:"),
                Wrap(
                  spacing: 8,
                  children: freeHours.map((h) => ChoiceChip(
                    label: Text(h),
                    selected: selectedTime == h,
                    onSelected: (val) => setModalState(() => selectedTime = h),
                  )).toList(),
                ),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 117, 214, 218),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: (selectedUser != null && selectedTime != null) ? () async {
                  try {
                    await FirebaseFirestore.instance.collection('appointments').add({
                      'patientId': selectedUser!.uid,
                      'patientName': selectedUser!.fullName,
                      'patientPhoto': selectedUser!.imageUrl,
                      'dentistId': '',
                      'date': Timestamp.fromDate(date),
                      'timeSlot': selectedTime,
                      'status': 'pending',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) Navigator.pop(context);
                    await _loadAppointmentsForDate(date);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al agendar: $e')),
                      );
                    }
                  }
                } : null,
                child: const Text("AGENDAR AHORA", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
