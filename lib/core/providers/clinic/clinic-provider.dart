import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/core/models/patient-model.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/models/turno-model.dart';
import 'package:medident/core/services/clinic-service.dart';
import 'package:medident/core/services/patient-service.dart';

enum ClinicStatus { checking, noClinic, owner, employee, error }

class ClinicProvider with ChangeNotifier {
  final ClinicService _service;
  final PatientService _patientService;

  ClinicStatus _status = ClinicStatus.checking;
  ClinicModel? _clinic;
  String? _error;
  bool _isLoading = false;
  List<AppointmentModel> _appointments = [];
  List<TreatmentModel> _treatments = [];
  bool _isLoadingAppointments = false;
  bool _isLoadingTreatments = false;

  StreamSubscription<QuerySnapshot>? _appointmentsSub;
  List<TurnoModel> _turnos = [];
  StreamSubscription<QuerySnapshot>? _turnosSub;
  bool _isLoadingTurnos = false;

  List<ProductModel> _promotions = [];
  StreamSubscription<List<ProductModel>>? _promotionsSub;
  bool _promotionsLoaded = false;

  List<Map<String, dynamic>> _clinicFeed = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _feedSub;
  bool _isLoadingFeed = false;

  ClinicProvider({required ClinicService service})
      : _service = service,
        _patientService = PatientService();

