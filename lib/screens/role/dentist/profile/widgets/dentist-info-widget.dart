import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';

class DentistInfoWidget extends StatelessWidget {
  final UserModel userModel;
  final bool isOwnProfile;
  final VoidCallback? onEditPressed;

  const DentistInfoWidget({
    super.key,
    required this.userModel,
    this.isOwnProfile = false,
    this.onEditPressed,
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
                  'Información',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (isOwnProfile)
                  GestureDetector(
                    onTap: onEditPressed,
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                if (userModel.bio != null && userModel.bio!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.description,
                    title: 'Bio',
                    value: userModel.bio!,
                  ),
                if (userModel.speciality != null && userModel.speciality!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.medical_services,
                    title: 'Especialidad',
                    value: userModel.speciality!,
                  ),
                if (userModel.clinicName != null && userModel.clinicName!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.local_hospital,
                    title: 'Clínica',
                    value: userModel.clinicName!,
                  ),
                if (userModel.address != null && userModel.address!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.location_on,
                    title: 'Dirección',
                    value: userModel.address!,
                  ),
                if (userModel.phoneNumber != null && userModel.phoneNumber!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.phone,
                    title: 'Teléfono',
                    value: userModel.phoneNumber!,
                  ),
                if (userModel.email.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.email,
                    title: 'Email',
                    value: userModel.email,
                  ),
                if (userModel.website != null && userModel.website!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.language,
                    title: 'Website',
                    value: userModel.website!,
                  ),
                if (userModel.licenseNumber != null && userModel.licenseNumber!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.badge,
                    title: 'Licencia',
                    value: userModel.licenseNumber!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}