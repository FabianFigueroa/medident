import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para mostrar estado en línea de empleados
class DentistOnlineStatus extends StatelessWidget {
  const DentistOnlineStatus({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistOnlineStatus] build() iniciado');
    
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;
    
    if (profile == null) return SliverToBoxAdapter(child: const SizedBox.shrink());

    // Sample employee data - could be extended to come from profile
    final List<Map<String, dynamic>> employees = [
      {'name': 'Dr. Roberto Silva', 'role': 'Odontólogo', 'status': 'online', 'avatar': '🧑‍⚕️'},
      {'name': 'Dra. Laura Martínez', 'role': 'Odontólogo', 'status': 'online', 'avatar': '👩‍⚕️'},
      {'name': 'Carlos García', 'role': 'Asistente', 'status': 'offline', 'avatar': '👨‍🔧'},
      {'name': 'María López', 'role': 'Recepción', 'status': 'online', 'avatar': '👩‍💼'},
    ];

    final onlineCount = employees.where((e) => e['status'] == 'online').length;
    final offlineCount = employees.length - onlineCount;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('👥 Estado en Línea', style: AppTextStyles.headlineSmall),
                Text(
                  '${onlineCount}/${employees.length} en línea',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.positive),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard('En línea', onlineCount, AppColors.positive, '🟢'),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: _buildStatusCard('Ausente', offlineCount, AppColors.grey600, '⚫'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingL),
            // Employee list
            if (employees.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Text('Sin empleados', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: employees.length,
                itemBuilder: (context, index) => _buildEmployeeTile(employees[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color, String emoji) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: AppConstants.paddingS),
            Text(count.toString(), style: AppTextStyles.headlineSmall.copyWith(color: color)),
            const SizedBox(height: AppConstants.paddingXS),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeTile(Map<String, dynamic> employee) {
    final isOnline = employee['status'] == 'online';
    final statusColor = isOnline ? AppColors.positive : AppColors.grey600;
    final statusEmoji = isOnline ? '🟢' : '⚫';
    final statusText = isOnline ? 'En línea' : 'Ausente';
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Text(employee['avatar'] ?? '👤'),
        ),
        title: Text(employee['name'] ?? 'Sin nombre', style: AppTextStyles.bodyLarge),
        subtitle: Text(
          '${employee['role'] ?? 'Sin rol'} • $statusText',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingXS),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            border: Border.all(color: statusColor),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Text(
            statusEmoji,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
