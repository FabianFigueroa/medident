import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';

const _storyDuration = Duration(seconds: 5);

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final String currentUserId;
  final DentistHomeProvider? provider;
  final void Function(String userId)? onProfileTap;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    required this.currentUserId,
    this.provider,
    this.onProfileTap,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isPaused = false;
  Timer? _storyTimer;
  double _progress = 0.0;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _showComments = false;
  List<Map<String, dynamic>> _comments = [];
  bool _isLiked = false;
  late AnimationController _likeAnimController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _likeAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _likeAnimController, curve: Curves.elasticOut),
    );
    _loadStoryData();
    _startTimer();
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    _pageController.dispose();
    _commentController.dispose();
    _commentFocus.dispose();
    _likeAnimController.dispose();
    super.dispose();
  }

  DentistHomeProvider _getProvider() {
    if (widget.provider == null) {
      throw StateError(
        'DentistHomeProvider not provided to StoryViewerScreen.',
      );
    }
    return widget.provider!;
  }

  void _startTimer() {
    _storyTimer?.cancel();
    _progress = 0.0;
    _isPaused = false;
    const tickDuration = Duration(milliseconds: 50);
    final totalTicks = _storyDuration.inMilliseconds / tickDuration.inMilliseconds;
    int ticks = 0;

    _storyTimer = Timer.periodic(tickDuration, (timer) {
      if (_isPaused) return;
      ticks++;
      _progress = ticks / totalTicks;
      if (_progress >= 1.0) {
        timer.cancel();
        _progress = 1.0;
        _goToNextStory();
      }
      if (mounted) setState(() {});
    });
  }

  void _goToNextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _pauseTimer() => setState(() => _isPaused = true);

  void _resumeTimer() => setState(() => _isPaused = false);

  Future<void> _loadStoryData() async {
    if (widget.stories.isEmpty || _currentIndex >= widget.stories.length) return;

    final story = widget.stories[_currentIndex];
    setState(() {
      _isLiked = story.likedBy.contains(widget.currentUserId);
    });
    await _loadComments(story.id);
    if (!story.viewedBy.contains(widget.currentUserId)) {
      try {
        await _getProvider().markStoryViewed(story.id);
      } catch (e) {
        debugPrint('Error marking story as viewed: $e');
      }
    }
  }

  Future<void> _loadComments(String storyId) async {
    try {
      final comments = await _getProvider().getStoryComments(storyId);
      if (mounted) setState(() => _comments = comments);
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
  }

  Future<void> _toggleLike() async {
    final story = widget.stories[_currentIndex];
    final wasLiked = _isLiked;
    final provider = _getProvider();

    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeAnimController.forward();
      } else {
        _likeAnimController.reverse();
      }
    });

    try {
      await provider.likeStory(story.id);
    } catch (e) {
      if (mounted) {
        setState(() => _isLiked = wasLiked);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final story = widget.stories[_currentIndex];
    final provider = _getProvider();

    _commentController.clear();
    _commentFocus.unfocus();

    try {
      await provider.addStoryComment(story.id, text);
      await _loadComments(story.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_isPaused) {
                  _resumeTimer();
                } else {
                  _pauseTimer();
                }
              },
              onLongPress: () => _pauseTimer(),
              onLongPressUp: () => _resumeTimer(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.stories.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _loadStoryData();
                  _startTimer();
                },
                itemBuilder: (context, index) {
                  final s = widget.stories[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (s.imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: s.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.white54, size: 50),
                                  SizedBox(height: 8),
                                  Text(
                                    'No se pudo cargar la imagen',
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                          ),
                        ),

                      if (s.text != null && s.text!.isNotEmpty)
                        Positioned(
                          top: 80,
                          left: 16,
                          right: 16,
                          child: Text(
                            s.text!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 12),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              // Progress bars row
                              Row(
                                children: widget.stories.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final isActive = idx == _currentIndex;
                                  final isCompleted = idx < _currentIndex;
                                  return Expanded(
                                    child: Container(
                                      height: 3,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: isActive
                                          ? FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: _progress,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                            )
                                          : isCompleted
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                )
                                              : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      widget.onProfileTap?.call(s.userId);
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.grey[800],
                                          backgroundImage: (s.userPhoto != null && s.userPhoto!.isNotEmpty)
                                              ? CachedNetworkImageProvider(s.userPhoto!)
                                              : null,
                                          child: (s.userPhoto == null || s.userPhoto!.isEmpty)
                                              ? const Icon(Icons.person, color: Colors.white70, size: 20)
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          s.userName.isNotEmpty ? s.userName : 'Usuario',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (s.likesCount > 0 || _comments.isNotEmpty)
                        Positioned(
                          bottom: _showComments ? 300 : 80,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (s.likesCount > 0)
                                Row(
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${s.likesCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              if (_comments.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.chat_bubble, color: Colors.white70, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_comments.length}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            if (_showComments)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: _comments.isEmpty
                            ? Center(
                                child: Text(
                                  'No hay comentarios aún',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  final comment = _comments[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.grey[300],
                                          child: const Icon(Icons.person, size: 16),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment['userName'] ?? 'Usuario',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                comment['content'] ?? '',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                focusNode: _commentFocus,
                                decoration: InputDecoration(
                                  hintText: 'Escribe un comentario...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _addComment(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Color(0xFF1877F2)),
                              onPressed: _addComment,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
              right: 8,
              bottom: 100,
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _likeAnimation,
                    child: _buildActionButton(
                      icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.white,
                      onTap: _toggleLike,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    color: Colors.white,
                    onTap: () {
                      _pauseTimer();
                      setState(() => _showComments = !_showComments);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.share,
                    color: Colors.white,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
