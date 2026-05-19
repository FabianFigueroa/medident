import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/providers/clinic/clinic-provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/providers/domain/appointment-provider.dart';
import 'package:medident/core/providers/domain/agenda-provider.dart';
import 'package:medident/core/services/clinic/clinic-appointment-service.dart';
import 'package:medident/core/services/agenda-service.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/clinic-feed-tab.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/clinic-turnos-tab.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/clinic-historial-tab.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/clinic-posts-tab.dart';
import 'package:medident/screens/shared/widgets/agenda-tab.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/clinic_header_widget.dart';

class DentistClinic_Dashboard extends StatefulWidget {
  const DentistClinic_Dashboard({super.key});

  @override
  State<DentistClinic_Dashboard> createState() => _DentistClinic_DashboardState();
}

class _DentistClinic_DashboardState extends State<DentistClinic_Dashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AppointmentProvider? _appointmentProvider;
  AgendaProvider? _agendaProvider;
  String _lastClinicId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appointmentProvider?.dispose();
    _agendaProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinicId = context.select<ClinicProvider, String>((p) => p.clinic?.id ?? '');
    final clinicPromos = context.select<ClinicProvider, List<ProductModel>>((p) => p.promotions);
    final clinicTreatments = context.select<ClinicProvider, List<TreatmentModel>>((p) => p.treatments);
    final isOwner = context.select<ClinicProvider, bool>((p) => p.isOwner);
    final user = context.select<AuthenticateProvider, UserModel?>((p) => p.user);

    if (clinicId.isNotEmpty && _lastClinicId != clinicId) {
      _appointmentProvider?.dispose();
      _appointmentProvider = AppointmentProvider(
        service: ClinicAppointmentService(clinicId: clinicId),
      );
      _agendaProvider?.dispose();
      _agendaProvider = AgendaProvider(service: AgendaService())..initialize(clinicId);
      _lastClinicId = clinicId;
    } else if (clinicId.isEmpty && _appointmentProvider == null) {
      _appointmentProvider = AppointmentProvider(
        service: ClinicAppointmentService(clinicId: ''),
      );
      _agendaProvider = AgendaProvider(service: AgendaService());
    }

    final promos = clinicPromos.expand((p) {
      if (p.slides.isNotEmpty) {
        return p.slides.map((s) => <String, dynamic>{
          'id': p.id,
          'promoId': p.id,
          'imageUrls': [s.imageUrl],
          'imageUrl': s.imageUrl,
          'title': s.title ?? p.name,
          'subtitle': s.subtitle,
          'name': s.title ?? p.name,
          'description': s.subtitle ?? p.description,
          'price': s.price ?? p.price,
          'discountPrice': s.discountPrice ?? p.discountPrice,
          'category': p.category,
          'terms': p.terms,
          'expiresAt': p.expiresAt?.toIso8601String(),
          'createdBy': p.createdBy,
          'ctaText': s.ctaText ?? 'Solicitar servicio',
          'overlayPosition': s.overlayPosition,
          'rating': p.rating,
          'reviewsCount': p.reviewsCount,
          'isActive': p.isActive,
        });
      }
      if (p.imageUrls.length > 1) {
        return p.imageUrls.map((url) => <String, dynamic>{
          'id': p.id,
          'promoId': p.id,
          'imageUrls': [url],
          'imageUrl': url,
          'title': p.name,
          'name': p.name,
          'description': p.description,
          'price': p.price,
          'discountPrice': p.discountPrice,
          'category': p.category,
          'terms': p.terms,
          'expiresAt': p.expiresAt?.toIso8601String(),
          'createdBy': p.createdBy,
          'rating': p.rating,
          'reviewsCount': p.reviewsCount,
          'isActive': p.isActive,
        });
      }
      return [<String, dynamic>{
        'id': p.id,
        'promoId': p.id,
        'imageUrls': p.imageUrls,
        'imageUrl': p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
        'title': p.name,
        'name': p.name,
        'description': p.description,
        'price': p.price,
        'discountPrice': p.discountPrice,
        'category': p.category,
        'terms': p.terms,
        'expiresAt': p.expiresAt?.toIso8601String(),
        'createdBy': p.createdBy,
        'rating': p.rating,
        'reviewsCount': p.reviewsCount,
        'isActive': p.isActive,
      }];
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              expandedHeight: 428,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: context.watch<ClinicProvider>().primaryColor,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: user != null
                    ? Clinic_Header_Widget(
                        userModel: user,
                        promotions: promos,
                        treatments: clinicTreatments,
                        isOwner: isOwner,
                        clinicId: clinicId,
                        onEditProfilePressed: () {
                          if (isOwner) {
                            Navigator.pushNamed(context, '/clinic/edit');
                          } else {
                            Navigator.pushNamed(context, '/profile');
                          }
                        },
                      )
                    : const SizedBox.shrink(),
                collapseMode: CollapseMode.parallax,
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(
                  color: Colors.white,
                    child: TabBar(
                    controller: _tabController,
                    indicatorColor: context.watch<ClinicProvider>().primaryColor,
                    indicatorWeight: 2.5,
                    labelColor: context.watch<ClinicProvider>().primaryColor,
                    unselectedLabelColor: Colors.grey[400],
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    tabs: const [
                      Tab(text: 'Inicio'),
                      Tab(text: 'Agendas'),
                      Tab(text: 'Turnos'),
                      Tab(text: 'Historial'),
                      Tab(text: 'Posts'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _appointmentProvider),
            ChangeNotifierProvider.value(value: _agendaProvider),
          ],
          child: TabBarView(
            controller: _tabController,
            children: const [
              ClinicFeedTab(),
              AgendaTab_Screen(),
              ClinicTurnosTab(),
              ClinicHistorialTab(),
              ClinicPostsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
