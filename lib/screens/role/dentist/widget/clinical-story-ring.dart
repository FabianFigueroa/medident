import 'package:flutter/material.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';
import 'clinical-story-viewer.dart';

class ClinicalStoryRing extends StatelessWidget {
  final List<StoryModel> clinicalStories;
  final String currentUserId;
  final VoidCallback? onUploadTap;

  const ClinicalStoryRing({
    super.key,
    required this.clinicalStories,
    required this.currentUserId,
    this.onUploadTap,
  });

  List<MapEntry<String, List<StoryModel>>> get _groupedByPatient {
    final map = <String, List<StoryModel>>{};
    for (final story in clinicalStories) {
      final key = story.sourceId.isNotEmpty ? story.sourceId : story.userId;
      map.putIfAbsent(key, () => []).add(story);
    }
    final entries = map.entries.toList();
    entries.sort((a, b) {
      final aHasUnviewed = a.value.any((s) => !s.viewedBy.contains(currentUserId));
      final bHasUnviewed = b.value.any((s) => !s.viewedBy.contains(currentUserId));
      if (aHasUnviewed && !bHasUnviewed) return -1;
      if (!aHasUnviewed && bHasUnviewed) return 1;
      return b.value.first.createdAt.compareTo(a.value.first.createdAt);
    });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedByPatient;
    if (groups.isEmpty && onUploadTap == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.camera_alt_outlined, size: 14, color: Color(0xFF0EA5A4)),
              const SizedBox(width: 6),
              const Text(
                'Momentos Clínicos',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              if (onUploadTap != null)
                GestureDetector(
                  onTap: onUploadTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5A4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 12, color: Color(0xFF0EA5A4)),
                        SizedBox(width: 3),
                        Text(
                          'Agregar',
                          style: TextStyle(fontSize: 10, color: Color(0xFF0EA5A4), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: groups.length + (onUploadTap != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (onUploadTap != null && index == 0) {
                return _AddStoryButton(onTap: onUploadTap!);
              }
              final groupIndex = onUploadTap != null ? index - 1 : index;
              final entry = groups[groupIndex];
              final stories = entry.value;
              final hasUnviewed = stories.any((s) => !s.viewedBy.contains(currentUserId));
              return _PatientStoryRing(
                stories: stories,
                patientName: stories.first.sourceName.isNotEmpty
                    ? stories.first.sourceName
                    : stories.first.userName,
                patientPhoto: stories.first.sourcePhoto ?? stories.first.userPhoto,
                hasUnviewed: hasUnviewed,
                onTap: () => _openViewer(context, stories),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openViewer(BuildContext context, List<StoryModel> stories) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClinicalStoryViewer(
          stories: stories,
          currentUserId: currentUserId,
        ),
      ),
    );
  }
}

class _PatientStoryRing extends StatelessWidget {
  final List<StoryModel> stories;
  final String patientName;
  final String? patientPhoto;
  final bool hasUnviewed;
  final VoidCallback onTap;

  const _PatientStoryRing({
    required this.stories,
    required this.patientName,
    this.patientPhoto,
    required this.hasUnviewed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnviewed
                    ? const LinearGradient(
                        colors: [Color(0xFF0EA5A4), Color(0xFF3B82F6)],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade400],
                      ),
              ),
              child: ClipOval(
                child: Global_Avatar_Widget(
                  imageUrl: patientPhoto ?? '',
                  width: 48,
                  height: 48,
                  errorWidget: Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, size: 22, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              width: 56,
              child: Text(
                patientName.length > 10
                    ? '${patientName.substring(0, 10)}...'
                    : patientName,
                style: const TextStyle(fontSize: 9, color: Color(0xFF475569)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddStoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0EA5A4).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFF0EA5A4).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF0EA5A4), size: 24),
            ),
            const SizedBox(height: 3),
            const SizedBox(
              width: 56,
              child: Text(
                'Nuevo',
                style: TextStyle(fontSize: 9, color: Color(0xFF0EA5A4), fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
