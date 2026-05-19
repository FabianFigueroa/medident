import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';

class ClinicAttendanceWidget extends StatelessWidget {
  final String clinicId;

  const ClinicAttendanceWidget({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 18, color: Color(0xFF0EA5A4)),
              const SizedBox(width: 6),
              const Text(
                'Personal Hoy',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('clinicId', isEqualTo: clinicId)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final total = snap.data!.docs.length;
                  final active = snap.data!.docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['isInClinic'] == true;
                  }).length;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5A4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$active/$total en clínica',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0EA5A4)),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('clinicId', isEqualTo: clinicId)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }

              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      'Sin personal registrado',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  padding: const EdgeInsets.only(right: 8),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['fullName'] as String? ?? 'Sin nombre';
                    final photoUrl = data['imageUrl'] as String?;
                    final role = data['role'] as String? ?? 'employee';
                    final isInClinic = data['isInClinic'] == true;
                    final cardCode = data['assignedCardCode'] as String?;

                    return _EmployeeAttendanceCard(
                      name: name,
                      photoUrl: photoUrl,
                      role: role,
                      isInClinic: isInClinic,
                      hasCard: cardCode != null && cardCode.isNotEmpty,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmployeeAttendanceCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String role;
  final bool isInClinic;
  final bool hasCard;

  const _EmployeeAttendanceCard({
    required this.name,
    this.photoUrl,
    required this.role,
    required this.isInClinic,
    required this.hasCard,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF10B981);

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isInClinic ? activeColor.withOpacity(0.3) : Colors.grey[200]!,
          width: isInClinic ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isInClinic
                ? activeColor.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isInClinic
                      ? activeColor.withOpacity(0.15)
                      : Colors.grey[100],
                  backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isInClinic ? activeColor : Colors.grey[400],
                          ),
                        )
                      : null,
                ),
                if (isInClinic)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check, size: 8, color: Colors.white),
                    ),
                  ),
                if (!isInClinic && hasCard)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.orange[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.access_time, size: 8, color: Colors.white),
                    ),
                  ),
                if (!hasCard)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.close, size: 8, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isInClinic ? const Color(0xFF0F172A) : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _roleLabel(role),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isInClinic ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'dentist':
        return 'Odontólogo/a';
      case 'employee':
        return 'Empleado/a';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}
