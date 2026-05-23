import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/screens/role/dentist/widget/jobs_one_widget.dart';
import 'package:medident/screens/role/dentist/widget/suggested-follow-widget.dart';
import 'package:medident/screens/widgets/carousel/promotions-carousel-widget.dart';
import 'package:medident/screens/widgets/scrolls/stories-scroll-widget.dart';
import 'package:medident/screens/shared/public-profile-screen.dart';
import 'package:medident/screens/shared/notification-screen.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:medident/core/providers/notification/notification-provider.dart';
import 'package:medident/screens/role/dentist/widget/post_one_widget.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/screens/role/dentist/widget/treatments-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/appointments-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/odontogram-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/reels-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/visits-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/turnos-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/product-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/messages-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/calls-one-widget.dart';
import 'package:medident/screens/role/dentist/widget/invoices-one-widget.dart';
import 'package:medident/screens/role/dentist/stories/story-viewer-screen.dart';
import 'package:medident/screens/role/dentist/stories/create-story-screen.dart';
import 'package:medident/core/providers/ia/valeria-provider.dart';
import 'package:medident/core/models/post-model.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/models/jobs-model.dart';

class DentistHomeMobile extends StatefulWidget {
  final String userId;

  const DentistHomeMobile({Key? key, required this.userId}) : super(key: key);

  @override
  State<DentistHomeMobile> createState() => _DentistHomeMobileState();
}

class _DentistHomeMobileState extends State<DentistHomeMobile> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DentistHomeProvider>().updateUserId(widget.userId);
      _registerValeriaTools();
    });
    _scrollController.addListener(_onScroll);
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
  void dispose() {
    try {
      context.read<ValeriaProvider>().unregisterTool('navigate');
    } catch (_) {}
    _scrollDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 600) {
      _scrollDebounce?.cancel();
      _scrollDebounce = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        final provider = context.read<DentistHomeProvider>();
        if (!provider.isLoadingMore && provider.hasMorePosts) {
          provider.loadMorePosts();
        }
      });
    }
  }

  @override
  void didUpdateWidget(DentistHomeMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      context.read<DentistHomeProvider>().updateUserId(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<DentistHomeProvider>().refreshAll(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: const [
            _AppBarSection(),
            _CarouselSection(),
            _StoriesSection(),
            _ContentSection(),
            _LoadingMoreShimmer(),
            SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: const SizedBox.shrink(),
    );
  }
}

// ─── AppBar (nunca cambia) ───────────────────────────────────
class _AppBarSection extends StatelessWidget {
  const _AppBarSection();

  @override
  Widget build(BuildContext context) {
    final title = context.select<DentistHomeProvider, String>((p) => p.userId);
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        color: Colors.white,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationScreen()),
              ),
              child: _NotificationBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carousel promociones ────────────────────────────────────
class _CarouselSection extends StatelessWidget {
  const _CarouselSection();

  @override
  Widget build(BuildContext context) {
    final products = context.select<DentistHomeProvider, List<ProductModel>>(
      (p) => p.products,
    );
    return SliverToBoxAdapter(
      child: products.isEmpty
          ? const SizedBox(height: 210)
          : Promotions_Carousel_Widget(
              products: products.take(5).toList(),
              onProductTap: (product) {},
            ),
    );
  }
}

// ─── Stories ─────────────────────────────────────────────────
class _StoriesSection extends StatelessWidget {
  const _StoriesSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistHomeProvider>();
    return SliverToBoxAdapter(
      child: StoriesScroll_Widget(
        stories: provider.stories,
        currentUserName: provider.currentUserName,
        currentUserPhoto: provider.currentUserPhoto,
        currentUserStories: provider.currentUserStories,
        isLoading: provider.isLoadingStories,
        onAvatarTap: (userId) {
          Navigator.push(
            context,
            MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(userId: userId, currentUserId: provider.userId),
                      ),
                    );
                  },
        onStoryTap: (story) {
          final isMyStory = provider.currentUserStories.any((s) => s.id == story.id);
          List<StoryModel> allStories;
          int? initialIndex;

          if (isMyStory) {
            allStories = provider.currentUserStories;
            if (allStories.isNotEmpty) {
              initialIndex = allStories.indexWhere((s) => s.id == story.id);
            }
          } else {
            allStories = [...provider.currentUserStories, ...provider.stories];
            if (allStories.isNotEmpty) {
              initialIndex = allStories.indexWhere((s) => s.id == story.id);
            }
          }

          if (initialIndex != null && initialIndex != -1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoryViewerScreen(
                  stories: allStories,
                  initialIndex: initialIndex!,
                  currentUserId: provider.userId,
                  provider: provider,
                  onProfileTap: (userId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(userId: userId, currentUserId: provider.userId),
                      ),
                    );
                  },
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
                currentUserId: provider.userId,
                currentUserName: provider.currentUserName,
                currentUserPhoto: provider.currentUserPhoto,
                provider: provider,
              ),
            ),
          );
        },
        onLoadMore: provider.hasMoreStories
            ? () => provider.loadMoreStories()
            : null,
        isLoadingMore: provider.isLoadingMore,
        hasMore: provider.hasMoreStories,
      ),
    );
  }
}

