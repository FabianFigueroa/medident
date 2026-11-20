import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';

class AccountScreenMobile extends StatefulWidget {
  final String uid;

  const AccountScreenMobile({super.key, required this.uid});

  @override
  State<AccountScreenMobile> createState() => _AccountScreenMobileState();
}

class _AccountScreenMobileState extends State<AccountScreenMobile> {
  static const _accent = Color(0xFF0EA5A4);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _specialityCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();

  UserModel? _user;
  bool _prefilled = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    final auth = context.watch<AuthenticateProvider>();
    final user = auth.user;
    if (user != null && user.uid == widget.uid) {
      _user = user;
      _prefill(user);
    }
  }

  void _prefill(UserModel user) {
    _fullNameCtrl.text = user.fullName;
    _userNameCtrl.text = user.userName ?? '';
    _phoneCtrl.text = user.phoneNumber ?? '';
    _specialityCtrl.text = user.speciality ?? '';
    _licenseCtrl.text = user.licenseNumber ?? '';
    _addressCtrl.text = user.address ?? '';
    _websiteCtrl.text = user.website ?? '';
    _captionCtrl.text = user.profileCaption ?? user.bio ?? '';
    _prefilled = true;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _userNameCtrl.dispose();
    _phoneCtrl.dispose();
    _specialityCtrl.dispose();
    _licenseCtrl.dispose();
    _addressCtrl.dispose();
    _websiteCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final caption = _captionCtrl.text.trim();
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'fullName': _fullNameCtrl.text.trim(),
        'userName': _userNameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'speciality': _specialityCtrl.text.trim(),
        'licenseNumber': _licenseCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
        'bio': caption,
        'profileCaption': caption,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _user?.email ?? '';
    if (email.isEmpty) return;
    try {
      await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enviamos un correo de recuperación a $email'),
          backgroundColor: _accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar el correo: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await context.read<AuthenticateProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthenticateProvider>().user;
    if (authUser != null && authUser.uid == widget.uid && !_prefilled) {
      _user = authUser;
      _prefill(authUser);
    }
    final user = _user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0.4,
        title: const Text(
          'Configuración de la cuenta',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _buildUserHeader(user),
                  const SizedBox(height: 20),
                  _sectionTitle('Información personal'),
                  _buildPersonalForm(),
                  const SizedBox(height: 20),
                  _sectionTitle('Descripción del perfil'),
                  _buildCaptionForm(),
                  const SizedBox(height: 20),
                  _sectionTitle('Cuenta'),
                  _buildAccountTiles(),
                  const SizedBox(height: 20),
                  _sectionTitle('Soporte'),
                  _buildSupportTiles(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_outlined, size: 20),
                      label: Text(
                        _saving ? 'Guardando...' : 'Guardar cambios',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Cerrar sesión'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserHeader(UserModel user) {
    final photo = user.imageUrl ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: _accent.withOpacity(0.12),
            backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
            child: photo.isEmpty
                ? Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: _accent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isNotEmpty ? user.fullName : 'Usuario',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: _text),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: const TextStyle(
                        fontSize: 10.5,
                        color: _accent,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _field(
            controller: _fullNameCtrl,
            label: 'Nombre completo',
            icon: Icons.badge_outlined,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _userNameCtrl,
            label: 'Nombre de usuario',
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _phoneCtrl,
            label: 'Teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _specialityCtrl,
            label: 'Especialidad',
            icon: Icons.medical_services_outlined,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _licenseCtrl,
            label: 'Número de licencia / tarjeta profesional',
            icon: Icons.workspace_premium_outlined,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _addressCtrl,
            label: 'Dirección',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _websiteCtrl,
            label: 'Sitio web',
            icon: Icons.language,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: _decoration('Correo electrónico', Icons.email_outlined),
            child: Text(
              _user?.email ?? '',
              style: const TextStyle(fontSize: 14, color: _muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esta descripción aparece en tu perfil público (profileCaption).',
            style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _captionCtrl,
            maxLines: 5,
            maxLength: 300,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: _decoration(
              'Cuéntale a tus pacientes sobre ti',
              Icons.notes_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTiles() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tile(
            icon: Icons.lock_outline_rounded,
            title: 'Contraseña y seguridad',
            subtitle: 'Enviar correo de recuperación',
            onTap: _sendPasswordReset,
          ),
          _tile(
            icon: Icons.notifications_none_rounded,
            title: 'Notificaciones',
            subtitle: 'Alertas de citas y mensajes',
            trailing: 'Activadas',
            onTap: () {},
          ),
          _tile(
            icon: Icons.language_rounded,
            title: 'Idioma',
            subtitle: 'Idioma de la aplicación',
            trailing: 'Español',
            onTap: () {},
          ),
          _tile(
            icon: Icons.brightness_6_rounded,
            title: 'Tema',
            subtitle: 'Apariencia de la aplicación',
            trailing: 'Claro',
            onTap: () {},
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTiles() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tile(
            icon: Icons.help_outline_rounded,
            title: 'Centro de ayuda',
            subtitle: 'Preguntas frecuentes y soporte',
            onTap: () {},
          ),
          _tile(
            icon: Icons.info_outline_rounded,
            title: 'Acerca de Medident',
            subtitle: 'Versión e información de la app',
            trailing: 'v1.0',
            onTap: () {},
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _muted,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
    required VoidCallback onTap,
    bool last = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: _accent),
          ),
          title: Text(
            title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _text),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 11.5, color: _muted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null)
                Text(trailing,
                    style: const TextStyle(fontSize: 12, color: _muted)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: _muted, size: 20),
            ],
          ),
          onTap: onTap,
        ),
        if (!last)
          const Divider(height: 1, thickness: 0.6, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _text),
      decoration: _decoration(label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: _muted),
      prefixIcon: Icon(icon, size: 19, color: _accent.withOpacity(0.85)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.4),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D0F172A),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
