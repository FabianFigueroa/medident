import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:medident/core/models/rfid-reader-model.dart';
import 'package:medident/core/models/roles/dentist/dentist-rfid-model.dart';
import 'package:medident/core/models/roles/dentist/dentist-sensor-model.dart';
import 'package:medident/core/models/rfid-log-model.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/models/alert-model.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/services/dentist/dentist-security-services.dart';
import 'package:medident/core/services/rfid-service.dart';
import 'package:medident/core/services/rtdb-rfid-service.dart';
import 'package:medident/core/services/alerts-service.dart';
import 'package:medident/core/services/realtime-sync-service.dart';

class DentistSecurityProvider with ChangeNotifier {
  final DentistSecurityService _securityService;
  final RfidService _rfidService = RfidService();
  final AlertsService _alertsService = AlertsService();
  final RealtimeSyncService _realtimeService = RealtimeSyncService();
  final String uid;

  DentistSecurityModel? _dentistSecurityModel;
  StreamSubscription? _securityDataSubscription;
  StreamSubscription? _rfidLogsSubscription;
  StreamSubscription? _alertsSubscription;
  StreamSubscription? _realtimeSubscription;
  RtdbRfidService? _rtidbRfidService;
  bool _isLoading = true;
  String? _error;
  Uint8List? _lastCameraSnapshot;
  bool _isCameraConnected = false;
  bool _isRegisteringCard = false;
  String? _scannedRfidCardId;
  bool _isAssigningRfidCard = false;
  List<RfidLogModel> _rfidLogs = [];
  List<AlertModel> _alerts = [];
  int _unreadAlertsCount = 0;

  DentistSecurityModel? get dentistSecurityModel => _dentistSecurityModel;
  DentistSecurityModel? get securityData => _dentistSecurityModel;
  DentistSecurityModel? get securityProfile => _dentistSecurityModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DentistRfidCardModel> get rfidCards =>
      _dentistSecurityModel?.rfidCards ?? [];
  List<dynamic> get securityLogs => _dentistSecurityModel?.securityLogs ?? [];
  Uint8List? get lastCameraSnapshot => _lastCameraSnapshot;
  bool get isCameraConnected => _isCameraConnected;
  bool get isRegisteringCard => _isRegisteringCard;
  String? get scannedRfidCardId => _scannedRfidCardId;
  bool get isAssigningRfidCard => _isAssigningRfidCard;

  // Propiedad para obtener compañeros (teammates)
  // List<UserModel> get teammates => _dentistSecurityModel?.teammates ?? [];

  bool _streamsInitialized = false;

  DentistSecurityProvider(this.uid, this._securityService);

  void initializeStreams([DentistSecurityModel? model]) {
    if (_streamsInitialized) return;
    _streamsInitialized = true;
    _listenToAlerts();
    _listenToRfidScanRealtime();
    if (model != null) {
      _initRtdbService(model);
      _listenToRfidLogs();
    }
    _initializeSecurityData();
  }

  void _initRtdbService(DentistSecurityModel model) {
    if (model.readers.isNotEmpty) {
      final reader = model.readers.first;
      _rtidbRfidService = RtdbRfidService(
        apiKey: model.locationId,
        deviceId: reader.readerId,
      );
    }
  }

  // Getters para nuevas funcionalidades
  List<RfidLogModel> get rfidLogs => _rfidLogs;
  List<AlertModel> get alerts => _alerts;
  int get unreadAlertsCount => _unreadAlertsCount;
  
  void _listenToRfidLogs() {
    if (uid.isEmpty) return;
    _rfidLogsSubscription?.cancel();
    // Use RTDB service if available, otherwise fallback to Firestore service
    if (_rtidbRfidService != null) {
      _rfidLogsSubscription = _rtidbRfidService!.getRfidLogsStream().listen((logs) {
        _rfidLogs = logs;
        notifyListeners();
      }, onError: (e) {
        debugPrint('[DentistSecurityProvider] Error en stream RFID logs (RTDB): $e');
      });
    } else {
      _rfidLogsSubscription = _rfidService.getRfidLogsStream(uid).listen((logs) {
        _rfidLogs = logs;
        notifyListeners();
      }, onError: (e) {
        debugPrint('[DentistSecurityProvider] Error en stream RFID logs (Firestore): $e');
      });
    }
  }