// ─── Contenido principal (loading / error / empty / feed) ─────
class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<DentistHomeProvider, bool>((p) => p.isLoading);
    final loadError = context.select<DentistHomeProvider, String?>((p) => p.loadError);
    final posts = context.select<DentistHomeProvider, List<PostModel>>((p) => p.posts);
    final stories = context.select<DentistHomeProvider, List<StoryModel>>((p) => p.stories);
    final products = context.select<DentistHomeProvider, List<ProductModel>>((p) => p.products);
    final jobs = context.select<DentistHomeProvider, List<JobModel>>((p) => p.jobs);

    if (isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildPostShimmer(),
          childCount: 2,
        ),
      );
    }

    if (loadError != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No se pudo cargar el home',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => context.read<DentistHomeProvider>().refreshAll(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty && stories.isEmpty && products.isEmpty && jobs.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Aún no hay contenido para mostrar.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _IntercalatedFeed();
  }

  static Widget _buildPostShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 120, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(height: 10, width: 80, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 16, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 16, width: 200, color: Colors.white),
            const SizedBox(height: 12),
            Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (i) => Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading shimmer bottom ──────────────────────────────────
class _LoadingMoreShimmer extends StatelessWidget {
  const _LoadingMoreShimmer();

  @override
  Widget build(BuildContext context) {
    final isLoadingMore = context.select<DentistHomeProvider, bool>((p) => p.isLoadingMore);
    if (!isLoadingMore) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: _buildInlineShimmer(),
    );
  }

  static Widget _buildInlineShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Container(height: 14, width: 120, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feed intercalado (posts + widgets) ──────────────────────
class _IntercalatedFeed extends StatelessWidget {
  _IntercalatedFeed();

  @override
  Widget build(BuildContext context) {
    final isLoadingMore = context.select<DentistHomeProvider, bool>((p) => p.isLoadingMore);
    final totalPosts = context.select<DentistHomeProvider, int>((p) => p.posts.length);
    if (totalPosts == 0) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final interleavedWidgets = (totalPosts / 3).ceil();
    final itemCount = totalPosts + interleavedWidgets;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          if (index == itemCount - 1 && isLoadingMore) {
            return _LoadingMoreShimmer._buildInlineShimmer();
          }
          return _FeedItem(index: index);
        },
        childCount: itemCount + (isLoadingMore ? 1 : 0),
      ),
    );
  }
}

class _FeedItem extends StatelessWidget {
  final int index;
  const _FeedItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistHomeProvider>();
    final totalPosts = provider.posts.length;
    if (totalPosts == 0) return const SizedBox.shrink();

    const postsPerBlock = 3;
    const blockSize = 4;
    final blockIndex = index ~/ blockSize;
    final positionInBlock = index % blockSize;

    if (positionInBlock == 2) {
      return _IntercalatedWidget(blockIndex: blockIndex);
    }

    final postIndex = (blockIndex * postsPerBlock) + positionInBlock;

    if (postIndex >= totalPosts - 2 &&
        !provider.isLoadingMore &&
        provider.hasMorePosts) {
      Future.microtask(() => provider.loadMorePosts());
    }

