import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:provider/provider.dart';

class ClinicalStoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final String currentUserId;
  final int initialIndex;

  const ClinicalStoryViewer({
    super.key,
    required this.stories,
    required this.currentUserId,
    this.initialIndex = 0,
  });

  @override
  State<ClinicalStoryViewer> createState() => _ClinicalStoryViewerState();
}

class _ClinicalStoryViewerState extends State<ClinicalStoryViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  late List<AnimationController> _progressControllers;
  bool _isPaused = false;
  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _progressControllers = List.generate(
      widget.stories.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProgress();
      _markViewed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    for (final c in _progressControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startProgress() {
    _progressControllers[_currentIndex].forward();
    _timer = Timer(const Duration(seconds: 5), _nextStory);
  }

  void _resetProgress() {
    _progressControllers[_currentIndex].reset();
    _timer?.cancel();
  }

  void _pause() {
    setState(() => _isPaused = true);
    _progressControllers[_currentIndex].stop();
    _timer?.cancel();
  }

  void _resume() {
    setState(() => _isPaused = false);
    _progressControllers[_currentIndex].forward();
    _timer = Timer(const Duration(seconds: 5), _nextStory);
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _markViewed() {
    final story = widget.stories[_currentIndex];
    if (!story.viewedBy.contains(widget.currentUserId)) {
      context.read<DentistHomeProvider>().markStoryViewed(story.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onTap: () {
          setState(() => _showInfo = !_showInfo);
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              onPageChanged: (index) {
                _resetProgress();
                setState(() => _currentIndex = index);
                _startProgress();
                _markViewed();
              },
              itemBuilder: (context, index) {
                return _StoryPage(story: widget.stories[index]);
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  Row(
                    children: List.generate(widget.stories.length, (i) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: AnimatedBuilder(
                              animation: _progressControllers[i],
                              builder: (context, _) {
                                return LinearProgressIndicator(
                                  value: i < _currentIndex
                                      ? 1.0
                                      : i == _currentIndex
                                          ? _progressControllers[i].value
                                          : 0.0,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                  minHeight: 2.5,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  _buildStoryHeader(story),
                ],
              ),
            ),
            if (_showInfo)
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: _buildStoryCaption(story),
              ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: _isPaused
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.pause, color: Colors.white, size: 24),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryHeader(StoryModel story) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundImage: story.userPhoto != null && story.userPhoto!.isNotEmpty
              ? NetworkImage(story.userPhoto!)
              : null,
          child: story.userPhoto == null || story.userPhoto!.isEmpty
              ? Text(
                  story.userName.isNotEmpty ? story.userName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (story.sourceName.isNotEmpty && story.sourceName != story.userName)
                Text(
                  'Paciente: ${story.sourceName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: Colors.white, size: 22),
        ),
      ],
    );
  }

  Widget _buildStoryCaption(StoryModel story) {
    if (story.text == null || story.text!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        story.text!,
        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  final StoryModel story;
  const _StoryPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Center(
        child: CachedNetworkImage(
          imageUrl: story.imageUrl,
          fit: BoxFit.contain,
          placeholder: (_, __) => Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'Error al cargar imagen',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
