import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/screens/widgets/appbar/appbar-center.dart';
import 'package:medident/screens/widgets/scrolls/stories-scroll-widget.dart';
import 'package:medident/screens/widgets/new-post/create_newposts_widget.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:medident/screens/role/dentist/widget/post_one_widget.dart';
import 'package:medident/screens/role/dentist/stories/story-viewer-screen.dart';
import 'package:medident/screens/role/dentist/stories/create-story-screen.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/core/providers/ia/valeria-provider.dart';

class DentistHomeTablet extends StatefulWidget {
  final String userId;

  const DentistHomeTablet({Key? key, required this.userId}) : super(key: key);

  @override
  State<DentistHomeTablet> createState() => _DentistHomeTabletState();
}

class _DentistHomeTabletState extends State<DentistHomeTablet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DentistHomeProvider>().updateUserId(widget.userId);
      _registerValeriaTools();
    });
  }

  @override
  void dispose() {
    try {
      context.read<ValeriaProvider>().unregisterTool('navigate');
    } catch (_) {}
    super.dispose();
  }

  void _registerValeriaTools() {
    final valeria = context.read<ValeriaProvider>();
    valeria.registerTool('navigate', (params) {
      if (!mounted) return;
      final screen = params['screen'] as String?;
      if (screen == null) return;
      switch (screen) {
        case 'home':
          Navigator.popUntil(context, (route) => route.isFirst);
        case 'profile':
          Navigator.pushNamed(context, '/dentist/profile');
        case 'patients':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navegando a pacientes...')),
          );
        case 'appointments':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abriendo agenda...')),
          );
        case 'clinic':
          Navigator.pushNamed(context, '/dentist/clinic');
        case 'create_story':
          Navigator.pushNamed(context, '/dentist/create-story');
        case 'create_post':
          Navigator.pushNamed(context, '/dentist/create-post');
        case 'odontogram':
          Navigator.pushNamed(context, '/dentist/odontogram');
        case 'schedule':
          Navigator.pushNamed(context, '/dentist/schedule');
        case 'treatments':
          Navigator.pushNamed(context, '/dentist/treatments');
        case 'security':
          Navigator.pushNamed(context, '/dentist/security');
        case 'delivery':
          Navigator.pushNamed(context, '/dentist/delivery');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DentistHomeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => provider.refreshAll(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Appbar_Container_Widget(
                    title: 'Inicio',
                    leftIcon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, size: 25),
                    rightIcon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, size: 25),
                    leftIconTap: () {},
                    rightIconTap: () {},
                    backgroundColor: Colors.white,
                  ),
                ),
                SliverToBoxAdapter(
                  child: StoriesScroll_Widget(
                    stories: provider.stories,
                    currentUserName: provider.currentUserName,
                    currentUserPhoto: provider.currentUserPhoto,
                    currentUserStories: provider.currentUserStories,
                    isLoading: provider.isLoadingStories,
                    onStoryTap: (story) {
                  final bool isMyStory = provider.currentUserStories.any((s) => s.id == story.id);
                  List<StoryModel> allStories;
                  int initialIndex;
                  
                  if (isMyStory) {
                    allStories = provider.currentUserStories;
                  } else {
                    allStories = [...provider.currentUserStories, ...provider.stories];
                  }
                  
                  initialIndex = allStories.indexWhere((s) => s.id == story.id);
                  
                  if (initialIndex != -1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryViewerScreen(
                          stories: allStories,
                          initialIndex: initialIndex,
                          currentUserId: widget.userId,
                          provider: provider,
                        ),
                      ),
                    );
                  }
                },
                    onAddStoryTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateStoryScreen(
                            currentUserId: widget.userId,
                            currentUserName: provider.currentUserName,
                            currentUserPhoto: provider.currentUserPhoto,
                            provider: provider,
                          ),
                        ),
                      );
                    },
                    onLoadMore: provider.hasMoreStories ? () => provider.loadMoreStories() : null,
                    isLoadingMore: provider.isLoadingMore,
                    hasMore: provider.hasMoreStories,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Create_Newposts_Widget(
                    userId: provider.userId.isNotEmpty ? provider.userId : 'user_dentist_1',
                    userName: 'Dra. Ana García',
                    userPhoto: '',
                    onPublished: () => provider.refreshAll(),
                  ),
                ),
                if (provider.isLoading)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTabletShimmer(),
                      childCount: 4,
                    ),
                  )
                else if (provider.posts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No hay contenido disponible')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < provider.posts.length) {
                            return Post_One_Widget(
                              post: provider.posts[index],
                              currentUserId: provider.userId,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        childCount: provider.posts.length,
                      ),
                    ),
                  ),
                if (provider.isLoadingMore)
                  SliverToBoxAdapter(
                    child: _buildTabletShimmer(),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
    );
      },
    );
  }

  Widget _buildTabletShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 14,
                  width: 120,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
