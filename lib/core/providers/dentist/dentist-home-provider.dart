import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medident/core/models/jobs-model.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/models/media-item.dart';
import 'package:medident/core/services/dentist/dentist-home-services.dart';
import 'package:medident/core/services/cache/home-cache-service.dart';
import 'package:medident/core/services/cache/user-cache-service.dart';
import 'package:medident/core/models/post-model.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/models/user-light-model.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/models/odontogram-model.dart';
import 'package:medident/core/models/turno-model.dart';
import 'package:medident/core/models/promo-model.dart';

class DentistHomeProvider with ChangeNotifier {
  final DentistHomeService _service;
  String _userId;
  String? _clinicId;

  List<PostModel> _posts = [];
  List<StoryModel> _stories = [];
  List<ProductModel> _products = [];
  List<JobModel> _jobs = [];
  List<UserModel> _suggestedUsers = [];
  List<ProductModel> _myPromotions = [];
  List<TreatmentModel> _treatments = [];
  List<AppointmentModel> _appointments = [];
  List<OdontogramModel> _odontograms = [];
  List<TurnoModel> _turnos = [];
  List<ProductModel> _shopProducts = [];
  List<Map<String, dynamic>> _chatMessages = [];
  List<Map<String, dynamic>> _videoCalls = [];
  List<Map<String, dynamic>> _billInvoices = [];
  List<Map<String, dynamic>> _clinicalVisits = [];
  List<Map<String, dynamic>> _shortReels = [];
  List<StoryModel> _currentUserStories = [];
  String _currentUserName = '';
  String _currentUserPhoto = '';

  DentistHomeProvider({
    required DentistHomeService service,
    required String userId,
    String? clinicId,
  })  : _service = service,
        _userId = userId,
        _clinicId = clinicId;

  bool _isLoading = true;
  bool _isDataLoading = false;
  bool _isLoadingStories = true;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  bool _hasLoadedInitialData = false;
  bool _isDisposed = false;
  bool _hasMoreStories = true;
  bool _hasPaginatedBeyond = false;
  String? _loadError;
  DocumentSnapshot? _lastPostDocument;
  DocumentSnapshot? _lastStreamSnapshot;
  DocumentSnapshot? _lastStoryDocument;

  // Streams de escucha en tiempo real
  StreamSubscription<QuerySnapshot>? _postsSub;
  StreamSubscription<QuerySnapshot>? _storiesSub;
  StreamSubscription<DocumentSnapshot>? _userSub;

  List<PostModel> get posts => _posts;
  List<StoryModel> get stories => _stories;
  List<ProductModel> get products => _products;
  List<JobModel> get jobs => _jobs;
  List<UserModel> get suggested_Friends => _suggestedUsers;
  List<ProductModel> get myPromotions => _myPromotions;
  List<TurnoModel> get turnos => _turnos;
  List<TreatmentModel> get treatments => _treatments;
  List<AppointmentModel> get appointments => _appointments;
  List<OdontogramModel> get odontograms => _odontograms;
  List<ProductModel> get shopProducts => _shopProducts;
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  List<Map<String, dynamic>> get videoCalls => _videoCalls;
  List<Map<String, dynamic>> get billInvoices => _billInvoices;
  List<Map<String, dynamic>> get clinicalVisits => _clinicalVisits;
  List<Map<String, dynamic>> get shortReels => _shortReels;
  List<StoryModel> get currentUserStories => _currentUserStories;
  String get currentUserName => _currentUserName;
  String get currentUserPhoto => _currentUserPhoto;
  bool get isLoading => _isLoading;
  bool get isLoadingStories => _isLoadingStories;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePosts => _hasMorePosts;
  bool get hasMoreStories => _hasMoreStories;
  String? get loadError => _loadError;
  String get userId => _userId;
  String? get clinicId => _clinicId;

  void setCurrentUserData({
    required String userId,
    required String userName,
    String? userPhoto,
  }) {
    _userId = userId;
    _currentUserName = userName;
    _currentUserPhoto = userPhoto ?? '';
    if (_currentUserStories.isEmpty) {
      loadMyStories();
    }
  }