    if (postIndex < totalPosts) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
        child: Post_One_Widget(
          post: provider.posts[postIndex],
          currentUserId: provider.userId,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _IntercalatedWidget extends StatelessWidget {
  final int blockIndex;
  const _IntercalatedWidget({required this.blockIndex});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistHomeProvider>();
    switch (blockIndex % 14) {
      case 0:
      case 1:
        return _lazyWidget(
          context,
          isEmpty: provider.products.isEmpty,
          load: () => provider.loadPromotions(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Promotions_Carousel_Widget(
              products: provider.products.where((p) => p.scope == 'global').take(5).toList(),
              onProductTap: (product) {},
            ),
          ),
          height: 150,
        );
      case 2:
        return _lazyWidget(
          context,
          isEmpty: provider.suggested_Friends.isEmpty,
          load: () => provider.loadSuggested_Friends(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Suggested_follow_Widget(
              userModelList: provider.suggested_Friends.take(5).toList(),
              onFollow: (String p1) {},
            ),
          ),
          height: 100,
        );
      case 3:
        return _lazyWidget(
          context,
          isEmpty: provider.jobs.isEmpty,
          load: () => provider.loadJobs(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Job_One_Widget(
              job: provider.jobs[blockIndex % provider.jobs.length],
              currentUserId: provider.userId,
            ),
          ),
          height: 120,
        );
      case 4:
        return _lazyWidget(
          context,
          isEmpty: provider.treatments.isEmpty,
          load: () => provider.loadTreatments(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Treatments_One_Widget(
              treatments: provider.treatments.take(4).toList(),
              onTap: (treatment) {},
            ),
          ),
          height: 100,
        );
      case 5:
        return _lazyWidget(
          context,
          isEmpty: provider.appointments.isEmpty,
          load: () => provider.loadAppointments(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Appointments_One_Widget(
              appointments: provider.appointments.take(4).toList(),
              onTap: (appointment) {},
            ),
          ),
          height: 120,
        );
      case 6:
        return _lazyWidget(
          context,
          isEmpty: provider.turnos.isEmpty,
          load: () => provider.loadTurnos(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TurnosOneWidget(
              onTap: (turno) {},
              onStatusChange: (id, status) {},
            ),
          ),
          height: 120,
        );
      case 7:
        return _lazyWidget(
          context,
          isEmpty: provider.odontograms.isEmpty,
          load: () => provider.loadOdontograms(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Odontogram_One_Widget(
              odontograms: provider.odontograms.take(3).toList(),
              onTap: (odontogram) {},
            ),
          ),
          height: 100,
        );
      case 8:
        return _lazyWidget(
          context,
          isEmpty: provider.shopProducts.isEmpty,
          load: () => provider.loadShopProducts(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Product_One_Widget(
              products: provider.shopProducts.take(5).toList(),
            ),
          ),
          height: 130,
        );
      case 9:
        return _lazyWidget(
          context,
          isEmpty: provider.chatMessages.isEmpty,
          load: () => provider.loadMessages(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Messages_One_Widget(
              messages: provider.chatMessages.take(3).toList(),
              onTap: (message) {},
            ),
          ),
          height: 100,
        );
      case 10:
        return _lazyWidget(
          context,
          isEmpty: provider.videoCalls.isEmpty,
          load: () => provider.loadCalls(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Calls_One_Widget(
              calls: provider.videoCalls.take(3).toList(),
              onTap: (call) {},
            ),
          ),
          height: 100,
        );
      case 11:
        return _lazyWidget(
          context,
          isEmpty: provider.billInvoices.isEmpty,
          load: () => provider.loadInvoices(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Invoices_One_Widget(
              invoices: provider.billInvoices.take(3).toList(),
              onTap: (invoice) {},
            ),
          ),
          height: 100,
        );
      case 12:
        return _lazyWidget(
          context,
          isEmpty: provider.clinicalVisits.isEmpty,
          load: () => provider.loadVisits(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Visits_One_Widget(
              visits: provider.clinicalVisits.take(3).toList(),
              onTap: (visit) {},
            ),
          ),
          height: 100,
        );
      case 13:
        return _lazyWidget(
          context,
          isEmpty: provider.shortReels.isEmpty,
          load: () => provider.loadReels(),
          builder: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Reels_One_Widget(
              reels: provider.shortReels.take(5).toList(),
              onTap: (reel) {},
            ),
          ),
          height: 200,
        );
    }
    return const SizedBox.shrink();
  }
}

Widget _lazyWidget(
  BuildContext context, {
  required bool isEmpty,
  required VoidCallback load,
  required Widget Function() builder,
  double height = 100,
}) {
  if (isEmpty) {
    load();
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  return builder();
}

class _NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.notifications_outlined,
              color: Colors.grey, size: 24),
        ),
        if (unreadCount > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
