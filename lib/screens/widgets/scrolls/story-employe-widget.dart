import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/main_export.dart' hide ProfileAvatar;
import 'package:medident/screens/widgets/avatar/profile-avatar.dart';

class StoryPanelWidget extends StatelessWidget {
  final UserModel? currentUser;
  final List<StoryModel> stories;
  final Function(StoryModel)? onStoryTap;
  final VoidCallback? onAddStoryTap;

  const StoryPanelWidget({
    Key? key,
    this.currentUser,
    required this.stories,
    this.onStoryTap,
    this.onAddStoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const Center(
        child: Text('No hay historias disponibles.'),
      );
    }

    return Container(
      height: 200,
      color: ResponsiveUtils.isDesktop(context) ? Colors.transparent : Colors.white,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 8,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: 1 + stories.length,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _StoryCard(
                  isAddStory: true,
                  currentUser: currentUser,
                  onAddStoryTap: onAddStoryTap,
                ),
              );
            }

            final StoryModel story = stories[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _StoryCard(
                story: story,
                onStoryTap: onStoryTap,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final bool isAddStory;
  final UserModel? currentUser;
  final StoryModel? story;
  final Function(StoryModel)? onStoryTap;
  final VoidCallback? onAddStoryTap;

  const _StoryCard({
    Key? key,
    this.isAddStory = false,
    this.currentUser,
    this.story,
    this.onStoryTap,
    this.onAddStoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storyImageUrl = isAddStory ? currentUser?.imageUrl ?? '' : story?.imageUrl ?? '';
    final userImageUrl = isAddStory ? currentUser?.imageUrl ?? '' : story?.userPhoto ?? '';
    final userName = isAddStory ? 'Publicar' : story?.userName ?? 'Desconocido';

    return GestureDetector(
      onTap: () {
        if (isAddStory) {
          onAddStoryTap?.call();
        } else if (story != null) {
          debugPrint('Story tapped from StoryPanelWidget: ${story!.id}');
          onStoryTap?.call(story!);
        }
      },
      child: SizedBox(
        width: 120,
        child: Stack(
          children: [
            // Imagen de fondo de la historia
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: storyImageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 30),
                ),
              ),
            ),
            
            // Gradiente para mejorar la visibilidad del texto
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Contenido del card
            Positioned(
              top: 8,
              left: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar circular del usuario
                  ProfileAvatar(
                    imageUrl: userImageUrl,
                    hasBorder: story?.isViewed ?? false,
                  ),

                  const SizedBox(height: 8),

                  // Nombre y rol del usuario
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Botón redondo para el estado del usuario
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  debugPrint('Estado del usuario: ${story?.status}');
                },
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: story?.status == 'active'
                        ? Colors.green
                        : story?.status == 'busy'
                            ? Colors.red
                            : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
