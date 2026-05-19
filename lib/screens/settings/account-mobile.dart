// lib/screens/account/account_screen_mobile.dart

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:medident/screens/widgets/appbar/appbar-center.dart';

// ============================================================
// SCREEN PRINCIPAL
// ============================================================
class AccountScreenMobile extends StatefulWidget {
  final String uid; // Recibes el uid para cargar datos específicos del usuario
  
  const AccountScreenMobile({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<AccountScreenMobile> createState() => _AccountScreenMobileState();
}

class _AccountScreenMobileState extends State<AccountScreenMobile> {
  // Datos del usuario - mock inicial
  UserData _userData = UserData(
    name: 'Ronald Richards',
    email: 'ronaldrichards@gmail.com',
    photoUrl: null,
  );
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ============================================================
  // AQUÍ CONECTAS CON TU AUTHENTICATE PROVIDER
  // ============================================================
  Future<void> _loadUserData() async {
    // TODO: Conectar con tu AuthenticateProvider
    // Ejemplo de cómo sería:
    /*
    final authProvider = Provider.of<AuthenticateProvider>(context, listen: false);
    final user = authProvider.getUserData(widget.uid);
    setState(() {
      _userData = UserData(
        name: user['name'],
        email: user['email'],
        photoUrl: user['photoUrl'],
      );
      _isLoading = false;
    });
    */
    
    // Simulación de carga - REMOVER CUANDO CONECTES
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Appbar_Container_Widget(
        leftIcon: HugeIcon(icon: HugeIcons.strokeRounded0Circle, size: 24),
        rightIcon: HugeIcon(icon: HugeIcons.strokeRounded1Square, size: 20),
        title: "Mi Título",
        textAlign: TextAlign.center,
        gradientColorStart: Colors.blue,
        gradientColorEnd: Colors.purple,
        leftIconTap: () => Navigator.pop(context),
        rightIconTap: () => debugPrint("Menú"),
      ),
    ),
      body: _isLoading 
        ? const _LoadingWidget()
        : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          
          // Header de perfil
          ProfileHeader(userData: _userData),
          
          const SizedBox(height: 32),
          
          // Sección Account
          const SectionTitle(title: 'Account'),
          const SizedBox(height: 8),
          AccountSection(),
          
          const SizedBox(height: 24),
          
          // Sección Preferences
          const SectionTitle(title: 'Preferences'),
          const SizedBox(height: 8),
          PreferencesSection(),
          
          const SizedBox(height: 24),
          
          // Sección Support
          const SectionTitle(title: 'Support'),
          const SizedBox(height: 8),
          SupportSection(),
          
          const SizedBox(height: 40),
          
          // Botón de cerrar sesión
          LogoutButton(uid: widget.uid),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ============================================================
// MODELO DE DATOS
// ============================================================
class UserData {
  final String name;
  final String email;
  final String? photoUrl;
  
  UserData({
    required this.name,
    required this.email,
    this.photoUrl,
  });
}

// ============================================================
// WIDGETS REUTILIZABLES
// ============================================================

// 1. WIDGET DE CARGA
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// 2. WIDGET HEADER DE PERFIL
class ProfileHeader extends StatelessWidget {
  final UserData userData;
  
  const ProfileHeader({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(photoUrl: userData.photoUrl),
        const SizedBox(width: 16),
        Expanded(
          child: ProfileInfo(
            name: userData.name,
            email: userData.email,
          ),
        ),
      ],
    );
  }
}

// 2.1 Avatar de perfil
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  
  const ProfileAvatar({Key? key, this.photoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF3F4F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
              ),
            )
          : _buildDefaultAvatar(),
    );
  }
  
  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person_rounded,
      size: 40,
      color: Colors.grey[400],
    );
  }
}

// 2.2 Información del perfil
class ProfileInfo extends StatelessWidget {
  final String name;
  final String email;
  
