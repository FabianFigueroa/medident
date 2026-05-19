import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-panel-shell.dart';
import 'package:medident/screens/widgets/avatar/circle_avatar_widget.dart';

class DentistTeamPanel extends StatelessWidget {
  final List<UserModel> listUserModel;

  const DentistTeamPanel({required this.listUserModel});

  @override
  Widget build(BuildContext context) {
    return DentistPanelShell(
      title: 'Equipo conectado',
      subtitle: 'Personal clave con disponibilidad inmediata.',
      child: Column(
        children: listUserModel
            .map(
              (member) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar_Widget(
                  imageUrl: member.imageUrl,
                  radius: 22,
                  placeholderIcon: Icons.person,
                ),
                title: Text(
                  member.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                subtitle: Text(
                  member.role.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'Ubuntu-Regular',
                  ),
                ),
                trailing: Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
