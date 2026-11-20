import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medident/core/models/turno-request-model.dart';
import 'package:medident/core/services/agenda-service.dart';

class AdminTurnoRequestsScreen extends StatelessWidget {
  const AdminTurnoRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de Turnos')),
      body: StreamBuilder<List<TurnoRequestModel>>(
        stream: AgendaService().streamTurnoRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final requests = snapshot.data!.where((r) => r.status == 'pending').toList();
          if (requests.isEmpty) return const Center(child: Text('No hay solicitudes pendientes'));
          
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (_, i) => _RequestCard(request: requests[i]),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TurnoRequestModel request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(request.employeeName),
        subtitle: Text(
          '${_typeLabel(request.type)}: ${request.details}'
          '${(request.targetEmployeeName ?? '').isNotEmpty ? ' · con ${request.targetEmployeeName}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => AgendaService().updateRequestStatus(request.id, 'approved', request.employeeId),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => AgendaService().updateRequestStatus(request.id, 'rejected', request.employeeId),
            ),
          ],
        ),
      ),
    );
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'cambio_horario':
      return 'CAMBIO DE HORARIO';
    case 'cambio_turno':
      return 'CAMBIO DE TURNO';
    case 'intercambio':
      return 'INTERCAMBIO';
    default:
      return 'NOVEDAD';
  }
}
