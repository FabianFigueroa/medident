import 'package:flutter/material.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x1A0F172A), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Servicios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (isOwnProfile)
                  GestureDetector(
                    onTap: onAddService,
                    child: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 24),
                  ),
              ],
            ),
          ),
          if ((services ?? []).isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No hay servicios registrados',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: (services ?? []).length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final service = (services ?? [])[index];
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medical_services, color: Colors.blue, size: 20),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: description.isNotEmpty
                      ? Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : null,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (price.isNotEmpty)
                        Text(
                          '\$$price',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      if (duration.isNotEmpty)
                        Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
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