  Future<void> loadMyStories() async {
    if (_userId.isEmpty) return;
    try {
      _currentUserStories = await _service.getMyStories(_userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading my stories: $e');
    }
  }

  void updateUserId(String newUserId) {
    if (_userId != newUserId) {
      _userId = newUserId;
      _hasLoadedInitialData = false;
      _cancelSubscriptions();
      _loadCurrentUserData();
      loadInitialData();
    }
  }

  Future<void> _loadCurrentUserData() async {
    if (_userId.isEmpty) return;
    try {
      final user = await _service.getUser(_userId);
      if (user != null) {
        _currentUserName = user.fullName;
        _currentUserPhoto = user.imageUrl ?? '';
        UserCacheService.saveUser(user);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading current user data: $e');
    }
  }

  void _cancelSubscriptions() {
    _postsSub?.cancel();
    _storiesSub?.cancel();
    _userSub?.cancel();
  }

  void _subscribeToPosts() {
    _postsSub?.cancel();
    _postsSub = _service.streamPosts(clinicId: _clinicId).listen(
      (snap) {
        final freshPosts = snap.docs.map((d) {
          final data = d.data();
          data['id'] = d.id;
          return PostModel.fromJson(data, d.id);
        }).toList();

        if (!_hasPaginatedBeyond) {
          _posts = freshPosts;
          _lastPostDocument = snap.docs.isNotEmpty ? snap.docs.last : null;
          _lastStreamSnapshot = snap.docs.isNotEmpty ? snap.docs.last : null;
        }
        _hasMorePosts = freshPosts.length >= 10;
        _isLoading = false;
        if (mounted) notifyListeners();
      },
      onError: (e) {
        debugPrint('Posts stream error: $e');
        _isLoading = false;
        if (mounted) notifyListeners();
      },
    );
  }

  // ── Suscripción en tiempo real a stories ─────────────────
  void _subscribeToStories() {
    _storiesSub?.cancel();
    _storiesSub = _service.streamStories().listen(
      (snap) {
        final allStories = snap.docs
            .map((d) => StoryModel.fromJson(d.data(), d.id))
            .toList();
        _stories = allStories.where((s) => s.userId != _userId).toList();
        _isLoadingStories = false;
        _hasMoreStories = allStories.length >= 20;
        if (mounted) notifyListeners();
      },
      onError: (e) {
        debugPrint('Stories stream error: $e');
        _isLoadingStories = false;
        if (mounted) notifyListeners();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  CARGA INICIAL: cache local → streams → lazy secondary
  // ═══════════════════════════════════════════════════════════
  Future<void> loadInitialData({bool force = false}) async {
    if (_isDataLoading && !force) return;

    if (force) {
      _hasLoadedInitialData = false;
      _posts.clear();
      _stories.clear();
      _suggestedUsers.clear();
      _currentUserStories.clear();
      _lastPostDocument = null;
      _lastStreamSnapshot = null;
      _lastStoryDocument = null;
      _hasMorePosts = true;
      _hasMoreStories = true;
      _hasPaginatedBeyond = false;
    }

    if (_hasLoadedInitialData && !force) return;

    _isDataLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      if (_userId.isEmpty) {
        _isDataLoading = false;
        _isLoading = false;
        _isLoadingStories = false;
        notifyListeners();
        return;
      }

      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        _currentUserName = fbUser.displayName ?? fbUser.email ?? '';
        _currentUserPhoto = fbUser.photoURL ?? '';
      }

      // 1) Instant first paint from local cache
      await _loadFromCache();
      final cachedUser = await UserCacheService.loadUser(_userId);
      if (cachedUser != null && _currentUserName.isEmpty) {
        _currentUserName = cachedUser.fullName;
        _currentUserPhoto = cachedUser.imageUrl ?? '';
      }

      // 2) Streams en tiempo real (Firestore cache-first → server)
      _subscribeToPosts();
      _subscribeToStories();

      // 3) Lazy: secondary data solo cuando el widget lo pida
      unawaited(_loadSecondaryData());

      _hasLoadedInitialData = true;
      _isDataLoading = false;
      notifyListeners();
    } catch (e) {
      _loadError = e.toString();
      _isDataLoading = false;
      _isLoading = false;
      _isLoadingStories = false;
      notifyListeners();
      debugPrint('Error loading dentist home data: $e');
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = await HomeCacheService.load(_userId);
      if (cached == null) return;
      _currentUserName = cached.userName;
      _currentUserPhoto = cached.userPhoto;
      if (_posts.isEmpty) _posts = cached.posts;
      if (_stories.isEmpty) _stories = cached.stories;
      if (_currentUserStories.isEmpty) _currentUserStories = cached.currentUserStories;
      if (_suggestedUsers.isEmpty) _suggestedUsers = cached.suggestedUsers;
      if (_products.isEmpty) _products = cached.products;
      if (_jobs.isEmpty) _jobs = cached.jobs;
      if (_treatments.isEmpty) _treatments = cached.treatments;
      if (_appointments.isEmpty) _appointments = cached.appointments;
      _isLoading = false;
      _isLoadingStories = false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadSecondaryData() async {
    try {
      // Critical first (visible above the fold)
      final criticalTasks = await Future.wait([
        _service.getMyStories(_userId),
        _service.getGlobalPromotions(),
        _service.getSuggested_Friends(limit: 5),
      ], eagerError: false);

      if (!_isDisposed) {
        _currentUserStories = criticalTasks[0] as List<StoryModel>;
        _products = criticalTasks[1] as List<ProductModel>;
        _suggestedUsers = criticalTasks[2] as List<UserModel>;
        _isLoading = false;
        _isLoadingStories = false;
        notifyListeners();
      }

      // Deferred (loaded after first paint)
      final deferredTasks = await Future.wait([
        _service.getJobs(limit: 5),
        _service.getTreatments(limit: 10),
        _service.getAppointments(dentistId: _userId, limit: 10),
      ], eagerError: false);

      if (!_isDisposed) {
        _jobs = deferredTasks[0] as List<JobModel>;
        _treatments = deferredTasks[1] as List<TreatmentModel>;
        _appointments = deferredTasks[2] as List<AppointmentModel>;
        notifyListeners();
        unawaited(_saveToCache());
      }
    } catch (e) {
      debugPrint('Secondary data load error: $e');
      _isLoading = false;
      _isLoadingStories = false;
      if (mounted) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelSubscriptions();
    super.dispose();
  }

  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts || _userId.isEmpty) return;
    _isLoadingMore = true;
    _hasPaginatedBeyond = true;
    notifyListeners();
    try {
      final cursor = _lastPostDocument ?? _lastStreamSnapshot;
      final result = await _service.getPostsPaginated(
        limit: 10,
        lastDoc: cursor,
        clinicId: _clinicId,
      );
      final newPosts = result['posts'] as List<PostModel>;
      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        _posts.addAll(newPosts);
        _lastPostDocument = result['lastDocument'];
      }
    } catch (e) {
      debugPrint('Error loading more posts: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Paginación de stories ────────────────────────────
  Future<void> loadMoreStories() async {
    if (_isLoadingMore || !_hasMoreStories || _lastStoryDocument == null) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final result = await _service.getStoriesPaginated(
        limit: 20,
        lastDoc: _lastStoryDocument,
      );
      final newStories = result['stories'] as List<StoryModel>;
      if (newStories.isEmpty) {
        _hasMoreStories = false;
      } else {
        _stories.addAll(newStories);
        _lastStoryDocument = result['lastDocument'];
      }
    } catch (e) {
      debugPrint('Error loading more stories: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> likeStory(String storyId) async {
    if (_userId.isEmpty) return;
    try {
      await _service.likeStory(storyId, _userId);
      final i = _stories.indexWhere((s) => s.id == storyId);
      if (i != -1) {
        final story = _stories[i];
        final isLiked = story.likedBy.contains(_userId);
        _stories[i] = story.copyWith(
          likesCount: isLiked ? story.likesCount - 1 : story.likesCount + 1,
          likedBy: isLiked
              ? (story.likedBy..remove(_userId))
              : (story.likedBy..add(_userId)),
        );
        notifyListeners();
      }
      final j = _currentUserStories.indexWhere((s) => s.id == storyId);
      if (j != -1) {
        final story = _currentUserStories[j];
        final isLiked = story.likedBy.contains(_userId);
        _currentUserStories[j] = story.copyWith(
          likesCount: isLiked ? story.likesCount - 1 : story.likesCount + 1,
          likedBy: isLiked
              ? (story.likedBy..remove(_userId))
              : (story.likedBy..add(_userId)),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error liking story: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStoryComments(String storyId) async {
    try {
      return await _service.getStoryComments(storyId);
    } catch (e) {
      debugPrint('Error getting story comments: $e');
      return [];
    }
  }

  Future<void> addStoryComment(String storyId, String content) async {
    if (_userId.isEmpty) return;
    try {
      await _service.addStoryComment(storyId, _userId, content);
    } catch (e) {
      debugPrint('Error adding story comment: $e');
      rethrow;
    }
  }

  Future<void> markStoryViewed(String storyId) async {
    if (_userId.isEmpty) return;
    try {
      await _service.markStoryViewed(storyId, _userId);
      final i = _stories.indexWhere((s) => s.id == storyId);
      if (i != -1) {
        final story = _stories[i];
        if (!story.viewedBy.contains(_userId)) {
          _stories[i] = story.copyWith(
            viewedBy: [...story.viewedBy, _userId],
            isViewed: true,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error marking story viewed: $e');
    }
  }

  Future<void> loadPosts() async {
    if (_posts.isNotEmpty) return;
    _subscribeToPosts();
  }

  Future<void> loadStories() async {
    if (_stories.isNotEmpty && _hasLoadedInitialData) return;
    _subscribeToStories();
  }

  Future<void> loadJobs() async {
    if (_jobs.isNotEmpty) return;
    try {
      _jobs = await _service.getJobs(limit: 5);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading jobs: $e');
    }
  }

  Future<void> loadSuggested_Friends() async {
    try {
      _suggestedUsers = await _service.getSuggested_Friends(limit: 5);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading suggested users: $e');
    }
  }

  Future<void> loadTreatments() async {
    if (_treatments.isNotEmpty) return;
    try {
      _treatments = await _service.getTreatments(limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading treatments: $e');
    }
  }

  Future<void> loadAppointments() async {
    if (_appointments.isNotEmpty) return;
    if (_userId.isEmpty) return;
    try {
      _appointments =
          await _service.getAppointments(dentistId: _userId, limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading appointments: $e');
    }
  }

  Future<void> loadOdontograms() async {
    if (_odontograms.isNotEmpty) return;
    if (_userId.isEmpty) return;
    try {
      _odontograms =
          await _service.getOdontograms(dentistId: _userId, limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading odontograms: $e');
    }
  }

  Future<void> loadTurnos() async {
    if (_turnos.isNotEmpty) return;
    if (_userId.isEmpty) return;
    try {
      _turnos = await _service.getTurnos(dentistId: _userId, limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading turnos: $e');
    }
  }

  Future<void> loadShopProducts() async {
    if (_shopProducts.isNotEmpty) return;
    try {
      _shopProducts = await _service.getShopProducts(limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading shop products: $e');
    }
  }

  Future<void> loadProducts() async {
    await loadShopProducts();
  }

  Future<void> loadPromotions() async {
    if (_products.isNotEmpty) return;
    try {
      _products = await _service.getGlobalPromotions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading promotions: $e');
    }
  }

  Future<void> loadMessages() async {
    if (_userId.isEmpty) return;
    try {
      _chatMessages = await _service.getChatMessages(limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> loadCalls() async {
    if (_userId.isEmpty) return;
    try {
      _videoCalls = await _service.getVideoCalls(limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading calls: $e');
    }
  }

  Future<void> loadInvoices() async {
    if (_userId.isEmpty) return;
    try {
      _billInvoices = await _service.getBillInvoices(limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading invoices: $e');
    }
  }

  Future<void> loadVisits() async {
    if (_userId.isEmpty) return;
    try {
      _clinicalVisits = await _service.getClinicalVisits(limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading visits: $e');
    }
  }

  Future<void> loadReels() async {
    try {
      _shortReels = await _service.getShortReels(limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reels: $e');
    }
  }

  Future<void> loadMyPromotions() async {
    if (_userId.isEmpty) return;
    try {
      _myPromotions = await _service.getMyPromotions(userId: _userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading my promotions: $e');
    }
  }

  Future<String> createPromotion({
    required String name,
    required String description,
    required double price,
    required String scope,
    double? discount,
    List<String>? images,
    String? category,
    String? clinicName,
    DateTime? expires,
  }) async {
    if (_userId.isEmpty) throw Exception('Usuario no autenticado');
    try {
      final id = await _service.createPromotion(
        userId: _userId,
        name: name,
        description: description,
        price: price,
        scope: scope,
        discount: discount,
        images: images,
        category: category,
        clinicName: clinicName,
        expires: expires,
      );
      await Future.wait([loadProducts(), loadMyPromotions()]);
      return id;
    } catch (e) {
      debugPrint('Error creating promotion: $e');
      rethrow;
    }
  }

  Future<void> updatePromotion({
    required String promoId,
    String? name,
    String? desc,
    double? price,
    double? discount,
    List<String>? images,
    bool? active,
    bool? featured,
    DateTime? expires,
  }) async {
    try {
      await _service.updatePromotion(
        promoId: promoId,
        name: name,
        desc: desc,
        price: price,
        discount: discount,
        images: images,
        active: active,
        featured: featured,
        expires: expires,
      );
      await Future.wait([loadProducts(), loadMyPromotions()]);
    } catch (e) {
      debugPrint('Error updating promotion: $e');
      rethrow;
    }
  }

  Future<void> deletePromotion(String promoId) async {
    try {
      await _service.deletePromotion(promoId);
      _products.removeWhere((p) => p.id == promoId);
      _myPromotions.removeWhere((p) => p.id == promoId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting promotion: $e');
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    if (_userId.isEmpty) return;
    try {
      await _service.likePost(postId, _userId);
      final i = _posts.indexWhere((p) => p.id == postId);
      if (i != -1) {
        final post = _posts[i];
        final isLiked = post.likedBy?.contains(_userId) ?? false;
        _posts[i] = post.copyWith(
          likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
          likedBy: isLiked
              ? (post.likedBy?..remove(_userId))
              : (post.likedBy?..add(_userId)),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
      rethrow;
    }
  }

  Future<void> addComment(String postId, String content) async {
    if (_userId.isEmpty) return;
    try {
      await _service.addComment(postId, _userId, content);
      final i = _posts.indexWhere((p) => p.id == postId);
      if (i != -1) {
        _posts[i] =
            _posts[i].copyWith(commentsCount: _posts[i].commentsCount + 1);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> sharePost(String postId) async {
    if (_userId.isEmpty) return;
    try {
      await _service.sharePost(postId, _userId);
    } catch (e) {
      debugPrint('Error sharing post: $e');
      rethrow;
    }
  }

  Future<void> savePost(String postId) async {
    if (_userId.isEmpty) return;
    try {
      await _service.savePost(postId, _userId);
    } catch (e) {
      debugPrint('Error saving post: $e');
      rethrow;
    }
  }

  Future<void> followUser(String targetUserId) async {
    if (_userId.isEmpty || _userId == targetUserId) return;
    try {
      await _service.followUser(_userId, targetUserId);
      final i = _suggestedUsers.indexWhere((u) => u.uid == targetUserId);
      if (i != -1) {
        _suggestedUsers.removeAt(i);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error following user: $e');
      rethrow;
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    if (_userId.isEmpty) return;
    try {
      await _service.unfollowUser(_userId, targetUserId);
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      rethrow;
    }
  }

  Future<void> blockUser(String targetUserId) async {
    if (_userId.isEmpty) return;
    try {
      await _service.blockUser(_userId, targetUserId);
      _posts.removeWhere((p) => p.userId == targetUserId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error blocking user: $e');
      rethrow;
    }
  }

  Future<void> hidePost(String postId) async {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    try {
      await _service.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  Future<void> reportContent({
    required String contentId,
    required String contentType,
    required String reason,
    String? additionalInfo,
  }) async {
    if (_userId.isEmpty) return;
    try {
      await _service.reportContent(
        contentId: contentId,
        contentType: contentType,
        reason: reason,
        reporterId: _userId,
        info: additionalInfo,
      );
    } catch (e) {
      debugPrint('Error reporting content: $e');
      rethrow;
    }
  }

  void openComments(String postId) {}
  void openUserProfile(String userId) {}
  void openProductDetails(String productId) {}
  void openJobDetails(String jobId) {}

  Future<List<PostModel>> searchPosts(String query) async {
    try {
      return [];
    } catch (e) {
      debugPrint('Error searching posts: $e');
      return [];
    }
  }

  Future<List<UserLightModel>> searchUsers(String query) async {
    try {
      return await _service.searchUsers(query);
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    if (_userId.isEmpty) return;
    try {
      await _service.addToCart(_userId, productId, quantity);
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> applyToJob(String jobId, {String? coverLetter}) async {
    if (_userId.isEmpty) return;
    try {
      await _service.applyToJob(_userId, jobId, coverLetter: coverLetter);
    } catch (e) {
      debugPrint('Error applying to job: $e');
      rethrow;
    }
  }

  Future<void> bookAppointment({
    required String patientId,
    required String patientName,
    required String dentistId,
    required String treatmentName,
    required DateTime date,
    required String timeSlot,
    String? patientPhoto,
    String? notes,
  }) async {
    if (_userId.isEmpty) return;
    try {
      await _service.bookAppointment(
        patientId: patientId,
        patientName: patientName,
        dentistId: dentistId,
        treatmentName: treatmentName,
        date: date,
        timeSlot: timeSlot,
        patientPhoto: patientPhoto,
        notes: notes,
      );
      await loadAppointments();
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String recipientId,
    required String content,
    String? messageType,
  }) async {
    if (_userId.isEmpty) return;
    try {
      await _service.sendMessage(
        senderId: _userId,
        recipientId: recipientId,
        content: content,
        messageType: messageType ?? 'text',
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<String> createPost({
    required String title,
    required String description,
    List<String>? imageUrls,
    List<MediaItem>? media,
    String? city,
    String? clinicId,
  }) async {
    if (_userId.isEmpty) throw Exception('Usuario no autenticado');
    try {
      final id = await _service.createPost(
        userId: _userId,
        title: title,
        description: description,
        imageUrls: imageUrls,
        media: media,
        city: city,
        clinicId: clinicId ?? _clinicId,
      );
      return id;
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  Future<String> createStory(
      {required String imageUrl, String? text}) async {
    if (_userId.isEmpty) throw Exception('Usuario no autenticado');
    try {
      final id = await _service.createStory(
        userId: _userId,
        imageUrl: imageUrl,
        text: text,
      );
      final newStory = StoryModel(
        id: id,
        userId: _userId,
        userName: _currentUserName,
        userPhoto: _currentUserPhoto.isNotEmpty ? _currentUserPhoto : null,
        imageUrl: imageUrl,
        isActive: true,
        createdAt: DateTime.now(),
      );
      _stories.insert(0, newStory);
      _currentUserStories.insert(0, newStory);
      notifyListeners();
      return id;
    } catch (e) {
      debugPrint('Error creating story: $e');
      rethrow;
    }
  }

  Future<String> createReel({
    required String videoUrl,
    String? description,
  }) async {
    if (_userId.isEmpty) throw Exception('Usuario no autenticado');
    try {
      return await _service.createReel(
        userId: _userId,
        videoUrl: videoUrl,
        description: description,
      );
    } catch (e) {
      debugPrint('Error creating reel: $e');
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await _service.updateAppointmentStatus(appointmentId, status);
      final i = _appointments.indexWhere((a) => a.id == appointmentId);
      if (i != -1) {
        _appointments[i] = _appointments[i].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating appointment status: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _service.deleteAppointment(appointmentId);
      _appointments.removeWhere((a) => a.id == appointmentId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
      rethrow;
    }
  }

  List<AppointmentModel> getAppointmentsByDate(DateTime date) {
    return _appointments
        .where((a) =>
            a.date.year == date.year &&
            a.date.month == date.month &&
            a.date.day == date.day)
        .toList();
  }

  List<AppointmentModel> getTodayAppointments() {
    final now = DateTime.now();
    return getAppointmentsByDate(now);
  }

  List<AppointmentModel> getUpcomingAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.date.isAfter(now) || a.isToday)
        .toList();
  }

  Future<String> createTurno({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    if (_userId.isEmpty) throw Exception('Usuario no autenticado');
    try {
      final id = await _service.createTurno(
        dentistId: _userId,
        employeeId: employeeId,
        employeeName: employeeName,
        date: date,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      await loadTurnos();
      return id;
    } catch (e) {
      debugPrint('Error creating turno: $e');
      rethrow;
    }
  }

  Future<void> updateTurnoStatus(String turnoId, String status) async {
    try {
      await _service.updateTurnoStatus(turnoId, status);
      final i = _turnos.indexWhere((t) => t.id == turnoId);
      if (i != -1) {
        _turnos[i] = _turnos[i].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating turno status: $e');
      rethrow;
    }
  }

  Future<void> deleteTurno(String turnoId) async {
    try {
      await _service.deleteTurno(turnoId);
      _turnos.removeWhere((t) => t.id == turnoId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting turno: $e');
      rethrow;
    }
  }

  Future<void> refreshAll() async {
    _posts.clear();
    _stories.clear();
    _products.clear();
    _jobs.clear();
    _suggestedUsers.clear();
    _myPromotions.clear();
    _currentUserStories.clear();
    _lastPostDocument = null;
    _lastStoryDocument = null;
    _hasMorePosts = true;
    _hasMoreStories = true;
    await loadInitialData(force: true);
  }

  Future<void> _saveToCache() async {
    try {
      await HomeCacheService.save(
        userId: _userId,
        data: HomeCacheData(
          userName: _currentUserName,
          userPhoto: _currentUserPhoto,
          posts: _posts,
          stories: _stories,
          currentUserStories: _currentUserStories,
          suggestedUsers: _suggestedUsers,
          products: _products,
          jobs: _jobs,
          treatments: _treatments,
          appointments: _appointments,
        ),
      );
    } catch (_) {}
  }

  bool get mounted => !_isDisposed;
}