  void _listenToAlerts() {
    if (uid.isEmpty) return;
    _alertsSubscription?.cancel();
    _alertsSubscription = _alertsService.getAlertsStream(uid).listen((alerts) {
      _alerts = alerts;
      _unreadAlertsCount = alerts.where((a) => !a.read).length;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[DentistSecurityProvider] Error en stream alertas: $e');
    });
  }

  void _listenToRfidScanRealtime() {
    if (uid.isEmpty) return;
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _realtimeService.listenToRfidScan(uid).listen((data) {
      if (data != null) {
        _handleRfidScanFromRealtime(data);
      }
    }, onError: (e) {
      debugPrint('[DentistSecurityProvider] Error en stream RFID scan: $e');
    });
  }

  Future<void> _handleRfidScanFromRealtime(Map<dynamic, dynamic> scanData) async {
    try {
      final cardId = scanData['cardId'] as String? ?? '';
      final readerId = scanData['readerId'] as String? ?? '';
      
      if (cardId.isEmpty || _dentistSecurityModel == null) return;

      // Buscar tarjeta en rfidCards
      final card = _dentistSecurityModel!.rfidCards.firstWhere(
        (c) => c.cardId == cardId,
        orElse: () => DentistRfidCardModel(cardId: cardId, status: 'unknown'),
      );

      final granted = card.status == 'active';
      
      // Buscar reader para ver si tiene cámara
      final reader = _dentistSecurityModel!.readers.firstWhere(
        (r) => r.readerId == readerId,
        orElse: () => RfidReaderModel(readerId: readerId, location: 'Unknown'),
      );

      String? photoUrl;
      
      // SI hay cámara, disparar captura
      if (reader.hasCamera && reader.cameraId != null) {
        await _realtimeService.triggerCameraCapture(uid, reader.cameraId!);
        
        // Esperar y leer la foto
        final cameraData = await _realtimeService
            .listenToCameraSnapshot(uid, reader.cameraId!)
            .first;
        photoUrl = cameraData?['photoUrl'] as String?;
      }

      // Crear log en rfid_logs collection
      final log = RfidLogModel(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        userId: uid,
        cardId: cardId,
        readerId: readerId,
        granted: granted,
        photoUrl: photoUrl,
        timestamp: DateTime.now(),
        location: reader.location,
        patientId: null,
        description: granted 
            ? 'Acceso concedido: ${card.assignedTo}' 
            : '¡ACCESO DENEGADO! Tarjeta: $cardId',
      );

      await _rfidService.createRfidLog(log);

      // Crear alerta
      final alert = AlertModel(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        userId: uid,
        clinicId: _dentistSecurityModel!.locationId,
        type: 'rfid_scan',
        severity: granted ? 'low' : 'high',
        title: 'Acceso RFID: ${card.assignedTo}',
        description: log.description ?? '',
        timestamp: DateTime.now(),
        room: reader.location,
        deviceId: readerId,
        cardId: cardId,
        photoUrl: photoUrl,
        read: false,
        handled: false,
        metadata: {'granted': granted},
      );

      await _alertsService.createAlert(alert);

      // SI acceso concedido, abrir puerta
      if (granted) {
        await _realtimeService.controlDevice(uid, 'doors', 'door_$readerId', {
          'open': true,
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[DentistSecurityProvider] Error handling RFID scan: $e');
    }
  }

  Future<void> _initializeSecurityData() async {
    try {
      // Primero intenta cargar datos reales
      _listenToSecurityData();

      final bool docExists = await _securityService.doesSecurityDocumentExist(uid);
      if (!docExists) {
        await _generateTestData();
      }
    } catch (e) {
      debugPrint('[DentistSecurityProvider._initializeSecurityData] Error: $e');
      _listenToSecurityData();
    }
  }

  Future<void> _generateTestData() async {
    try {
      // Crear documento inicial
      await _securityService.createInitialContract(
        uid,
        locationId: 'clinic-001',
        address: 'Calle Dental 123, Centro Médico',
      );

      // Generar tarjetas RFID de prueba
      final testCards = _generateTestRfidCards();
      for (var card in testCards) {
        await _securityService.addCard(uid, card);
      }

      // Generar dispositivos IoT de prueba
      final testDevices = _generateTestDevices();
      await _syncTestDevices(testDevices);
    } catch (e) {
      debugPrint('[DentistSecurityProvider._generateTestData] ❌ Error: $e');
    }
  }

  List<DentistRfidCardModel> _generateTestRfidCards() {
    return [
      DentistRfidCardModel(
        cardId: 'RFID-001-DR-SILVA',
        assignedTo: 'Dr. Roberto Silva',
      ),
      DentistRfidCardModel(
        cardId: 'RFID-002-DRA-MARTINEZ',
        assignedTo: 'Dra. Laura Martínez',
      ),
      DentistRfidCardModel(
        cardId: 'RFID-003-AUX-GARCIA',
        assignedTo: 'Aux. Carlos García',
      ),
      DentistRfidCardModel(
        cardId: 'RFID-004-AUX-LOPEZ',
        assignedTo: 'Aux. María López',
      ),
    ];
  }

  Future<void> _syncTestDevices(dynamic testDevices) async {
    // Este método será implementado cuando actualicemos el servicio
  }

  List<Map<String, dynamic>> _generateTestDevices() {
    return [
      // Luces
      {
        'type': 'lights',
        'name': 'Luz Sala de Espera',
        'room': 'Sala de Espera',
        'icon': '💡',
        'isOn': true,
      },
      {
        'type': 'lights',
        'name': 'Luz Consultorio 1',
        'room': 'Consultorio',
        'icon': '💡',
        'isOn': true,
      },
      {
        'type': 'lights',
        'name': 'Luz Consultorio 2',
        'room': 'Consultorio',
        'icon': '💡',
        'isOn': false,
      },
      {
        'type': 'lights',
        'name': 'Luz Esterilización',
        'room': 'Esterilización',
        'icon': '💡',
        'isOn': true,
      },

      // Ventiladores
      {
        'type': 'fans',
        'name': 'Extractor Consultorio 1',
        'room': 'Consultorio',
        'icon': '🌀',
        'isOn': true,
      },
      {
        'type': 'fans',
        'name': 'Extractor Esterilización',
        'room': 'Esterilización',
        'icon': '🌀',
        'isOn': true,
      },

      // Aires acondicionados
      {
        'type': 'airs',
        'name': 'A/C Principal',
        'room': 'Central',
        'icon': '❄️',
        'isOn': true,
      },
      {
        'type': 'airs',
        'name': 'A/C Consultorio 1',
        'room': 'Consultorio',
        'icon': '❄️',
        'isOn': true,
      },

      // TVs
      {
        'type': 'tvs',
        'name': 'TV Sala de Espera',
        'room': 'Sala de Espera',
        'icon': '📺',
        'isOn': true,
      },

      // Sistemas de Voz
      {
        'type': 'voices',
        'name': 'Intercomunicador',
        'room': 'Central',
        'icon': '📢',
        'isOn': true,
      },

      // Puertas
      {
        'type': 'doors',
        'name': 'Puerta Principal',
        'room': 'Entrada',
        'icon': '🚪',
        'isOn': true,
      },
      {
        'type': 'doors',
        'name': 'Puerta Consultorio 1',
        'room': 'Consultorio',
        'icon': '🚪',
        'isOn': false,
      },
    ];
  }

  void _listenToSecurityData() {
    _isLoading = true;
    notifyListeners();

    _securityDataSubscription?.cancel();

    try {
_securityDataSubscription = _securityService
            .getSecurityDataStream(uid)
            .listen(
              (data) {
                _dentistSecurityModel = data;
                _isLoading = false;
                _error = null;
                // Initialize RTDB service and listen to RFID logs now that we have security data
                _initRtdbService(_dentistSecurityModel!);
                _listenToRfidLogs();
                notifyListeners();
              },
            onError: (e, stackTrace) {
              _error = "Error al obtener los datos de seguridad: $e";
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e, stackTrace) {
      debugPrint(
        '[DentistSecurityProvider._listenToSecurityData] ❌ EXCEPCIÓN: $e',
      );
      debugPrint(
        '[DentistSecurityProvider._listenToSecurityData] Stack trace: $stackTrace',
      );
      _error = "Error al escuchar datos de seguridad: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCard(DentistRfidCardModel updatedCard) async {
    debugPrint(
      '[DentistSecurityProvider.updateCard] Actualizando tarjeta: ${updatedCard.cardId}',
    );
    try {
      await _securityService.updateCard(uid, updatedCard);
    } catch (e, stackTrace) {
      debugPrint('[DentistSecurityProvider.updateCard] ❌ Error: $e');
      debugPrint('[DentistSecurityProvider.updateCard] Stack: $stackTrace');
      _error = "Error al actualizar la tarjeta: $e";
      notifyListeners();
    }
  }

  Future<void> addCard(DentistRfidCardModel newCard) async {
    debugPrint(
      '[DentistSecurityProvider.addCard] Agregando tarjeta: ${newCard.cardId}',
    );
    try {
      await _securityService.addCard(uid, newCard);
    } catch (e, stackTrace) {
      debugPrint('[DentistSecurityProvider.addCard] ❌ Error: $e');
      debugPrint('[DentistSecurityProvider.addCard] Stack: $stackTrace');
      _error = "Error al añadir la tarjeta: $e";
      notifyListeners();
    }
  }

  Future<void> deleteCard(DentistRfidCardModel cardToDelete) async {
    debugPrint(
      '[DentistSecurityProvider.deleteCard] Eliminando tarjeta: ${cardToDelete.cardId}',
    );
    try {
      await _securityService.deleteCard(uid, cardToDelete);
    } catch (e, stackTrace) {
      debugPrint('[DentistSecurityProvider.deleteCard] ❌ Error: $e');
      debugPrint('[DentistSecurityProvider.deleteCard] Stack: $stackTrace');
      _error = "Error al eliminar la tarjeta: $e";
      notifyListeners();
    }
  }

  Future<void> addSensor(DentistSensorModel newSensor) async {
    debugPrint(
      '[DentistSecurityProvider.addSensor] Agregando sensor: ${newSensor.sensorId}',
    );
    try {
      await _securityService.addSensor(uid, newSensor);
    } catch (e) {
      debugPrint('[DentistSecurityProvider.addSensor] ❌ Error: $e');
      _error = "Error al añadir el sensor: $e";
      notifyListeners();
    }
  }

  Future<void> deleteSensor(DentistSensorModel sensorToDelete) async {
    debugPrint(
      '[DentistSecurityProvider.deleteSensor] Eliminando sensor: ${sensorToDelete.sensorId}',
    );
    try {
      await _securityService.deleteSensor(uid, sensorToDelete);
    } catch (e) {
      debugPrint('[DentistSecurityProvider.deleteSensor] ❌ Error: $e');
      _error = "Error al eliminar el sensor: $e";
      notifyListeners();
    }
  }

  Future<void> acceptContract() async {
    debugPrint(
      '[DentistSecurityProvider.acceptContract] Aceptando contrato para userId: $uid',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final bool docExists = await _securityService.doesSecurityDocumentExist(
        uid,
      );

      if (!docExists) {
        await _securityService.createInitialContract(uid);
      }

      await _securityService.updateContractStatus(uid, 'active');
    } catch (e, stackTrace) {
      _error = "Error al aceptar el contrato: $e";
      debugPrint("[DentistSecurityProvider.acceptContract] ❌ Error: $e");
      debugPrint("[DentistSecurityProvider.acceptContract] Stack: $stackTrace");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODOS PARA GESTIÓN DE TARJETAS RFID ---
  void setCardRegistrationMode(bool isRegistering) {
    _isRegisteringCard = isRegistering;
    if (!isRegistering) {
      _scannedRfidCardId = null;
      _isAssigningRfidCard = false;
    }
    notifyListeners();
  }

  Future<void> assignRfidCard({
    required String cardId,
    required String cardName,
  }) async {
    debugPrint('[DentistSecurityProvider.assignRfidCard] Asignando tarjeta');

    try {
      final newCard = DentistRfidCardModel(
        cardId: cardId,
        assignedTo: cardName,
      );
      await _securityService.addCard(uid, newCard);
      _scannedRfidCardId = null;
      _isAssigningRfidCard = false;
      _isRegisteringCard = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('[DentistSecurityProvider.assignRfidCard] ❌ Error: $e');
      debugPrint('[DentistSecurityProvider.assignRfidCard] Stack: $stackTrace');
      _error = "Error al asignar la tarjeta: $e";
      notifyListeners();
    }
  }

  Future<void> deleteRfidCard(String cardId) async {
    debugPrint(
      '[DentistSecurityProvider.deleteRfidCard] Eliminando tarjeta: $cardId',
    );

    try {
      final cards = _dentistSecurityModel?.rfidCards ?? [];
      final cardToDelete = cards.firstWhere((card) => card.cardId == cardId);
      await _securityService.deleteCard(uid, cardToDelete);
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('[DentistSecurityProvider.deleteRfidCard] ❌ Error: $e');
      debugPrint('[DentistSecurityProvider.deleteRfidCard] Stack: $stackTrace');
      _error = "Error al eliminar la tarjeta: $e";
      notifyListeners();
    }
  }

  void cancelRfidAssignment() {
    _scannedRfidCardId = null;
    _isAssigningRfidCard = false;
    notifyListeners();
  }

  // --- MÉTODOS PARA CONTROL LED ---
  Future<void> updateActiveLedOption(String? option) async {
    debugPrint(
      '[DentistSecurityProvider.updateActiveLedOption] Nueva opción: $option',
    );
    try {
      _dentistSecurityModel?.activeLedOption = option;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('[DentistSecurityProvider.updateActiveLedOption] ❌ Error: $e');
      debugPrint(
        '[DentistSecurityProvider.updateActiveLedOption] Stack: $stackTrace',
      );
      _error = "Error al actualizar la opción LED: $e";
      notifyListeners();
    }
  }

  // --- MÉTODOS PARA DISPOSITIVOS IoT ---
  Future<void> updateUserDeviceState(
    String deviceType,
    String deviceId,
    bool newState,
  ) async {
    debugPrint(
      '[DentistSecurityProvider.updateUserDeviceState] Tipo: $deviceType, ID: $deviceId, Estado: $newState',
    );

    try {
      // Aquí se actualiza el estado del dispositivo
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('[DentistSecurityProvider.updateUserDeviceState] ❌ Error: $e');
      debugPrint(
        '[DentistSecurityProvider.updateUserDeviceState] Stack: $stackTrace',
      );
      _error = "Error al actualizar el dispositivo: $e";
      notifyListeners();
    }
  }

  // --- MÉTODOS PARA CÁMARA ESP32 ---
  Future<void> setEsp32CamConfig({
    required String? ipAddress,
    required bool isActive,
  }) async {
    debugPrint(
      '[DentistSecurityProvider.setEsp32CamConfig] IP: $ipAddress, Activa: $isActive',
    );

    try {
      if (_dentistSecurityModel != null) {
        _dentistSecurityModel!.esp32CamIp = ipAddress;
        _dentistSecurityModel!.isCameraActive = isActive;
        _isCameraConnected =
            isActive && ipAddress != null && ipAddress.isNotEmpty;
      }
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('[DentistSecurityProvider.setEsp32CamConfig] ❌ Error: $e');
      debugPrint(
        '[DentistSecurityProvider.setEsp32CamConfig] Stack: $stackTrace',
      );
      _error = "Error al configurar la cámara: $e";
      notifyListeners();
    }
  }

  // Método para refrescar datos de seguridad
  Future<void> refreshData() async {
    try {
      _isLoading = true;
      notifyListeners();

      _dentistSecurityModel = await _securityService.fetchSecurityData(uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos para Alertas
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await _alertsService.markAsRead(alertId);
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> markAlertAsHandled(String alertId, String handledBy) async {
    try {
      await _alertsService.markAsHandled(alertId, handledBy);
    } catch (e) {
      _error = e.toString();
    }
  }

  // Métodos para Readers RFID
  Future<void> addReader(RfidReaderModel reader) async {
    try {
      final updatedReaders = [...?_dentistSecurityModel?.readers, reader];
      await _securityService.updateReaders(uid, updatedReaders);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Método para trigger manual de cámara
  Future<void> triggerCameraCapture(String camId) async {
    try {
      await _realtimeService.triggerCameraCapture(uid, camId);
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  void dispose() {
    _securityDataSubscription?.cancel();
    _rfidLogsSubscription?.cancel();
    _alertsSubscription?.cancel();
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
