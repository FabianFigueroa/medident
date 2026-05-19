/// ───────────────────────────────────────────────────────────
///  SEED DATA — Poblado rápido de datos de prueba
/// ───────────────────────────────────────────────────────────
///  Uso desde la terminal:
///    1. Inicia sesión en la app con cualquier usuario
///    2. En OTRA terminal ejecuta:
///       flutter run lib/scripts/seed_all_data.dart
///    3. O desde código llama:  SeedAllData.run();
/// ───────────────────────────────────────────────────────────
///  Crea:
///    - 1 clínica    - 3 tratamientos   - 5 citas
///    - 3 promociones - 3 productos     - 5 posts
///    - 5 stories    - 3 turnos         - 2 trabajos
/// ───────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeedAllData {
  static Future<void> run() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❌ ERROR: No hay usuario autenticado. Inicia sesión primero.');
      return;
    }

    final uid = user.uid;
    final db = FirebaseFirestore.instance;
    debugPrint('🌱 SeedAllData: poblando datos para UID $uid...');

    try {
      // 1. CLÍNICA
      final clinicId = 'clinic_seed_001';
      await db.collection('clinics').doc(clinicId).set({
        'name': 'Clínica Dental Medident',
        'ownerId': uid,
        'nit': '901.123.456-7',
        'address': 'Carrera 45 # 23-12, Bogotá',
        'phone': '+57 321 456 7890',
        'email': 'contacto@medident.com',
        'apiKey': 'CL-SEED-0001-ABCD',
        'employeeIds': [uid],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. TRATAMIENTOS
      final treatments = [
        {'name': 'Limpieza Dental', 'description': 'Limpieza profunda con ultrasonido', 'price': 120000, 'isActive': true},
        {'name': 'Blanqueamiento', 'description': 'Blanqueamiento con tecnología láser', 'price': 350000, 'isActive': true},
        {'name': 'Ortodoncia Invisible', 'description': 'Alineadores transparentes personalizados', 'price': 2500000, 'isActive': true},
      ];
      for (int i = 0; i < treatments.length; i++) {
        await db.collection('treatments').doc('treatment_seed_$i').set({
          ...treatments[i],
          'clinicId': clinicId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. PROMOCIONES
      final promotions = [
        {'name': 'Descuento en Limpieza', 'description': '30% off en limpieza dental', 'price': 84000, 'scope': 'global', 'isActive': true, 'imageUrls': ['https://images.unsplash.com/photo-1606811841689-23cc3dee82c0?w=600']},
        {'name': 'Blanqueamiento Express', 'description': 'Precio especial de lanzamiento', 'price': 250000, 'scope': 'global', 'isActive': true, 'imageUrls': ['https://images.unsplash.com/photo-1576091160550-112173e7f869?w=600']},
        {'name': 'Chequeo General', 'description': 'Valoración completa + radiografía', 'price': 50000, 'scope': 'clinic', 'isActive': true, 'imageUrls': ['https://images.unsplash.com/photo-1584308666744-24d5f83f2f9d?w=600']},
      ];
      for (int i = 0; i < promotions.length; i++) {
        await db.collection('promotions').doc('promo_seed_$i').set({
          ...promotions[i],
          'userId': uid,
          'clinicId': clinicId,
          'discountPrice': (promotions[i]['price'] as int) * 0.7,
          'isFeatured': i == 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 4. PRODUCTOS (tienda)
      final products = [
        {'name': 'Cepillo Eléctrico', 'description': 'Cepillo sónico con 3 velocidades', 'price': 89000, 'isActive': true, 'imageUrls': ['https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=400']},
        {'name': 'Hilo Dental', 'description': 'Hilo encerado 50m', 'price': 15000, 'isActive': true, 'imageUrls': ['https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=400']},
        {'name': 'Enjuague Bucal', 'description': 'Antiséptico sin alcohol 500ml', 'price': 28000, 'isActive': true, 'imageUrls': ['https://images.unsplash.com/photo-1585382621162-36e91536e9f6?w=400']},
      ];
      for (int i = 0; i < products.length; i++) {
        await db.collection('products').doc('product_seed_$i').set({
          ...products[i],
          'createdBy': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 5. CITAS (appointments)
      final now = DateTime.now();
      final patients = ['Paciente Demo 1', 'Paciente Demo 2', 'Paciente Demo 3', 'Paciente Demo 4', 'Paciente Demo 5'];
      for (int i = 0; i < patients.length; i++) {
        await db.collection('appointments').doc('appt_seed_$i').set({
          'patientId': 'patient_seed_$i',
          'patientName': patients[i],
          'dentistId': uid,
          'clinicId': clinicId,
          'treatmentName': treatments[i % treatments.length]['name'],
          'date': Timestamp.fromDate(now.add(Duration(days: i))),
          'timeSlot': '${8 + i}:00',
          'status': i == 0 ? 'confirmed' : 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 6. TURNOS (shifts)
      for (int i = 0; i < 3; i++) {
        await db.collection('turnos').doc('turno_seed_$i').set({
          'dentistId': uid,
          'employeeId': uid,
          'employeeName': 'Dr. Demo',
          'clinicId': clinicId,
          'date': Timestamp.fromDate(now.add(Duration(days: i))),
          'startTime': '08:00',
          'endTime': '17:00',
          'status': i == 0 ? 'in_progress' : 'scheduled',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 7. POSTS
      final unsplashIds = ['1606811841689', '1576091160550', '1584308666744', '1588776814541', '1607613009820'];
      final postContents = [
        {'title': 'Nueva tecnología 3D', 'description': 'Ahora contamos con escáner intraoral 3D para diagnósticos más precisos.'},
        {'title': 'Tips de higiene dental', 'description': 'Cepíllate 3 veces al día y usa hilo dental. Tu sonrisa te lo agradecerá.'},
        {'title': 'Ortodoncia invisible', 'description': '¿Sabías que los alineadores invisibles corrigen tu sonrisa sin brackets?'},
        {'title': 'Blanqueamiento seguro', 'description': 'Nuestro blanqueamiento dental respeta el esmalte y elimina manchas profundas.'},
        {'title': 'Urgencias dentales', 'description': 'Tenemos horario extendido para emergencias. ¡Contáctanos!', 'city': 'Bogotá'},
      ];
      for (int i = 0; i < postContents.length; i++) {
        final imgUrl = 'https://images.unsplash.com/photo-${unsplashIds[i]}?w=600';
        await db.collection('posts').doc('post_seed_$i').set({
          ...postContents[i],
          'userId': uid,
          'imageUrls': [imgUrl],
          'media': [{'url': imgUrl, 'type': 'image'}],
          'likesCount': 10 + i * 5,
          'commentsCount': 2 + i,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 8. STORIES
      final storyIds = ['1606811841689', '1576091160550', '1584308666744', '1579154204601', '1588776814541'];
      for (int i = 0; i < 5; i++) {
        final imgUrl = 'https://images.unsplash.com/photo-${storyIds[i]}?w=400';
        await db.collection('stories').doc('story_seed_$i').set({
          'userId': uid,
          'userName': 'Dr. Demo',
          'imageUrl': imgUrl,
          'media': [{'url': imgUrl, 'type': 'image'}],
          'isActive': true,
          'viewedBy': [],
          'likedBy': [],
          'likesCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 9. TRABAJOS (jobs)
      await db.collection('jobs').doc('job_seed_0').set({
        'title': 'Odontólogo General',
        'description': 'Buscamos odontólogo con experiencia mínima de 2 años para consulta general.',
        'company': 'Clínica Dental Medident',
        'companyLogo': 'https://img.icons8.com/color/96/000000/dentist.png',
        'location': 'Bogotá',
        'type': 'Tiempo Completo',
        'salary': '\$3,000,000 - \$4,500,000',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await db.collection('jobs').doc('job_seed_1').set({
        'title': 'Higienista Dental',
        'description': 'Higienista para turnos de mañana y tarde. Experiencia en limpieza profunda.',
        'company': 'Clínica Dental Medident',
        'companyLogo': 'https://img.icons8.com/color/96/000000/tooth.png',
        'location': 'Bogotá',
        'type': 'Medio Tiempo',
        'salary': '\$1,500,000 - \$2,000,000',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ SeedAllData COMPLETADO — 9 colecciones pobladas con datos de prueba.');
      debugPrint('📊 Resumen: 1 clínica, 3 tratamientos, 3 promos, 3 productos,');
      debugPrint('            5 citas, 3 turnos, 5 posts, 5 stories, 2 trabajos.');
    } catch (e) {
      debugPrint('❌ SeedAllData ERROR: $e');
    }
  }
}