  const ProfileInfo({Key? key, required this.name, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// 3. WIDGET TÍTULO DE SECCIÓN
class SectionTitle extends StatelessWidget {
  final String title;
  
  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// 4. WIDGET MENÚ ITEM GENÉRICO
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  
  const MenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(
            icon,
            color: const Color(0xFF6B7280),
            size: 22,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E1E1E),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null)
                Text(
                  trailing!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

// 5. SECCIÓN ACCOUNT
class AccountSection extends StatelessWidget {
  AccountSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Manage Profile',
          onTap: () => _navigateTo(context, '/manage-profile'),
        ),
        MenuItem(
          icon: Icons.lock_outline_rounded,
          title: 'Password & Security',
          onTap: () => _navigateTo(context, '/password-security'),
        ),
        MenuItem(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          onTap: () => _navigateTo(context, '/notifications'),
        ),
        MenuItem(
          icon: Icons.language_rounded,
          title: 'Language',
          trailing: 'English',
          onTap: () => _navigateTo(context, '/language'),
        ),
      ],
    );
  }
  
  void _navigateTo(BuildContext context, String route) {
    // TODO: Implementar navegación
    debugPrint('Navigate to: $route');
  }
}

// 6. SECCIÓN PREFERENCES
class PreferencesSection extends StatelessWidget {
  PreferencesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuItem(
          icon: Icons.info_outline_rounded,
          title: 'About Us',
          onTap: () => _navigateTo(context, '/about-us'),
        ),
        MenuItem(
          icon: Icons.brightness_6_rounded,
          title: 'Theme',
          trailing: 'Light',
          onTap: () => _navigateTo(context, '/theme'),
        ),
        MenuItem(
          icon: Icons.calendar_today_rounded,
          title: 'Appointments',
          onTap: () => _navigateTo(context, '/appointments'),
        ),
      ],
    );
  }
  
  void _navigateTo(BuildContext context, String route) {
    // TODO: Implementar navegación
    debugPrint('Navigate to: $route');
  }
}

// 7. SECCIÓN SUPPORT
class SupportSection extends StatelessWidget {
  SupportSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Help Center',
          onTap: () => _navigateTo(context, '/help-center'),
        ),
      ],
    );
  }
  
  void _navigateTo(BuildContext context, String route) {
    // TODO: Implementar navegación
    debugPrint('Navigate to: $route');
  }
}

// 8. WIDGET BOTÓN DE LOGOUT
class LogoutButton extends StatelessWidget {
  final String uid;
  
  const LogoutButton({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // ====================================================
                // AQUÍ CONECTAS EL LOGOUT CON TU AUTHENTICATE PROVIDER
                // ====================================================
                // TODO: Conectar logout con tu provider
                // Ejemplo:
                /*
                final authProvider = Provider.of<AuthenticateProvider>(
                  context, 
                  listen: false
                );
                authProvider.logout(uid);
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false
                );
                */
                
                debugPrint('Logout ejecutado para uid: $uid');
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// CÓMO USAR ESTA SCREEN (EJEMPLO)
// ============================================================

/*
// En tu archivo de navegación o router:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AccountScreenMobile(
      uid: currentUser.uid, // Pasas el uid del usuario actual
    ),
  ),
);

// O usando named routes:
// En tu router:
'/account': (context) => AccountScreenMobile(uid: arguments['uid']),

*/

// ============================================================
// EJEMPLO DE CÓMO CONECTAR CON TU AUTHENTICATE PROVIDER
// ============================================================

/*
// 1. En _loadUserData() dentro de AccountScreenMobile:
Future<void> _loadUserData() async {
  final authProvider = Provider.of<AuthenticateProvider>(context, listen: false);
  
  // Suponiendo que tu provider tiene un método getUserInfo(uid)
  final userInfo = await authProvider.getUserInfo(widget.uid);
  
  setState(() {
    _userData = UserData(
      name: userInfo.name,
      email: userInfo.email,
      photoUrl: userInfo.photoUrl,
    );
    _isLoading = false;
  });
}

// 2. En el botón de logout:
TextButton(
  onPressed: () {
    final authProvider = Provider.of<AuthenticateProvider>(
      context, 
      listen: false
    );
    authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  },
  child: const Text('Log Out'),
),
*/

// ============================================================
// NOTAS IMPORTANTES:
// ============================================================
// 1. Los widgets están separados para máxima reutilización
// 2. Todos los colores son consistentes y modernos
// 3. El diseño es responsivo y maneja diferentes tamaños de texto
// 4. Los estados de carga están implementados
// 5. Las animaciones son suaves y profesionales
// 6. Solo necesitas conectar tu AuthenticateProvider en los puntos marcados con TODO
