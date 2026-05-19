import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medident/core/models/post-model.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/models/jobs-model.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/core/models/appointment-model.dart';

class HomeCacheData {
  final String userName;
  final String userPhoto;
  final List<PostModel> posts;
  final List<StoryModel> stories;
  final List<StoryModel> currentUserStories;
  final List<UserModel> suggestedUsers;
  final List<ProductModel> products;
  final List<JobModel> jobs;
  final List<TreatmentModel> treatments;
  final List<AppointmentModel> appointments;

  HomeCacheData({
    required this.userName,
    required this.userPhoto,
    required this.posts,
    required this.stories,
    required this.currentUserStories,
    required this.suggestedUsers,
    required this.products,
    required this.jobs,
    required this.treatments,
    required this.appointments,
  });

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'userPhoto': userPhoto,
        'posts': posts.map(_postToMap).toList(),
        'stories': stories.map(_storyToMap).toList(),
        'currentUserStories': currentUserStories.map(_storyToMap).toList(),
        'suggestedUsers': suggestedUsers.map(_userToMap).toList(),
        'products': products.map(_productToMap).toList(),
        'jobs': jobs.map(_jobToMap).toList(),
        'treatments': treatments.map(_treatmentToMap).toList(),
        'appointments': appointments.map(_appointmentToMap).toList(),
      };

  factory HomeCacheData.fromJson(Map<String, dynamic> json) => HomeCacheData(
        userName: json['userName'] as String? ?? '',
        userPhoto: json['userPhoto'] as String? ?? '',
        posts: _parseList<PostModel>(json['posts'], _postFromMap),
        stories: _parseList<StoryModel>(json['stories'], _storyFromMap),
        currentUserStories:
            _parseList<StoryModel>(json['currentUserStories'], _storyFromMap),
        suggestedUsers:
            _parseList<UserModel>(json['suggestedUsers'], _userFromMap),
        products: _parseList<ProductModel>(json['products'], _productFromMap),
        jobs: _parseList<JobModel>(json['jobs'], _jobFromMap),
        treatments:
            _parseList<TreatmentModel>(json['treatments'], _treatmentFromMap),
        appointments:
            _parseList<AppointmentModel>(json['appointments'], _appointmentFromMap),
      );

  // ── Serialization helpers ───────────────────────────────

  static Map<String, dynamic> _postToMap(PostModel p) => {
        ...p.toJson(),
        'createdAt': p.createdAt.toIso8601String(),
      };

  static PostModel _postFromMap(Map<String, dynamic> m) =>
      PostModel.fromJson({
        ...m,
        'createdAt': DateTime.parse(m['createdAt'] as String),
      }, m['id'] as String);

  static Map<String, dynamic> _storyToMap(StoryModel s) => {
        'id': s.id,
        'userId': s.userId,
        'userName': s.userName,
        'userPhoto': s.userPhoto,
        'imageUrl': s.imageUrl,
        'status': s.status,
        'isActive': s.isActive,
        'isWorking': s.isWorking,
        'isViewed': s.isViewed,
        'viewedBy': s.viewedBy,
        'likedBy': s.likedBy,
        'likesCount': s.likesCount,
        'createdAt': s.createdAt.toIso8601String(),
      };

  static StoryModel _storyFromMap(Map<String, dynamic> m) => StoryModel.fromJson({
        ...m,
        'createdAt': DateTime.parse(m['createdAt'] as String),
      }, m['id'] as String);

  static Map<String, dynamic> _userToMap(UserModel u) => {
        'uid': u.uid,
        'email': u.email,
        'fullName': u.fullName,
        'userName': u.userName,
        'phoneNumber': u.phoneNumber,
        'imageUrl': u.imageUrl,
        'role': u.role.name,
        'gender': u.gender?.name,
        'birthDate': u.birthDate?.toIso8601String(),
        'address': u.address,
        'speciality': u.speciality,
        'status': u.status,
        'isActive': u.isActive,
        'followersCount': u.followersCount,
        'followingCount': u.followingCount,
        'clinicId': u.clinicId,
        'isClinicOwner': u.isClinicOwner,
      };

  static UserModel _userFromMap(Map<String, dynamic> m) => UserModel.fromMap({
        ...m,
        'birthDate': m['birthDate'] != null
            ? DateTime.parse(m['birthDate'] as String)
            : null,
      }, m['uid'] as String);

  static Map<String, dynamic> _productToMap(ProductModel p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'price': p.price,
        'discountPrice': p.discountPrice,
        'imageUrls': p.imageUrls,
        'category': p.category,
        'clinicId': p.clinicId,
        'clinicName': p.clinicName,
        'rating': p.rating,
        'reviewsCount': p.reviewsCount,
        'isFeatured': p.isFeatured,
        'isAvailable': p.isAvailable,
        'isActive': p.isActive,
        'createdBy': p.createdBy,
        'scope': p.scope,
        'createdAt': p.createdAt.toIso8601String(),
        'expiresAt': p.expiresAt?.toIso8601String(),
      };

  static ProductModel _productFromMap(Map<String, dynamic> m) =>
      ProductModel.fromJson(m, m['id'] as String);

  static Map<String, dynamic> _jobToMap(JobModel j) => {
        'id': j.id,
        'title': j.title,
        'description': j.description,
        'company': j.company,
        'companyLogo': j.companyLogo,
        'location': j.location,
        'type': j.type,
        'salary': j.salary,
        'salaryRange': j.salaryRange,
        'requirements': j.requirements,
        'benefits': j.benefits,
        'specialty': j.specialty,
        'createdAt': j.createdAt.toIso8601String(),
        'expiresAt': j.expiresAt?.toIso8601String(),
        'isActive': j.isActive,
        'postedById': j.postedById,
        'clinicId': j.clinicId,
      };

  static JobModel _jobFromMap(Map<String, dynamic> m) =>
      JobModel.fromJson(m, m['id'] as String);

  static Map<String, dynamic> _treatmentToMap(TreatmentModel t) => {
        'id': t.id,
        'name': t.name,
        'description': t.description,
        'price': t.price,
        'discountPrice': t.discountPrice,
        'iconName': t.iconName,
        'category': t.category,
        'durationMinutes': t.durationMinutes,
        'isActive': t.isActive,
        'clinicId': t.clinicId,
        'createdAt': t.createdAt.toIso8601String(),
      };

  static TreatmentModel _treatmentFromMap(Map<String, dynamic> m) =>
      TreatmentModel.fromJson(m, m['id'] as String);

  static Map<String, dynamic> _appointmentToMap(AppointmentModel a) => {
        'id': a.id,
        'patientId': a.patientId,
        'patientName': a.patientName,
        'patientPhoto': a.patientPhoto,
        'dentistId': a.dentistId,
        'treatmentName': a.treatmentName,
        'date': a.date.toIso8601String(),
        'timeSlot': a.timeSlot,
        'status': a.status,
        'notes': a.notes,
        'createdAt': a.createdAt.toIso8601String(),
      };

  static AppointmentModel _appointmentFromMap(Map<String, dynamic> m) =>
      AppointmentModel.fromJson(m, m['id'] as String);

  static List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(fromMap)
        .toList();
  }
}

class HomeCacheService {
  HomeCacheService._();

  static const String _prefix = 'home_cache_';

  static Future<void> save({
    required String userId,
    required HomeCacheData data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$userId', jsonEncode(data.toJson()));
  }

  static Future<HomeCacheData?> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$userId');
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return HomeCacheData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$userId');
  }
}