  // ── Cache local ────────────────────────────────────────────
  static const String _cacheKey = 'clinic_cache';

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final id = json['id'] as String? ?? '';
      final cachedStatusStr = json['cached_status'] as String?;
      if (id.isNotEmpty) {
        _clinic = ClinicModel.fromMap(json, id);
        _status = cachedStatusStr == 'owner' ? ClinicStatus.owner : ClinicStatus.employee;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveToCache() async {
    if (_clinic == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = Map<String, dynamic>.from(_clinic!.toMap());
      data.remove('createdAt');
      data.remove('updatedAt');
      data['cached_status'] = _status == ClinicStatus.owner ? 'owner' : 'employee';
      data['id'] = _clinic!.id;
      await prefs.setString(_cacheKey, jsonEncode(data));
    } catch (_) {}
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  ClinicStatus get status => _status;
  ClinicModel? get clinic => _clinic;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isOwner => _status == ClinicStatus.owner;

  Color get primaryColor {
    if (_clinic?.primaryColor != null) {
      final hex = _clinic!.primaryColor!;
      final c = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
      if (c != null) return Color(c);
    }
    return const Color(0xFF007AFF);
  }

  List<AppointmentModel> get appointments => _appointments;
  List<TreatmentModel> get treatments => _treatments;
  List<TurnoModel> get turnos => _turnos;
  bool get isLoadingAppointments => _isLoadingAppointments;
  bool get isLoadingTreatments => _isLoadingTreatments;
  bool get isLoadingTurnos => _isLoadingTurnos;
  List<ProductModel> get promotions => _promotions;
  List<Map<String, dynamic>> get clinicFeed => _clinicFeed;
  bool get isLoadingFeed => _isLoadingFeed;

  int get todayAppointmentsCount {
    final now = DateTime.now();
    return _appointments.where((a) =>
      a.date.year == now.year &&
      a.date.month == now.month &&
      a.date.day == now.day
    ).length;
  }

  int get uniquePatientsCount {
    return _appointments.map((a) => a.patientId).toSet().length;
  }

  int get pendingAppointmentsCount {
    return _appointments.where((a) => a.status != 'confirmed').length;
  }

  Future<void> checkClinicStatus(String userId) async {
    _status = ClinicStatus.checking;
    _error = null;
    notifyListeners();

    // 1) Instant paint desde cache local
    await _loadFromCache();

    try {
      final clinics = await _service.getClinicsForUser(userId);
      if (clinics.isEmpty) {
        _status = ClinicStatus.noClinic;
        _clinic = null;
      } else {
        _clinic = clinics.first;
        _status = _clinic!.ownerId == userId
            ? ClinicStatus.owner
            : ClinicStatus.employee;
        _subscribeToAppointments();
        _subscribeToTurnos();
        _subscribeToPromotions();
        _subscribeToClinicFeed();
        _saveToCache();
      }
    } catch (e) {
      if (_clinic == null) {
        _error = e.toString();
        _status = ClinicStatus.error;
      }
    }
    notifyListeners();
  }

  void setCachedStatus({required bool isOwner}) {
    _clinic = null;
    _status = isOwner ? ClinicStatus.owner : ClinicStatus.employee;
    _error = null;
    notifyListeners();
  }

  Future<void> refreshFromClinicId(String clinicId, String userId) async {
    try {
      final clinic = await _service.getClinic(clinicId);
      if (clinic != null) {
        _clinic = clinic;
        _status = clinic.ownerId == userId
            ? ClinicStatus.owner
            : ClinicStatus.employee;
        _subscribeToAppointments();
        _subscribeToTurnos();
        _subscribeToPromotions();
        _subscribeToClinicFeed();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Background clinic refresh error: $e');
    }
  }

  Future<void> loadPromotions() async {
    if (_clinic == null || _promotionsLoaded) return;
    _promotionsLoaded = true;
    final list = await _service.getClinicPromotions(_clinic!.id, _clinic!.ownerId);
    _promotions = list;
    notifyListeners();
  }

  void _subscribeToPromotions() {
    _promotionsSub?.cancel();
    if (_clinic == null) return;
    _promotionsSub = _service.streamClinicPromotions(_clinic!.id, _clinic!.ownerId).listen(
      (list) {
        _promotions = list;
        _promotionsLoaded = true;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Promotions stream error: $e');
      },
    );
  }

  // ── Stream en tiempo real del feed de la clínica ──────
  void _subscribeToClinicFeed() {
    _feedSub?.cancel();
    if (_clinic == null) return;
    _isLoadingFeed = true;
    notifyListeners();
    _feedSub = _service.streamClinicPosts(_clinic!.id).listen(
      (snap) {
        _clinicFeed = snap.docs.map((d) {
          final data = Map<String, dynamic>.from(d.data());
          data['id'] = d.id;
          return data;
        }).toList();
        _isLoadingFeed = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Clinic feed stream error: $e');
        _isLoadingFeed = false;
        notifyListeners();
      },
    );
  }

  Future<String> createClinicPost({
    required String createdBy,
    required String userName,
    String? userPhoto,
    required String type,
    required String description,
    List<String>? imageUrls,
  }) async {
    if (_clinic == null) throw Exception('Clínica no cargada');
    return _service.createClinicPost(
      clinicId: _clinic!.id,
      createdBy: createdBy,
      userName: userName,
      userPhoto: userPhoto,
      type: type,
      description: description,
      imageUrls: imageUrls,
    );
  }

  // ── Stream en tiempo real de citas ─────────────────────
  void _subscribeToAppointments() {
    _appointmentsSub?.cancel();
    if (_clinic == null) return;
      _appointmentsSub = _service.streamAppointmentsByClinic(_clinic!.id).listen(
      (snap) {
        _appointments = snap.docs.map((d) => AppointmentModel.fromJson(d.data(), d.id)).toList();
        _isLoadingAppointments = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Appointments stream error: $e');
        _isLoadingAppointments = false;
        notifyListeners();
      },
    );
  }

  // ── Stream en tiempo real de turnos ───────────────────
  void _subscribeToTurnos() {
    _turnosSub?.cancel();
    if (_clinic == null) return;
    _isLoadingTurnos = true;
    notifyListeners();
    _turnosSub = _service.streamTurnosByClinic(_clinic!.id).listen(
      (snap) {
        try {
          _turnos = snap.docs.map((d) {
            final data = Map<String, dynamic>.from(d.data());
            return TurnoModel.fromJson(data, d.id);
          }).toList();
        } catch (e) {
          debugPrint('Error parseando turnos: $e');
          _turnos = [];
        }
        _isLoadingTurnos = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Turnos stream error: $e');
        _isLoadingTurnos = false;
        notifyListeners();
      },
    );
  }

  // ── Crear clínica (dueño) ─────────────────────────────
  Future<bool> createClinic({
    required String name,
    required String ownerId,
    required String nit,
    String? address,
    String? phone,
    String? email,
    String? website,
    Map<String, String>? socialMedia,
    Map<String, Map<String, String>>? businessHours,
    String? description,
    String? logoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CLINIC_PROVIDER] createClinic — creando clínica: $name');
      _clinic = await _service.createClinic(
        name: name,
        ownerId: ownerId,
        nit: nit,
        address: address,
        phone: phone,
        email: email,
        website: website,
        socialMedia: socialMedia,
        businessHours: businessHours,
        description: description,
        logoUrl: logoUrl,
      );
      debugPrint('[CLINIC_PROVIDER] createClinic — OK, clinicId: ${_clinic!.id}');
      _status = ClinicStatus.owner;
      _isLoading = false;
      _subscribeToAppointments();
      _subscribeToTurnos();
      _subscribeToPromotions();
      _subscribeToClinicFeed();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[CLINIC_PROVIDER] createClinic — ERROR: $e');
      _error = e.toString();
      _status = ClinicStatus.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Unirse por código API ─────────────────────────────
  Future<bool> joinByCode({required String apiKey, required String userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final clinic = await _service.getClinicByApiKey(apiKey);
      if (clinic == null) {
        _error = 'Código inválido. Verifica e intenta de nuevo.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final success = await _service.joinClinic(clinicId: clinic.id, userId: userId);
      if (success) {
        _clinic = clinic;
        _status = ClinicStatus.employee;
        _subscribeToAppointments();
        _subscribeToTurnos();
        _subscribeToPromotions();
        _subscribeToClinicFeed();
      } else {
        _error = 'Error al unirse a la clínica.';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _status = ClinicStatus.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveClinic() async {
    if (_clinic == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.leaveClinic(_clinic!.id, _clinic!.ownerId);
      if (success) {
        _appointmentsSub?.cancel();
        _turnosSub?.cancel();
        _clinic = null;
        _appointments.clear();
        _status = ClinicStatus.noClinic;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadTreatments() async {
    if (_treatments.isNotEmpty || _clinic == null) return;
    _isLoadingTreatments = true;
    notifyListeners();
    try {
      _treatments = await _service.getTreatmentsByClinic(_clinic!.id);
      _isLoadingTreatments = false;
      notifyListeners();
    } catch (e) {
      _isLoadingTreatments = false;
      debugPrint('Error loading treatments: $e');
      notifyListeners();
    }
  }

  List<AppointmentModel> getAppointmentsByDate(DateTime date) {
    return _appointments.where((a) =>
      a.date.year == date.year &&
      a.date.month == date.month &&
      a.date.day == date.day
    ).toList();
  }

  // ── CRUD de citas ─────────────────────────────────────
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _service.updateAppointmentStatus(appointmentId, status);
      final i = _appointments.indexWhere((a) => a.id == appointmentId);
      if (i != -1) {
        _appointments[i] = _appointments[i].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');
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

  Future<String> bookAppointment({
    required String patientId,
    required String patientName,
    required String dentistId,
    required String treatmentName,
    required DateTime date,
    required String timeSlot,
    String? patientPhoto,
    String? notes,
  }) async {
    try {
      final id = await _service.bookAppointment(
        clinicId: _clinic?.id,
        patientId: patientId,
        patientName: patientName,
        dentistId: dentistId,
        treatmentName: treatmentName,
        date: date,
        timeSlot: timeSlot,
        patientPhoto: patientPhoto,
        notes: notes,
      );
      return id;
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      rethrow;
    }
  }

  Future<void> refresh(String userId) async {
    await checkClinicStatus(userId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Empleados activos ────────────────────────────────
  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveEmployees() {
    final cid = _clinic?.id;
    if (cid == null) return const Stream.empty();
    return _service.streamActiveEmployeesByClinic(cid);
  }

  // ── Pacientes ──────────────────────────────────────────
  Stream<List<PatientModel>> streamPatients([String searchQuery = '']) {
    final cid = _clinic?.id;
    if (cid == null) return Stream.value([]);
    return _patientService.streamPatientsByClinic(cid).map((all) {
      if (searchQuery.isEmpty) return all;
      final q = searchQuery.toLowerCase();
      return all.where((p) => p.fullName.toLowerCase().contains(q)).toList();
    });
  }

  Future<PatientModel?> getPatientDetail(String patientId) {
    return _patientService.getPatientDetail(patientId);
  }

  Future<String> createPatient({
    required String uid,
    required String fullName,
    String? photo,
    String? phone,
    String? email,
    String? bloodType,
    List<String>? allergies,
    List<String>? medications,
    List<String>? medicalHistory,
    List<String>? dentalHistory,
    String? insuranceProvider,
    String? insuranceId,
    String? notes,
  }) {
    if (_clinic == null) return Future.error('Clínica no cargada');
    final cid = _clinic!.id;
    return _patientService.createPatient(
      uid: uid,
      fullName: fullName,
      clinicId: cid,
      photo: photo,
      phone: phone,
      email: email,
      bloodType: bloodType,
      allergies: allergies,
      medications: medications,
      medicalHistory: medicalHistory,
      dentalHistory: dentalHistory,
      insuranceProvider: insuranceProvider,
      insuranceId: insuranceId,
      notes: notes,
    );
  }

  Future<void> updatePatientProfile(String uid, Map<String, dynamic> updates) {
    return _patientService.updatePatientProfile(uid, updates);
  }

  Future<void> updatePatientUser(String uid, Map<String, dynamic> updates) {
    return _patientService.updateUserField(uid, updates);
  }

  Future<void> deletePatient(String uid) {
    return _patientService.deletePatient(uid);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamClinicalRecords(String clinicId, String patientId) {
    return _patientService.streamClinicalRecords(patientId, clinicId);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamClinicClinicalRecords(String clinicId) {
    return _patientService.streamClinicClinicalRecords(clinicId);
  }

  Future<String> addClinicalRecord({
    required String clinicId,
    required String patientId,
    required String dentistName,
    required DateTime date,
    String? diagnosis,
    String? treatment,
    String? procedure,
    String? notes,
    List<String>? attachments,
    String? odontogramId,
  }) {
    return _patientService.addClinicalRecord(
      patientId: patientId,
      clinicId: clinicId,
      dentistName: dentistName,
      date: date,
      diagnosis: diagnosis,
      treatment: treatment,
      procedure: procedure,
      notes: notes,
      attachments: attachments,
      odontogramId: odontogramId,
    );
  }

  Future<void> deleteClinicalRecord(String recordId) {
    return _patientService.deleteClinicalRecord(recordId);
  }

  // ── CRUD Turnos ───────────────────────────────────────
  Future<String> createTurno({
    required String dentistId,
    required String employeeId,
    required String employeeName,
    String? employeePhoto,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    return _service.createTurno(
      clinicId: _clinic!.id,
      dentistId: dentistId,
      employeeId: employeeId,
      employeeName: employeeName,
      employeePhoto: employeePhoto,
      date: date,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
    );
  }

  Future<void> updateTurnoStatus(String turnoId, String status) async {
    await _service.updateTurnoStatus(turnoId, status);
    final i = _turnos.indexWhere((t) => t.id == turnoId);
    if (i != -1) {
      _turnos[i] = _turnos[i].copyWith(status: status);
      notifyListeners();
    }
  }

  Future<void> deleteTurno(String turnoId) async {
    await _service.deleteTurno(turnoId);
    _turnos.removeWhere((t) => t.id == turnoId);
    notifyListeners();
  }

  // ── Odontogramas ──────────────────────────────────────
  Future<Map<String, dynamic>?> getOdontogram(String patientId) {
    return _patientService.getOdontogramByPatient(patientId);
  }

  Future<void> saveOdontogram({
    required String patientId,
    required String patientName,
    required String dentistId,
    required Map<String, dynamic> teethMap,
  }) {
    return _patientService.saveOdontogram(
      patientId: patientId,
      patientName: patientName,
      dentistId: dentistId,
      teethMap: teethMap,
    );
  }

  Future<void> updateOdontogram(
    String odontogramId,
    Map<String, dynamic> teethMap,
  ) {
    return _patientService.updateOdontogram(odontogramId, teethMap);
  }

  @override
  void dispose() {
    _appointmentsSub?.cancel();
    _turnosSub?.cancel();
    _promotionsSub?.cancel();
    _feedSub?.cancel();
    super.dispose();
  }
}
