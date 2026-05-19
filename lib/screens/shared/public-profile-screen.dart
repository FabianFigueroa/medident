import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/services/dentist/dentist-home-services.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

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
              : Padding(
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
                    ],
                  ),
                ),
    );
  }
}
