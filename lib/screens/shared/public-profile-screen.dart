import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/services/dentist/dentist-home-services.dart';
import 'package:medident/screens/widgets/follows/follow-button.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String? currentUserId;

  const PublicProfileScreen({super.key, required this.userId, this.currentUserId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final DentistHomeService _service = DentistHomeService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _service.getUser(widget.userId);
      if (mounted) setState(() { _user = user; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Usuario no encontrado'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _user!.imageUrl != null && _user!.imageUrl!.isNotEmpty
                            ? NetworkImage(_user!.imageUrl!)
                            : null,
                        child: _user!.imageUrl == null || _user!.imageUrl!.isEmpty
                            ? Text(
                                _user!.fullName.isNotEmpty ? _user!.fullName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _user!.fullName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      if (_user!.email.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(_user!.email, style: TextStyle(color: Colors.grey[600])),
                      ],
                      if ((_user!.profileCaption ?? _user!.bio ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          _user!.profileCaption ?? _user!.bio ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                        ),
                      ],
                      if (widget.currentUserId != null && widget.currentUserId != widget.userId) ...[
                        const SizedBox(height: 16),
                        FollowButton(
                          currentUserId: widget.currentUserId!,
                          targetUserId: widget.userId,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildInfoCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    final rows = <Widget>[];
    void add(IconData icon, String label, String? value) {
      if (value == null || value.trim().isEmpty) return;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0EA5A4)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ));
    }

    add(Icons.medical_services_outlined, 'Especialidad', _user!.speciality);
    add(Icons.badge_outlined, 'Licencia', _user!.licenseNumber);
    add(Icons.phone_outlined, 'Teléfono', _user!.phoneNumber);
    add(Icons.location_on_outlined, 'Dirección', _user!.address);
    add(Icons.language, 'Sitio web', _user!.website);
    add(Icons.local_hospital_outlined, 'Clínica', _user!.clinicName);

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x100F172A), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...rows,
        ],
      ),
    );
  }
}
