import 'package:flutter/material.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class Stories_One_Widget extends StatelessWidget {
  final List<StoryModel> stories;
  final Function(StoryModel)? onStoryTap;

  const Stories_One_Widget({
    super.key,
    required this.stories,
    this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return GestureDetector(
            onTap: () {
              debugPrint('Story tapped from Stories_One_Widget: ${story.id}');
              onStoryTap?.call(story);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: story.isViewed 
                          ? [Colors.grey.shade400, Colors.grey.shade400]
                          : [Colors.pink, Colors.orange],
                      ),
                    ),
                    child: ClipOval(
                      child: Global_Avatar_Widget(
                        imageUrl: story.imageUrl,
                        width: 64,
                        height: 64,
                        errorWidget: Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 24, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 70,
                    child: Text(
                      story.userName.isNotEmpty ? story.userName : 'Usuario',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
