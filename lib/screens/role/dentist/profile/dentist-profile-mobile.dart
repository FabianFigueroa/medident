import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:medident/core/providers/dentist/dentist-profile-provider.dart';
import 'package:medident/screens/role/dentist/profile/widgets/header_container_widget.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-gallery-widget.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-services-widget.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-info-widget.dart';
import 'package:provider/provider.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-profile-header-widget.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:medident/main_export.dart';

class DentistProfile_Mobile extends StatelessWidget {
  final TrackingScrollController scrollController;
  final bool isDesktop;

  const DentistProfile_Mobile({
    super.key,
    required this.scrollController,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DentistProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FB),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (profileProvider.error != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FB),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Ocurrio un error al cargar el perfil: ${profileProvider.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final userProfile = profileProvider.userProfile;

        if (userProfile == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FB),
            body: Center(child: Text('No se pudo cargar la información del usuario.')),
          );
        }

        final currentUser = context.read<AuthenticateProvider>().user;
        final isOwnProfile = currentUser != null && userProfile.uid == currentUser.uid;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: Appbar_Container_Widget(
            leftIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedHospital01,
              size: 24,
            ),
            rightIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              size: 24,
            ),
            title: userProfile.fullName.isNotEmpty
                ? userProfile.fullName.split(' ').first
                : 'Perfil',
            gradientColorStart: AppColors.tealColor,
            gradientColorEnd: AppColors.primary,
            backgroundColor: AppColors.white,
            leftIconTap: () {
              final provider = context.read<DentistMainProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: const DentistClinicScreen(),
                  ),
                ),
              );
            },
            rightIconTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountScreenMobile(
                    uid: currentUser?.uid ?? '',
                  ),
                ),
              );
            },
          ),
          body: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Header_Container_Widget(
                  userModel: userProfile,
                  isFollowing: profileProvider.isFollowing,
                  isOwnProfile: isOwnProfile,
                  onEditProfilePressed: () => _handleEditProfile(context),
                  onFollowPressed: profileProvider.toggleFollow,
                  promotions: profileProvider.promotions,
                  featuredPosts: profileProvider.featuredPosts,
                  showFeaturedPosts: true,
                  onPromotionEdit: () => _handleEditPromotion(profileProvider),
                  onPromotionDelete: () => _handleDeletePromotion(profileProvider),
                  onPromotionShare: () => _handleSharePromotion(profileProvider),
                  onFeaturedPostTap: () => _handleFeaturedPostTap(),
                ),
              ),
              SliverToBoxAdapter(
                child: DentistInfoWidget(
                  userModel: userProfile,
                  isOwnProfile: isOwnProfile,
                  onEditPressed: () => _handleEditProfile(context),
                ),
              ),
              SliverToBoxAdapter(
                child: DentistServicesWidget(
                  services: profileProvider.services,
                  isOwnProfile: isOwnProfile,
                  onServiceTap: (int index) => debugPrint('Service: $index'),
                ),
              ),
              SliverToBoxAdapter(
                child: DentistGalleryWidget(
                  images: profileProvider.galleryImages,
                  isOwnProfile: isOwnProfile,
                  onImageTap: (int index) => debugPrint('Image: $index'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        );
      },
    );
  }

  void _handleEditProfile(BuildContext context) {
    final currentUser = context.read<AuthenticateProvider>().user;
    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountScreenMobile(uid: currentUser.uid),
        ),
      );
    }
  }

  void _handleEditPromotion(DentistProfileProvider provider) {
    debugPrint('Editar promoción - Implementar lógica de navegación a pantalla de edición');
  }

  void _handleDeletePromotion(DentistProfileProvider provider) {
    debugPrint('Eliminar promoción - Implementar lógica de eliminación');
  }

  void _handleSharePromotion(DentistProfileProvider provider) {
    debugPrint('Compartir promoción - Implementar lógica de compartir');
  }

  void _handleFeaturedPostTap() {
    debugPrint('Post destacado tocado - Implementar lógica de navegación');
  }
}
