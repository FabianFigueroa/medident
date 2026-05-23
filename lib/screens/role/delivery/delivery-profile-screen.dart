import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class DeliveryProfileScreen extends StatelessWidget {
  const DeliveryProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Builder(builder: (context) {
              final imageUrl = user?.imageUrl;
              final hasImage = imageUrl != null && imageUrl.isNotEmpty;
              return CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey[300],
                backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                child: !hasImage
                    ? Icon(Icons.person, size: 48, color: Colors.grey[500])
                    : null,
              );
            }),
            const SizedBox(height: 16),
            Text(user?.fullName ?? 'Domiciliario',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(user?.phoneNumber ?? '', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
