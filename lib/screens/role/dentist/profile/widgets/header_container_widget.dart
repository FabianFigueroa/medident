import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-counter-widget.dart';
import 'package:medident/screens/widgets/avatar/circle_avatar_widget.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class Header_Container_Widget extends StatelessWidget {
  const Header_Container_Widget({
    super.key,
    required this.userModel,
    this.isFollowing = false,
    this.isOwnProfile = false, // Por defecto, asumimos que no es el perfil propio
    this.counterWidget, // Nuevo: Permite pasar un widget de contadores personalizado
    this.onEditProfilePressed,
    this.onFollowPressed,
    required this.promotions, // Ahora es requerido y viene del padre
    this.featuredPosts = const [], // Nuevo: Por defecto lista vacía
    this.showFeaturedPosts = false, // Nuevo: Por defecto no mostrar
    this.onPromotionEdit,
    this.onPromotionDelete,
    this.onPromotionShare,
    this.onFeaturedPostTap, // Nuevo: Callback para tap en post destacado
  });

  final Widget? counterWidget; // Nuevo: Widget de contadores personalizable para reutilización
  final List<Map<String, dynamic>> featuredPosts; // Nuevo: Lista de posts destacados
  final bool isFollowing;
  final bool isOwnProfile; // Nuevo: Para saber si es el perfil propio (calculado por el padre)
  final VoidCallback? onEditProfilePressed; // Callback para editar perfil propio
  final VoidCallback? onFeaturedPostTap; // Callback para tap en post destacado
  final VoidCallback? onFollowPressed; // Callback para seguir/dejar de seguir (cuando no es propio)
  final VoidCallback? onPromotionDelete; // Callback para eliminar promoción
  final VoidCallback? onPromotionEdit;   // Callback para editar promoción
  final VoidCallback? onPromotionShare;  // Callback para compartir promoción
  final List<Map<String, dynamic>> promotions; // Lista de promociones recibida desde el padre
  final bool showFeaturedPosts; // Nuevo: Controla si mostrar la sección de posts destacados
  final UserModel userModel;

  String get _avatarUrl => userModel.imageUrl != null && userModel.imageUrl!.isNotEmpty 
      ? userModel.imageUrl!   
      : AppConstants.placeholderUserImage;

  String _getPromotionImageUrl(Map<String, dynamic> promo) {
    final imageUrls = promo['imageUrls'] as List<dynamic>?;
    if (imageUrls != null && imageUrls.isNotEmpty && imageUrls.first.toString().isNotEmpty) {
      return imageUrls.first.toString();
    }
    final url = promo['imageUrl'] ?? 
                 promo['thumbnailUrl'] ?? 
                 promo['image'] ?? 
                 promo['url'] ?? 
                 promo['mediaUrl'] ?? 
                 promo['photoUrl'] ??
                 '';
    return url.isNotEmpty ? url : AppConstants.placeholderUserImage;
  }

  Widget _buildFeaturedPostsSection(List<Map<String, dynamic>> posts) {
    return Container(
      height: 60, // Altura fija para la sección de posts destacados
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final post = posts[index];
          final imageUrl = post['imageUrl'] ?? 
                           post['thumbnailUrl'] ?? 
                           post['image'] ?? 
                           post['url'] ?? 
                           post['mediaUrl'] ?? 
                           post['photoUrl'] ?? 
                           AppConstants.placeholderUserImage;
          return GestureDetector(
            onTap: onFeaturedPostTap != null ? () => onFeaturedPostTap!() : null,
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.white54),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo) {
    final url = _getPromotionImageUrl(promo);
    final hasImage = url.isNotEmpty && url != AppConstants.placeholderUserImage;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF9333EA).withOpacity(0.7), const Color(0xFF7C3AED).withOpacity(0.9)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              promo['title'] ?? 'Promoción',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (hasImage)
          Global_Avatar_Widget(
            imageUrl: url,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorWidget: const SizedBox.shrink(),
          ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo['title'] ?? 'Sin título',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                if ((promo['price'] ?? 0) > 0)
                  Text(
                    '\$${(promo['price'] as num).toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPromotionDetails(BuildContext context, Map<String, dynamic> promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Promotion media (image or video)
                if (_getPromotionImageUrl(promotion).isNotEmpty && _getPromotionImageUrl(promotion) != AppConstants.placeholderUserImage)
                  Global_Avatar_Widget(
                    imageUrl: _getPromotionImageUrl(promotion),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                else if (promotion['videoUrl'] != null && promotion['videoUrl'].isNotEmpty)
                  // For video, show thumbnail with play icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Global_Avatar_Widget(
                        imageUrl: promotion['thumbnailUrl'] ?? promotion['videoUrl'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      const Icon(Icons.play_circle_fill, color: Color.fromARGB(255, 151, 59, 59), size: 50),
                    ],
                  )
                else
                  Container(
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey[200]!, Colors.grey[300]!])),
                    height: 200,
                    width: double.infinity,
                    child: const Icon(Icons.image, color: Colors.grey, size: 48),
                  ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  promotion['title'] ?? 'Promoción sin título',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  promotion['description'] ?? 'Sin descripción',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 5),
                
                // Action buttons - DELEGADOS AL PADRE VIA CALLBACKS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Edit button
                    ElevatedButton.icon(
                      onPressed: onPromotionEdit != null 
                          ? () {
                              Navigator.of(context).pop();
                              onPromotionEdit!();
                            }
                          : null, // Deshabilitado si no hay callback
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    // Delete button
                    ElevatedButton.icon(
                      onPressed: onPromotionDelete != null 
                          ? () {
                              Navigator.of(context).pop();
                              onPromotionDelete!();
                            }
                          : null,
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                    // Share button
                    ElevatedButton.icon(
                      onPressed: onPromotionShare != null 
                          ? () {
                              Navigator.of(context).pop();
                              onPromotionShare!();
                            }
                          : null,
                      icon: const Icon(Icons.share),
                      label: const Text('Compartir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats({
    required String username,
    required String profession,
    String? specialty, // Opcional
    String? fullname,  // Opcional
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre Completo
        Text(
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Ubuntu-Bold',
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
          softWrap: true,
        ),
        
        // Profesión / Job Title
        Text(
          profession,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontFamily: 'Ubuntu-Regular',
          ),
        ),
        
        // Especialidad (Si existe, la mostramos)
        if (specialty != null && specialty.isNotEmpty)
          Text(
            specialty,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blueAccent, // Un toque de color para resaltar
              fontFamily: 'Ubuntu-Medium',
            ),
          ),
        
        // Username (Si lo quieres mostrar estilo @usuario)
        if (fullname != null && fullname.isNotEmpty)
          Text(
            "@$fullname",
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> promotionsToShow = promotions.take(5).toList();
    final List<Map<String, dynamic>> featuredPostsToShow = featuredPosts.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal:8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x1A0F172A), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // 1. Carrusel + contadores (superpuestos en Stack con altura fija 250)
          SizedBox(
            height: 370,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: promotionsToShow.isEmpty
                      ? Container(
                          height: 250,
                          color: const Color.fromARGB(255, 255, 183, 183),
                          child: const Center(
                            child: Text('No hay promociones', style: TextStyle(color: Color.fromARGB(255, 97, 91, 91), fontSize: 16)),
                          ),
                        )
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: 250,
                            viewportFraction: 1.0,
                            autoPlay: promotionsToShow.length > 1,
                            autoPlayInterval: const Duration(seconds: 4),
                          ),
                          items: promotionsToShow.map((promo) => GestureDetector(
                            onTap: () => _showPromotionDetails(context, promo),
                            child: _buildPromoCard(promo),
                          )).toList(),
                        ),
                ),
                ////////////////////////////////////////////
                Positioned(
                  top: 210,
                  left: 15,
                  right: 15,
                  child: counterWidget ?? Dentist_Counter_Widget(
                    currentUser: userModel,
                    isFollowing: isFollowing,
                    onFollowPressed: onFollowPressed,
                    onEditProfilePressed: onEditProfilePressed,
                    isOwnProfile: isOwnProfile,
                  ),
                ),

                const SizedBox(height: 8),

                Positioned(
                  top: 295,
                  left: 0,
                  right: 0,
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Global_Avatar_Widget(
                        imageUrl: _avatarUrl,
                        width: 50,
                        height: 50,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStats(
                          username: "${userModel.userName}",
                          profession: userModel.speciality ?? userModel.role.displayName,
                          specialty: 'www.doctormontiel.com',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          

          // 2. Sección inferior (Avatar, stats) — fluye naturalmente
          

          // 3. Posts destacados (Opcional)
          if (showFeaturedPosts && featuredPostsToShow.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _buildFeaturedPostsSection(featuredPostsToShow),
            ),
        ],
      ),
    );
  }
}