import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/widgets/app_card.dart';

class DentistServicesWidget extends StatelessWidget {
  final List<Map<String, dynamic>>? services;
  final bool isOwnProfile;
  final Function(int)? onServiceTap;
  final VoidCallback? onAddService;

  const DentistServicesWidget({
    super.key,
    required this.services,
    this.isOwnProfile = false,
    this.onServiceTap,
    this.onAddService,
  });

  @override
  Widget build(BuildContext context) {
    final items = services ?? [];
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Servicios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
              ),
              if (isOwnProfile)
                GestureDetector(
                  onTap: onAddService,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: AppColors.primary, size: 18),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No hay servicios registrados', style: TextStyle(color: AppColors.grey500, fontSize: 14)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final service = items[index];
                final name = service['name'] ?? service['title'] ?? 'Servicio ${index + 1}';
                final price = service['price'] ?? service['cost'] ?? '';
                final duration = service['duration'] ?? service['time'] ?? '';
                final description = service['description'] ?? service['desc'] ?? '';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medical_services, color: AppColors.primary, size: 20),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                  subtitle: description.isNotEmpty
                      ? Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.grey500))
                      : null,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (price.toString().isNotEmpty)
                        Text('\$$price', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
                      if (duration.toString().isNotEmpty)
                        Text(duration.toString(), style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
                    ],
                  ),
                  onTap: onServiceTap != null ? () => onServiceTap!(index) : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
