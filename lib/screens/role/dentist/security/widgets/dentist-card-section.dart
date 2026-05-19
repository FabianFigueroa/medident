import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class DentistCardSection extends StatelessWidget {
  const DentistCardSection({super.key});

  // Helper para obtener el icono según el tipo de tarjeta
  IconData _getCardTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'employee':
        return Icons.person_outline;
      case 'patient':
        return Icons.sick_outlined;
      case 'guest':
        return Icons.group_outlined;
      default:
        return Icons.credit_card;
    }
  }

  // Helper para construir el ListTile de cada tarjeta
  Widget _buildCardListTile(BuildContext context, DentistRfidCardModel card, DentistSecurityProvider provider) {
    Color statusColor;
    IconData statusIcon;
    switch (card.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'inactive':
        statusColor = Colors.orange;
        statusIcon = Icons.pause_circle_outline;
        break;
      case 'lost':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.blueGrey;
        statusIcon = Icons.info_outline;
    }

    return ListTile(
      leading: Icon(_getCardTypeIcon(card.type), color: Theme.of(context).primaryColor, size: 32),
      title: Text(card.assignedTo.isNotEmpty ? card.assignedTo : 'Sin asignar', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text('ID: ${card.cardId} | Tipo: ${card.type.toUpperCase()}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            avatar: CircleAvatar(backgroundColor: statusColor.withOpacity(0.2), child: Icon(statusIcon, color: statusColor, size: 16)),
            label: Text(card.status.toUpperCase(), style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 10)),
            backgroundColor: statusColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.grey),
            onPressed: () => _showAddEditCardDialog(context, cardToEdit: card),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDeleteCard(context, card),
          ),
        ],
      ),
    );
  }

  // Método para confirmar la eliminación de una tarjeta
  void _confirmDeleteCard(BuildContext context, DentistRfidCardModel card) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar la tarjeta "${card.assignedTo.isNotEmpty ? card.assignedTo : card.cardId}"?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
              onPressed: () {
                context.read<DentistSecurityProvider>().deleteCard(card);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DentistSecurityProvider>(
      builder: (context, provider, child) {
        // Obtenemos las tarjetas desde el nuevo 'securityData'
        final cards = provider.securityData?.cards ?? [];

        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tarjetas de Acceso',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                      onPressed: () => _showAddEditCardDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (cards.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('No hay tarjetas registradas.')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return _buildCardListTile(context, card, provider);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditCardDialog(BuildContext context, {DentistRfidCardModel? cardToEdit}) {
    final provider = context.read<DentistSecurityProvider>();
    final isEditing = cardToEdit != null;
    final cardIdController = TextEditingController(text: cardToEdit?.cardId ?? '');
    final assignedToController = TextEditingController(text: cardToEdit?.assignedTo ?? '');
    String? selectedType = cardToEdit?.type ?? 'employee';
    String? selectedStatus = cardToEdit?.status ?? 'active';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Tarjeta' : 'Añadir Tarjeta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cardIdController,
                  decoration: const InputDecoration(labelText: 'ID de la Tarjeta'),
                  readOnly: isEditing,
                ),
                TextField(
                  controller: assignedToController,
                  decoration: const InputDecoration(labelText: 'Asignada a'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Tarjeta',
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['employee', 'patient', 'guest'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedType = newValue;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado de la Tarjeta',
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['active', 'inactive', 'lost'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedStatus = newValue;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            if (isEditing)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
                onPressed: () {
                  provider.deleteCard(cardToEdit);
                  Navigator.of(dialogContext).pop();
                },
              ),
            ElevatedButton(
              child: Text(isEditing ? 'Guardar' : 'Añadir'),
              onPressed: () {
                final newCard = DentistRfidCardModel(
                  cardId: cardIdController.text,
                  assignedTo: assignedToController.text,
                  type: selectedType!,
                  status: selectedStatus!,
                );

                if (isEditing) {
                  provider.updateCard(newCard);
                } else {
                  provider.addCard(newCard);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
