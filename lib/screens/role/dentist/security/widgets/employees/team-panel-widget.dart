import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/dentist/security/widgets/employees/team-panel-shell.dart';

class TeamPanelWidget extends StatelessWidget {
  final List<UserModel> teammates;

  const TeamPanelWidget({required this.teammates});

  @override
  Widget build(BuildContext context) {
    ///// 
    return TeamPanelShell(
      title: 'Equipo conectado',
      subtitle: 'Personal clave con disponibilidad inmediata.',
      child: Column(
        children: teammates
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
