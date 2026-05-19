import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/screens/role/dentist/profile/widgets/counter-widget.dart';

class Dentist_Counter_Widget extends StatefulWidget {
  final UserModel currentUser;
  final bool isFollowing;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onEditProfilePressed;
   final bool isOwnProfile;
  
  const Dentist_Counter_Widget({
    super.key,
    required this.currentUser,
    this.isFollowing = false,
    this.onFollowPressed,
    this.onEditProfilePressed,
    this.isOwnProfile = false,
  });

  @override
  State<Dentist_Counter_Widget> createState() => _Dentist_Counter_WidgetState();
}

class _Dentist_Counter_WidgetState extends State<Dentist_Counter_Widget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        //border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Contador de Ventas
            Expanded(
              child: CounterWidget(
                label: 'Ventas',
                count: widget.currentUser.servicesCount,
              ),
            ),
            // Contador de Pacientes  
            Expanded(
              child: CounterWidget(
                label: 'Pacientes',
                count: widget.currentUser.followersCount,
              ),
            ),
            // Contador de Seguidores
            Expanded(
              child: CounterWidget(
                label: 'Seguidores',
                count: widget.currentUser.followingCount,
              ),
            ),
            SizedBox(
              height: 35, // ¡La altura es obligatoria!
              child: VerticalDivider(
                color: Colors.grey,
                thickness: 0.5, // Grosor de la línea
                width: 0.8, // Espacio total horizontal que ocupa
              ),
            ),

            SizedBox(width: 25),
            _buildActionButton(context),


          ],
        ),
      ),
    );
  }



  Widget _buildActionButton(BuildContext context) {
    if (widget.isOwnProfile) {
      // Si es el perfil propio, mostrar botón de "Editar perfil"
      return ElevatedButton(
        onPressed: widget.onEditProfilePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 5, 172, 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Editar perfil',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else {
      // Si es el perfil de otro usuario, mostrar botón de seguir/dejar de seguir
      return ElevatedButton(
        onPressed: widget.onFollowPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isFollowing ? Colors.grey : Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          widget.isFollowing ? 'Siguiendo' : 'Seguir',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
  }


}
