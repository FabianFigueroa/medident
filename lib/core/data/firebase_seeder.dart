import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSeeder {
  static bool _executed = false;

  static Future<void> seedOnce() async {
    if (_executed) return;
    _executed = true;

    final fs = FirebaseFirestore.instance;
    final batch = fs.batch();

    // --- Users ---
    final users = {
      'doctor_demo_1': {
        'fullName': 'Dr. Carlos Montiel',
        'firstName': 'Carlos',
        'email': 'carlos@medident.com',
        'role': 'doctor',
        'speciality': 'Odontología General',
        'phoneNumber': '+57 300 123 4567',
        'imageUrl': '',
        'servicesCount': 342,
        'followersCount': 1280,
        'followingCount': 89,
        'isInClinic': true,
        'clinicId': 'clinic_demo_1',
        'isClinicOwner': true,
        'userName': '@carlosmontiel',
      },
      'doctor_demo_2': {
        'fullName': 'Dra. Ana García',
        'firstName': 'Ana',
        'email': 'ana@medident.com',
        'role': 'doctor',
        'speciality': 'Ortodoncia',
        'phoneNumber': '+57 300 987 6543',
        'imageUrl': '',
        'servicesCount': 198,
        'followersCount': 856,
        'followingCount': 45,
        'isInClinic': true,
        'clinicId': 'clinic_demo_1',
        'isClinicOwner': false,
        'userName': '@anagarcia',
      },
      'patient_demo_1': {
        'fullName': 'María Rodríguez',
        'firstName': 'María',
        'email': 'maria@email.com',
        'role': 'patient',
        'phoneNumber': '+57 300 555 0101',
        'imageUrl': '',
        'isInClinic': false,
      },
    };

    for (final entry in users.entries) {
      final ref = fs.collection('users').doc(entry.key);
      batch.set(ref, entry.value);
    }

    // --- Clinic ---
    batch.set(fs.collection('clinics').doc('clinic_demo_1'), {
      'name': 'Clínica Medident',
      'description': 'Odontología de punta con los mejores profesionales',
      'address': 'Carrera 45 # 23-12, Bogotá',
      'phone': '+57 1 234 5678',
      'ownerId': 'doctor_demo_1',
      'isActive': true,
      'createdAt': Timestamp.now(),
      'coverImage': '',
    });

    // --- Products / Promotions ---
    final products = [
      {'name': 'Blanqueamiento Dental', 'description': 'Tecnología láser, resultados inmediatos', 'price': 350000, 'discountPrice': 249000, 'imageUrls': [], 'isActive': true, 'category': 'Estética'},
      {'name': 'Limpieza Profunda', 'description': 'Profylaxis completa con fluorización', 'price': 120000, 'discountPrice': 89000, 'imageUrls': [], 'isActive': true, 'category': 'Prevención'},
      {'name': 'Consulta Especializada', 'description': 'Valoración integral con especialista', 'price': 150000, 'imageUrls': [], 'isActive': true, 'category': 'General'},
      {'name': 'Ortodoncia Invisible', 'description': 'Alineadores transparentes, plan completo', 'price': 3500000, 'discountPrice': 2800000, 'imageUrls': [], 'isActive': true, 'category': 'Ortodoncia'},
      {'name': 'Implante Dental', 'description': 'Implante de titanio con corona porcelana', 'price': 1800000, 'discountPrice': 1500000, 'imageUrls': [], 'isActive': true, 'category': 'Cirugía'},
    ];

    for (int i = 0; i < products.length; i++) {
      final ref = fs.collection('products').doc('product_demo_${i+1}');
      batch.set(ref, {...products[i], 'createdAt': Timestamp.now()});
    }

    // --- Promotions ---
    final promotions = [
      {'name': '\u{1F384} Plan Navide\u00F1o', 'imageUrl': '', 'title': 'Sonrisa Perfecta', 'description': 'Blanqueamiento + Limpieza por solo \$299.000', 'isActive': true},
      {'name': '\u{1F338} Promoci\u00F3n Marzo', 'imageUrl': '', 'title': 'Mes de la Mujer', 'description': '30% descuento en consulta con especialista', 'isActive': true},
      {'name': '\u{1F9B7} D\u00EDa del Odont\u00F3logo', 'imageUrl': '', 'title': 'Celebra con nosotros', 'description': '2x1 en valoraci\u00F3n integral', 'isActive': true},
    ];

    for (int i = 0; i < promotions.length; i++) {
      final ref = fs.collection('promotions').doc('promo_demo_${i+1}');
      batch.set(ref, {...promotions[i], 'createdAt': Timestamp.now()});
    }

    // --- Posts ---
    final posts = [
      {
        'userId': 'doctor_demo_1',
        'sourceType': 'user',
        'sourceId': 'doctor_demo_1',
        'sourceName': 'Dr. Carlos Montiel',
        'sourcePhoto': '',
        'description': '✨ Transformando sonrisas todos los días. La ortodoncia invisible está cambiando vidas. ¿Ya conoces nuestros alineadores?',
        'imageUrls': [],
        'likesCount': 45,
        'commentsCount': 7,
        'sharesCount': 3,
        'likedBy': ['doctor_demo_2'],
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        'isActive': true,
      },
      {
        'userId': 'doctor_demo_2',
        'sourceType': 'user',
        'sourceId': 'doctor_demo_2',
        'sourceName': 'Dra. Ana García',
        'sourcePhoto': '',
        'description': '🦷 Tips para mantener una sonrisa saludable: \n1. Cepillado 3 veces al día\n2. Usa seda dental\n3. Visita al odontólogo cada 6 meses\n4. Evita el exceso de azúcar',
        'imageUrls': [],
        'likesCount': 32,
        'commentsCount': 5,
        'sharesCount': 12,
        'likedBy': [],
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
        'isActive': true,
      },
      {
        'userId': 'doctor_demo_1',
        'sourceType': 'clinic',
        'sourceId': 'clinic_demo_1',
        'sourceName': 'Clínica Medident',
        'sourcePhoto': '',
        'description': '🏥 Nueva tecnología 3D para diagnóstico. Ahora con escáner intraoral digital. Resultados más rápidos y precisos.',
        'imageUrls': [],
        'likesCount': 67,
        'commentsCount': 11,
        'sharesCount': 8,
        'likedBy': ['doctor_demo_1', 'doctor_demo_2'],
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
        'isActive': true,
      },
    ];

    for (int i = 0; i < posts.length; i++) {
      final ref = fs.collection('posts').doc('post_demo_${i+1}');
      batch.set(ref, posts[i]);
    }

    // --- Appointments ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointments = [
      {'patientId': 'patient_demo_1', 'patientName': 'María Rodríguez', 'dentistId': 'doctor_demo_1', 'date': Timestamp.fromDate(today.add(const Duration(hours: 9))), 'startTime': '09:00', 'endTime': '09:45', 'reason': 'Valoración general', 'serviceType': 'General', 'status': 'confirmed', 'cost': 150000, 'consultingRoom': 'Consultorio 1'},
      {'patientId': '', 'patientName': 'Pedro Martínez', 'dentistId': 'doctor_demo_1', 'date': Timestamp.fromDate(today.add(const Duration(hours: 10, minutes: 30))), 'startTime': '10:30', 'endTime': '11:30', 'reason': 'Blanqueamiento dental', 'serviceType': 'Estética', 'status': 'confirmed', 'cost': 350000, 'consultingRoom': 'Consultorio 1'},
      {'patientId': '', 'patientName': 'Laura Jiménez', 'dentistId': 'doctor_demo_2', 'date': Timestamp.fromDate(today.add(const Duration(hours: 11))), 'startTime': '11:00', 'endTime': '11:30', 'reason': 'Control de ortodoncia', 'serviceType': 'Ortodoncia', 'status': 'in_progress', 'cost': 80000, 'consultingRoom': 'Consultorio 2'},
      {'patientId': '', 'patientName': 'Andrea López', 'dentistId': 'doctor_demo_1', 'date': Timestamp.fromDate(today.add(const Duration(hours: 14))), 'startTime': '14:00', 'endTime': '14:45', 'reason': 'Limpieza profunda', 'serviceType': 'Prevención', 'status': 'confirmed', 'cost': 120000, 'consultingRoom': 'Consultorio 1'},
    ];

    for (int i = 0; i < appointments.length; i++) {
      final ref = fs.collection('appointments').doc('appt_demo_${i+1}');
      batch.set(ref, appointments[i]);
    }

    // --- Comments ---
    final comments = [
      {'postId': 'post_demo_1', 'sourceType': 'user', 'sourceId': 'doctor_demo_2', 'sourceName': 'Dra. Ana García', 'sourcePhoto': '', 'content': 'Excelente trabajo! Mis pacientes están encantados.', 'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1)))},
      {'postId': 'post_demo_1', 'sourceType': 'user', 'sourceId': '', 'sourceName': 'Paciente Feliz', 'sourcePhoto': '', 'content': 'Me encantó el resultado! Recomiendo 100%', 'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30)))},
    ];

    for (int i = 0; i < comments.length; i++) {
      final ref = fs.collection('comments').doc();
      batch.set(ref, comments[i]);
    }

    await batch.commit();
  }
}
