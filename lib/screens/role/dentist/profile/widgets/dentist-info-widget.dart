import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/widgets/app_card.dart';

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
                'Información',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
              ),
              if (isOwnProfile)
                GestureDetector(
                  onTap: onEditPressed,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: AppColors.primary, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (userModel.bio != null && userModel.bio!.isNotEmpty)
            _buildInfoItem(Icons.description, 'Bio', userModel.bio!),
          if (userModel.speciality != null && userModel.speciality!.isNotEmpty)
            _buildInfoItem(Icons.medical_services, 'Especialidad', userModel.speciality!),
          if (userModel.clinicName != null && userModel.clinicName!.isNotEmpty)
            _buildInfoItem(Icons.local_hospital, 'Clínica', userModel.clinicName!),
          if (userModel.address != null && userModel.address!.isNotEmpty)
            _buildInfoItem(Icons.location_on, 'Dirección', userModel.address!),
          if (userModel.phoneNumber != null && userModel.phoneNumber!.isNotEmpty)
            _buildInfoItem(Icons.phone, 'Teléfono', userModel.phoneNumber!),
          if (userModel.email.isNotEmpty)
            _buildInfoItem(Icons.email, 'Email', userModel.email),
          if (userModel.website != null && userModel.website!.isNotEmpty)
            _buildInfoItem(Icons.language, 'Website', userModel.website!),
          if (userModel.licenseNumber != null && userModel.licenseNumber!.isNotEmpty)
            _buildInfoItem(Icons.badge, 'Licencia', userModel.licenseNumber!),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.grey500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
