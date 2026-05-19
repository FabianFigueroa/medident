import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/roles/dentist/dentist-rfid-model.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/models/roles/dentist/dentist-sensor-model.dart';
import 'package:medident/core/models/rfid-reader-model.dart';

class DentistSecurityService {
  /////
  final CollectionReference _securityCollection=FirebaseFirestore.instance.collection('security');
  /// Escucha los cambios en tiempo real y los convierte en un objeto [DentistSecurityModel].
  Stream<DentistSecurityModel> getSecurityDataStream(String userId) {
    return _securityCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return DentistSecurityModel.fromFirestore(snapshot);
      } else {
        // Si el dentista no tiene un documento, devolvemos uno por defecto
        // indicando que el contrato está inactivo.
        return DentistSecurityModel(
          userId: userId,
          locationId: '',
          contractStatus: 'inactive', // Usamos tu propuesta de status
        );
      }
    });
  }
  ////////////
  Future<void> createInitialContract(String userId, {String locationId = '', String address = ''}) async {
    final docRef = _securityCollection.doc(userId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      try {
        await docRef.set({
          'userId': userId,
          'locationId': locationId,
          'contract-status': 'pending',
          'address': address,
          'employeeCount': 0,
          'cards': [],
          'sensors': [],
        });
      } catch (e) {
        throw Exception('No se pudo crear el contrato inicial.');
      }
    }
  }

  /// Añade una nueva tarjeta RFID al contrato del usuario.
  Future<void> addCard(String userId, DentistRfidCardModel newCard) async {
    try {
      final docRef = _securityCollection.doc(userId);
      await docRef.update({
        'cards': FieldValue.arrayUnion([newCard.toMap()])
      });
    } catch (e) {
      debugPrint("Error al añadir tarjeta: $e");
      throw Exception('No se pudo añadir la tarjeta.');
    }
  }

  /// Elimina una tarjeta RFID del contrato del usuario.
  Future<void> deleteCard(String userId, DentistRfidCardModel cardToDelete) async {
    try {
      final docRef = _securityCollection.doc(userId);
      await docRef.update({
        'cards': FieldValue.arrayRemove([cardToDelete.toMap()])
      });
    } catch (e) {
      debugPrint("Error al eliminar tarjeta: $e");
      throw Exception('No se pudo eliminar la tarjeta.');
    }
  }

  /// Actualiza los datos de una tarjeta existente (nombre o estado).
  Future<void> updateCard(String userId, DentistRfidCardModel updatedCard) async {
    try {
      final docRef = _securityCollection.doc(userId);
      final doc = await docRef.get();

      if (doc.exists) {
        final model = DentistSecurityModel.fromFirestore(doc);
        final List<DentistRfidCardModel> updatedCards = model.cards.map((card) {
          return card.cardId == updatedCard.cardId ? updatedCard : card;
        }).toList();

        await docRef.update({'cards': updatedCards.map((c) => c.toMap()).toList()});
      }
    } catch (e) {
      debugPrint("Error al actualizar tarjeta: $e");
      throw Exception('No se pudo actualizar la tarjeta.');
    }
  }


  // --- Métodos para gestionar Sensores IoT ---

  /// Añade un nuevo sensor al contrato del usuario.
  Future<void> addSensor(String userId, DentistSensorModel newSensor) async {
    try {
      final docRef = _securityCollection.doc(userId);
      await docRef.update({
        'sensors': FieldValue.arrayUnion([newSensor.toMap()])
      });
    } catch (e) {
      debugPrint("Error al añadir sensor: $e");
      throw Exception('No se pudo añadir el sensor.');
    }
  }

  /// Elimina un sensor del contrato del usuario.
  Future<void> deleteSensor(String userId, DentistSensorModel sensorToDelete) async {
    try {
      final docRef = _securityCollection.doc(userId);
      await docRef.update({
        'sensors': FieldValue.arrayRemove([sensorToDelete.toMap()])
      });
    } catch (e) {
      debugPrint("Error al eliminar sensor: $e");
      throw Exception('No se pudo eliminar el sensor.');
    }
  }

  Future<void> updateContractStatus(String userId, String status) async {
    await _securityCollection.doc(userId).update({'contract-status': status});
  }
 
  /// Verifica si el documento de seguridad para un usuario existe.
  Future<bool> doesSecurityDocumentExist(String userId) async {
    final doc = await _securityCollection.doc(userId).get();
    return doc.exists;
  }

  Future<DentistSecurityModel> fetchSecurityData(String userId) async {
    try {
      final doc = await _securityCollection.doc(userId).get();
      if (doc.exists) {
        return DentistSecurityModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('fetchSecurityData error: $e');
    }
    return DentistSecurityModel(
      userId: userId,
      contractStatus: 'inactive',
      locationId: '',
      securityLogs: [],
    );
  }

  /// Actualizar lectores RFID
  Future<void> updateReaders(String userId, List<RfidReaderModel> readers) async {
    try {
      final cardsMap = readers.map((r) => r.toMap()).toList();
      await _securityCollection.doc(userId).update({
        'readers': cardsMap,
      });
    } catch (e) {
      debugPrint("Error al actualizar lectores: $e");
      throw Exception('No se pudieron actualizar los lectores.');
    }
  }

  /// Obtener lectores RFID
  Future<List<RfidReaderModel>> getReaders(String userId) async {
    try {
      final doc = await _securityCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final readers = data['readers'] as List<dynamic>? ?? [];
        return readers.map((r) => RfidReaderModel.fromMap(r)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error al obtener lectores: $e");
      return [];
    }
  }
}
