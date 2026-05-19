import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedAllData() async {
    // Eliminar esta línea para desarrollo:，可以让每次都插入数据
    // if (_seedRunned) return;
    // _seedRunned = true;

    debugPrint('🌱 Starting seed data...');

    try {
      await Future.wait([
        _seedUsers(),
        _seedPosts(),
        _seedStories(),
        _seedPromotions(),
        _seedJobs(),
        _seedTreatments(),
        _seedAppointments(),
        _seedOdontograms(),
        _seedProducts(),
        _seedMessages(),
        _seedCalls(),
        _seedInvoices(),
        _seedVisits(),
        _seedReels(),
      ]);
      debugPrint('✅✅✅✅✅✅✅✅✅✅ Seed data completed!  ✅✅✅✅✅✅✅✅✅');
    } catch (e) {
      debugPrint('❌ Seed error: $e');
    }
  }

  Future<void> _seedUsers() async {
    final users = [
      {
        'uid': 'user_dentist_1',
        'email': 'dentista1@test.com',
        'fullName': 'Dra. Ana García',
        'userName': 'anagarcia',
        'imageUrl': 'https://randomuser.me/api/portraits/women/1.jpg',
        'role': 'dentist',
        'speciality': 'Ortodoncia',
        'isActive': true,
        'followersCount': 150,
        'followingCount': 45,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'user_dentist_2',
        'email': 'dentista2@test.com',
        'fullName': 'Dr. Carlos López',
        'userName': 'carloslop',
        'imageUrl': 'https://randomuser.me/api/portraits/men/2.jpg',
        'role': 'dentist',
        'speciality': 'Endodoncia',
        'isActive': true,
        'followersCount': 89,
        'followingCount': 30,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'user_dentist_3',
        'email': 'dentista3@test.com',
        'fullName': 'Dra. María Torres',
        'userName': 'mariatorres',
        'imageUrl': 'https://randomuser.me/api/portraits/women/3.jpg',
        'role': 'dentist',
        'speciality': 'Periodoncia',
        'isActive': true,
        'followersCount': 200,
        'followingCount': 60,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'user_patient_1',
        'email': 'paciente1@test.com',
        'fullName': 'Juan Pérez',
        'userName': 'juanperez',
        'imageUrl': 'https://randomuser.me/api/portraits/men/4.jpg',
        'role': 'patient',
        'isActive': true,
        'followersCount': 12,
        'followingCount': 25,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'user_patient_2',
        'email': 'paciente2@test.com',
        'fullName': 'Laura Martínez',
        'userName': 'lauramartinez',
        'imageUrl': 'https://randomuser.me/api/portraits/women/5.jpg',
        'role': 'patient',
        'isActive': true,
        'followersCount': 8,
        'followingCount': 15,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final user in users) {
      await _firestore.collection('users').doc(user['uid'] as String).set(user);
    }
    debugPrint('✅ Seeded ${users.length} users');
  }

Future<void> _seedPosts() async {
    final posts = [
      {
        'userId': 'user_dentist_1',
        'title': 'Nuevo tratamiento de Ortodoncia',
        'description': 'Hoy comenzamos un nuevo tratamiento de ortodoncia invisible. ¡El paciente está muy satisfecho con los resultados!',
        'imageUrls': [
          'https://images.unsplash.com/photo-1606811841689-10df2f43d718?w=800',
        ],
        'likedBy': ['user_patient_1', 'user_patient_2'],
        'likesCount': 15,
        'commentsCount': 3,
        'sharesCount': 2,
        'city': 'Ciudad de México',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_dentist_2',
        'title': 'Tips para cuidar tus dientes',
        'description': 'Recordatorio: Cepíllate los dientes al menos 2 veces al día y usa hilo dental. ¡Tu sonrisa te lo agradecerá!',
        'imageUrls': [
          'https://images.unsplash.com/photo-1606265752439-1f18756aa5fc?w=800',
        ],
        'likedBy': ['user_dentist_1', 'user_patient_1'],
        'likesCount': 28,
        'commentsCount': 5,
        'sharesCount': 8,
        'city': 'Guadalajara',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_dentist_3',
        'title': 'Caso clínico: Regeneración ósea',
        'description': 'Excelente resultado en este caso de regeneración ósea. La tecnología dental avanza cada día más.',
        'imageUrls': [
          'https://images.unsplash.com/photo-1629909613650-8e699c01a62c?w=800',
        ],
        'likedBy': ['user_dentist_1', 'user_dentist_2', 'user_patient_2'],
        'likesCount': 42,
        'commentsCount': 7,
        'sharesCount': 4,
        'city': 'Monterrey',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_dentist_1',
        'title': 'Blanqueamiento Dental',
        'description': ' Antes y después de un blanqueamiento profesional. ¡Transforma sonrisas!',
        'imageUrls': [
          'https://images.unsplash.com/photo-1579684385127-1ef15d508110?w=800',
        ],
        'likedBy': ['user_patient_1', 'user_patient_2', 'user_dentist_2'],
        'likesCount': 35,
        'commentsCount': 8,
        'sharesCount': 5,
        'city': 'Ciudad de México',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_dentist_2',
        'title': 'Implantes Dentales',
        'description': 'Los implantes dentales son la mejor opción para reemplazar dientes perdidos. ¡Consulta!',
        'imageUrls': [
          'https://images.unsplash.com/photo-1559599238-3087930f6388?w=800',
        ],
        'likedBy': ['user_patient_1'],
        'likesCount': 22,
        'commentsCount': 4,
        'sharesCount': 3,
        'city': 'Guadalajara',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final post in posts) {
      await _firestore.collection('posts').add(post);
    }
    debugPrint('✅ Seeded ${posts.length} posts');
  }

  Future<void> _seedStories() async {
    final stories = [
      {
        'userId': 'user_dentist_1',
        'userName': 'Dra. Ana García',
        'userPhoto': 'https://randomuser.me/api/portraits/women/1.jpg',
        'imageUrl': 'https://images.unsplash.com/photo-1606811841689-10df2f43d718?w=800',
        'status': 'Consultorio',
        'isActive': true,
        'isViewed': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_dentist_2',
        'userName': 'Dr. Carlos López',
        'userPhoto': 'https://randomuser.me/api/portraits/men/2.jpg',
        'imageUrl': 'https://images.unsplash.com/photo-1579684385127-1ef15d508110?w=800',
        'status': 'En consulta',
        'isActive': true,
        'isViewed': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_dentist_3',
        'userName': 'Dra. María Torres',
        'userPhoto': 'https://randomuser.me/api/portraits/women/3.jpg',
        'imageUrl': 'https://images.unsplash.com/photo-1629909613650-8e699c01a62c?w=800',
        'status': 'Cirugía',
        'isActive': true,
        'isViewed': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final story in stories) {
      await _firestore.collection('stories').add(story);
    }
    debugPrint('✅ Seeded ${stories.length} stories');
  }

  Future<void> _seedPromotions() async {
    final promotions = [
      {
        'name': 'Limpieza Dental + Blanqueamiento',
        'description': 'Paquete completo para una sonrisa perfecta. Incluye limpieza profunda y sesión de blanqueamiento.',
        'price': 2500.0,
        'discountPrice': 1800.0,
        'imageUrls': [
          'https://images.unsplash.com/photo-1606265752439-1f18756aa5fc?w=800',
        ],
        'category': 'estetica',
        'clinicName': 'Dental Care Studio',
        'rating': 4.8,
        'reviewsCount': 45,
        'isFeatured': true,
        'isAvailable': true,
        'isActive': true,
        'createdBy': 'user_dentist_1',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      },
      {
        'name': 'Ortodoncia Invisible - Promo',
        'description': 'Ortodoncia invisible con aligners removibles. Primera consultación sin costo.',
        'price': 35000.0,
        'discountPrice': 28000.0,
        'imageUrls': [
          'https://images.unsplash.com/photo-1606811841689-10df2f43d718?w=800',
        ],
        'category': 'ortodoncia',
        'clinicName': 'Dental Care Studio',
        'rating': 4.9,
        'reviewsCount': 120,
        'isFeatured': true,
        'isAvailable': true,
        'isActive': true,
        'createdBy': 'user_dentist_1',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 60))),
      },
      {
        'name': 'Revisión y Diagnóstico Gratis',
        'description': 'Tu primera visita incluye revisión completa y diagnóstico personalizado sin costo.',
        'price': 500.0,
        'discountPrice': 0.0,
        'imageUrls': [
          'https://images.unsplash.com/photo-1629909613650-8e699c01a62c?w=800',
        ],
        'category': 'general',
        'clinicName': 'Clínica Dental López',
        'rating': 4.5,
        'reviewsCount': 30,
        'isFeatured': false,
        'isAvailable': true,
        'isActive': true,
        'createdBy': 'user_dentist_2',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
      },
    ];

    for (final promo in promotions) {
      await _firestore.collection('promotions').add(promo);
    }
    debugPrint('✅ Seeded ${promotions.length} promotions');
  }

  Future<void> _seedJobs() async {
    final jobs = [
      {
        'title': 'Asistente Dental',
        'description': 'Buscamos asistente dental con experiencia. Disponibilidad completa, conocimientos de atención al paciente.',
        'company': 'Dental Care Studio',
        'companyLogo': 'https://randomuser.me/api/portraits/women/1.jpg',
        'location': 'Ciudad de México',
        'type': 'full-time',
        'salary': 12000.0,
        'salaryRange': '\$12,000 - \$15,000 mensuales',
        'requirements': ['Experiencia mínima 1 año', 'Licencia como asistente dental', 'Conocimientos de software dental'],
        'benefits': ['Prestaciones de ley', 'Horario flexible', 'Capacitación continua'],
        'specialty': 'Asistente dental',
        'isActive': true,
        'postedById': 'user_dentist_1',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      },
      {
        'title': 'Dentista General',
        'description': 'Se requiere dentista general para clínica establecida. Excelentes condiciones.',
        'company': 'Clínica Dental López',
        'companyLogo': 'https://randomuser.me/api/portraits/men/1.jpg',
        'location': 'Guadalajara, Jal.',
        'type': 'full-time',
        'salary': 25000.0,
        'salaryRange': '\$25,000 - \$35,000 mensuales',
        'requirements': ['Cédula profesional', 'Experiencia mínima 2 años', 'Especialidad deseable'],
        'benefits': ['Comisiones por tratamientos', 'Horario Lunes a Viernes', 'Instituto de idiomas'],
        'specialty': 'Dentista general',
        'isActive': true,
        'postedById': 'user_dentist_2',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
      },
      {
        'title': 'Ortodoncista',
        'description': 'Buscamos ortodoncista con especialidad. Trabaja con tecnología de última generación.',
        'company': 'Smile Design Clinic',
        'companyLogo': 'https://randomuser.me/api/portraits/men/2.jpg',
        'location': 'Monterrey, N.L.',
        'type': 'part-time',
        'salary': 40000.0,
        'salaryRange': '\$40,000+ mensuales',
        'requirements': ['Especialidad en Ortodoncia', 'Mínimo 3 años de experiencia', 'Conocimientos en sistemas de aligners'],
        'benefits': ['Porcentaje por casos', 'Equipo de última generación', 'Ambiente laboral activo'],
        'specialty': 'Ortodoncia',
        'isActive': true,
        'postedById': 'user_dentist_3',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 20))),
      },
    ];

    for (final job in jobs) {
      await _firestore.collection('jobs').add(job);
    }
    debugPrint('✅ Seeded ${jobs.length} jobs');
  }

  Future<void> _seedTreatments() async {
    final treatments = [
      {
        'name': 'Limpieza Dental',
        'description': 'Limpieza profesional超声波',
        'price': 800.0,
        'discountPrice': null,
        'iconName': 'cleaning',
        'category': 'preventivo',
        'durationMinutes': 45,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Blanqueamiento',
        'description': 'Blanqueamiento dental profesional',
        'price': 3500.0,
        'discountPrice': 2800.0,
        'iconName': 'whitening',
        'category': 'estético',
        'durationMinutes': 60,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Ortodoncia',
        'description': 'Tratamiento de ortodoncia tradicional',
        'price': 25000.0,
        'discountPrice': null,
        'iconName': 'braces',
        'category': 'ortodoncia',
        'durationMinutes': 30,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Endodoncia',
        'description': 'Tratamiento de conducto',
        'price': 4500.0,
        'discountPrice': null,
        'iconName': 'root',
        'category': 'endodoncia',
        'durationMinutes': 90,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final treatment in treatments) {
      await _firestore.collection('treatments').add(treatment);
    }
    debugPrint('✅ Seeded ${treatments.length} treatments');
  }

  Future<void> _seedAppointments() async {
    final now = DateTime.now();
    final appointments = [
      {
        'patientId': 'user_patient_1',
        'patientName': 'Juan Pérez',
        'patientPhoto': 'https://i.pravatar.cc/150?img=7',
        'dentistId': 'user_dentist_1',
        'treatmentName': 'Limpieza Dental',
        'date': Timestamp.fromDate(now),
        'timeSlot': '10:00 AM',
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'patientId': 'user_patient_2',
        'patientName': 'Laura Martínez',
        'patientPhoto': 'https://i.pravatar.cc/150?img=9',
        'dentistId': 'user_dentist_1',
        'treatmentName': 'Blanqueamiento',
        'date': Timestamp.fromDate(now),
        'timeSlot': '11:30 AM',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'patientId': 'user_patient_1',
        'patientName': 'Juan Pérez',
        'patientPhoto': 'https://i.pravatar.cc/150?img=7',
        'dentistId': 'user_dentist_1',
        'treatmentName': 'Ortodoncia',
        'date': Timestamp.fromDate(now.add(const Duration(days: 1))),
        'timeSlot': '09:00 AM',
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final apt in appointments) {
      await _firestore.collection('appointments').add(apt);
    }
    debugPrint('✅ Seeded ${appointments.length} appointments');
  }

  Future<void> _seedOdontograms() async {
    final odontograms = [
      {
        'patientId': 'user_patient_1',
        'patientName': 'Juan Pérez',
        'dentistId': 'user_dentist_1',
        'teethMap': {'11': 'caries', '21': 'sellante', '36': 'obturación'},
        'notes': 'Paciente con buena higiene oral',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'patientId': 'user_patient_2',
        'patientName': 'Laura Martínez',
        'dentistId': 'user_dentist_1',
        'teethMap': {'16': 'corona', '26': 'implante', '46': 'endodoncia'},
        'notes': 'Seguimiento mensual',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final od in odontograms) {
      await _firestore.collection('odontograms').add(od);
    }
    debugPrint('✅ Seeded ${odontograms.length} odontograms');
  }

  Future<void> _seedProducts() async {
    final products = [
      {'name': 'Cepillo Dental', 'price': 150.0, 'imageUrl': 'https://via.placeholder.com/150', 'isActive': true},
      {'name': 'Pasta Dental', 'price': 89.0, 'imageUrl': 'https://via.placeholder.com/150', 'isActive': true},
      {'name': 'Hilo Dental', 'price': 65.0, 'imageUrl': 'https://via.placeholder.com/150', 'isActive': true},
      {'name': 'Enjuague', 'price': 120.0, 'imageUrl': 'https://via.placeholder.com/150', 'isActive': true},
    ];
    for (final p in products) await _firestore.collection('products').add(p);
    debugPrint('✅ Seeded ${products.length} products');
  }

  Future<void> _seedMessages() async {
    final messages = [
      {'senderId': 'user_patient_1', 'senderName': 'Juan Pérez', 'senderPhoto': 'https://i.pravatar.cc/150?img=7', 'content': 'Hola doctor', 'isRead': false},
      {'senderId': 'user_patient_2', 'senderName': 'Laura Martínez', 'senderPhoto': 'https://i.pravatar.cc/150?img=9', 'content': 'Tengo una duda', 'isRead': true},
    ];
    for (final m in messages) await _firestore.collection('messages').add(m);
    debugPrint('✅ Seeded ${messages.length} messages');
  }

  Future<void> _seedCalls() async {
    final calls = [
      {'callerId': 'user_patient_1', 'callerName': 'Juan Pérez', 'callerPhoto': 'https://i.pravatar.cc/150?img=7', 'type': 'video', 'status': 'completed', 'duration': '5:30'},
      {'callerId': 'user_patient_2', 'callerName': 'Laura Martínez', 'callerPhoto': 'https://i.pravatar.cc/150?img=9', 'type': 'audio', 'status': 'missed'},
    ];
    for (final c in calls) await _firestore.collection('calls').add(c);
    debugPrint('✅ Seeded ${calls.length} calls');
  }

  Future<void> _seedInvoices() async {
    final invoices = [
      {'invoiceNumber': 'FAC-001', 'patientName': 'Juan Pérez', 'total': 1500.0, 'status': 'pending'},
      {'invoiceNumber': 'FAC-002', 'patientName': 'Laura Martínez', 'total': 2500.0, 'status': 'paid'},
    ];
    for (final inv in invoices) await _firestore.collection('invoices').add(inv);
    debugPrint('✅ Seeded ${invoices.length} invoices');
  }

  Future<void> _seedVisits() async {
    final visits = [
      {'patientId': 'user_patient_1', 'patientName': 'Juan Pérez', 'treatment': 'Limpieza', 'date': DateTime.now(), 'status': 'completed'},
      {'patientId': 'user_patient_2', 'patientName': 'Laura Martínez', 'treatment': 'Blanqueamiento', 'date': DateTime.now(), 'status': 'completed'},
    ];
    for (final v in visits) await _firestore.collection('visits').add(v);
    debugPrint('✅ Seeded ${visits.length} visits');
  }

  Future<void> _seedReels() async {
    final reels = [
      {'userId': 'user_dentist_1', 'videoUrl': 'https://via.placeholder.com/300', 'thumbnailUrl': 'https://via.placeholder.com/300', 'likesCount': 45, 'commentsCount': 12},
      {'userId': 'user_dentist_2', 'videoUrl': 'https://via.placeholder.com/300', 'thumbnailUrl': 'https://via.placeholder.com/300', 'likesCount': 78, 'commentsCount': 23},
    ];
    for (final r in reels) await _firestore.collection('reels').add(r);
    debugPrint('✅ Seeded ${reels.length} reels');
  }
}
