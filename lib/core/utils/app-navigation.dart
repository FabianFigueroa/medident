// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:medident/ia/valeria.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/models/data/users-en-linea.dart';
import 'package:medident/core/models/roles/user_role.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/utils/app-logger.dart';
import 'package:medident/core/utils/screen-trace.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/screens/widgets/avatar/circle_avatar_widget.dart';
import 'package:medident/screens/role/admin/home/admin-home-screen.dart';
import 'package:medident/screens/role/admin/shops/admin-shops-screen.dart';
import 'package:medident/screens/role/admin/security/admin-security-screen.dart';
import 'package:medident/screens/role/admin/deliveries/admin-delivery-screen.dart';
import 'package:medident/screens/role/admin/profile/admin-profile-screen.dart';
import 'package:medident/screens/role/admin/security/widgets/admin-contracts-nav-screen.dart';
import 'package:medident/screens/role/dentist/home/dentist-home-screen.dart';
import 'package:medident/screens/role/dentist/agenda/dentist-personal-agenda.dart';
import 'package:medident/screens/role/dentist/clinic/dentist-clinic-screen.dart';
import 'package:medident/screens/role/dentist/profile/dentist-profile-screen.dart';
import 'package:medident/screens/role/doctor/doctor-delivery-screen.dart';
import 'package:medident/screens/role/doctor/agenda/doctor-personal-agenda.dart';
import 'package:medident/screens/role/doctor/doctor-home-screen.dart';
import 'package:medident/screens/role/doctor/doctor-shop-screen.dart';
import 'package:medident/screens/role/doctor/doctor-security-screen.dart';
import 'package:medident/screens/role/doctor/doctor-profile-screen.dart';
import 'package:medident/screens/role/employee/employee-home-screen.dart';
import 'package:medident/screens/role/employee/agenda/employee-personal-agenda.dart';
import 'package:medident/screens/role/employee/employee-shop-screen.dart';
import 'package:medident/screens/role/employee/employee-security-screen.dart';
import 'package:medident/screens/role/employee/employee-delivery-screen.dart';
import 'package:medident/screens/role/employee/employee-profile-screen.dart';
import 'package:medident/screens/role/patient/patient-delivery-screen.dart';
import 'package:medident/screens/role/patient/patient-home-screen.dart';
import 'package:medident/screens/role/patient/agenda/patient-personal-agenda.dart';
import 'package:medident/screens/role/patient/patient-shop-screen.dart';
import 'package:medident/screens/role/patient/patient-security-screen.dart';
import 'package:medident/screens/role/patient/patient-profile-screen.dart';
import 'package:medident/screens/role/delivery/delivery-home-screen.dart';
import 'package:medident/screens/role/delivery/delivery-profile-screen.dart';
import 'package:medident/screens/role/delivery/delivery-security-screen.dart';

class NavigationsScreen extends StatefulWidget {
  final UserRole role;

  const NavigationsScreen({
    super.key,
    required this.role,
  });

  @override
  State<NavigationsScreen> createState() => _NavigationsScreenState();
}

class _NavigationsScreenState extends State<NavigationsScreen>
    with SingleTickerProviderStateMixin {
      
  final List<UserModel> _allEmployees = [
    usersOnline[0],
    usersOnline[6],
    usersOnline[8],
    usersOnline[2],
  ];

  UserModel? _selectedEmployee;
  late TabController _tabController;
  late _RoleNavigationConfig _config;

  /// Avatar flotante de Valeria IA. Desactivado por ahora para centrarnos en
  /// la administración de la clínica. Cambiar a true para volver a mostrarlo.
  static const bool _showValeriaAssistant = false;

  /// NavegaciÃ³n lazy (patrÃ³n tenderos): solo se montan las pestaÃ±as que el
  /// usuario ya visitÃ³. Antes el IndexedStack montaba TODAS las pantallas del
  /// rol a la vez y cada una disparaba su `initializeSection(...)` en el
  /// arranque (home + shop + security + delivery + profile compitiendo por la
  /// red). Ahora el primer frame solo monta el Home.
  int _selectedIndex = 0;
  int _maxLoadedIndex = 0;

  final SearchController _searchController = SearchController();

  String get _roleName => AppLogger.roleName(widget.role);

  @override
  void initState() {
    super.initState();
    _config = _buildNavigationForRole(widget.role);
    _tabController = TabController(length: _config.items.length, vsync: this);
    _tabController.addListener(_onTabIndexChanged);
    _selectedIndex = 0;
    _maxLoadedIndex = 0;
    if (_allEmployees.isNotEmpty) {
      _selectedEmployee = _allEmployees[0];
    }
  }

  void _onTabIndexChanged() {
    final index = _tabController.index;
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        if (index > _maxLoadedIndex) _maxLoadedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabIndexChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  _RoleNavigationConfig _buildNavigationForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return _RoleNavigationConfig(
          roleName: 'admin',
          items: const [
            _NavItem(
              label: 'Inicio',
              icon: HugeIcons.strokeRoundedHome01,
              activeIcon: HugeIcons.strokeRoundedHome09,
              screen: AdminHomeScreen(),
            ),
            _NavItem(
              label: 'Tiendas',
              icon: HugeIcons.strokeRoundedStore03,
              activeIcon: HugeIcons.strokeRoundedShopSign,
              screen: AdminShopsScreen(),
            ),
            _NavItem(
              label: 'Seguridad',
              icon: HugeIcons.strokeRoundedShield01,
              activeIcon: HugeIcons.strokeRoundedShield02,
              screen: AdminSecurityScreen(),
            ),
            _NavItem(
              label: 'Envios',
              icon: HugeIcons.strokeRoundedTruck,
              activeIcon: HugeIcons.strokeRoundedTruckDelivery,
              screen: AdminDeliveryScreen(),
            ),
            _NavItem(
              label: 'Contratos',
              icon: HugeIcons.strokeRoundedFile01,
              activeIcon: HugeIcons.strokeRoundedFile02,
              screen: AdminContractsNavScreen(),
            ),
            _NavItem(
              label: 'Perfil',
              icon: HugeIcons.strokeRoundedUser,
              activeIcon: HugeIcons.strokeRoundedUserCircle,
              screen: AdminProfileScreen(),
            ),
          ],
        );
      case UserRole.dentist:
        return _RoleNavigationConfig(
          roleName: 'dentist',
          items: const [
            _NavItem(
              label: 'Home',
              icon: HugeIcons.strokeRoundedHome01,
              activeIcon: HugeIcons.strokeRoundedHome09,
              screen: DentistHomeScreen(),
            ),
            _NavItem(
              label: 'ClÃ­nica',
              icon: HugeIcons.strokeRoundedHospital01,
              activeIcon: HugeIcons.strokeRoundedHospital02,
              screen: DentistClinicScreen(),
            ),
            _NavItem(
              label: 'Agenda',
              icon: HugeIcons.strokeRoundedCalendar01,
              activeIcon: HugeIcons.strokeRoundedCalendar03,
              screen: DentistAgendaScreen(),
            ),
            _NavItem(
              label: 'Turnos',
              icon: HugeIcons.strokeRoundedTime01,
              activeIcon: HugeIcons.strokeRoundedTime02,
              screen: DentistTurnosAgendaScreen(),
            ),
            _NavItem(
              label: 'Perfil',
              icon: HugeIcons.strokeRoundedUser,
              activeIcon: HugeIcons.strokeRoundedUserCircle,
              screen: DentistProfileScreen(),
            ),
          ],
        );
      case UserRole.doctor:
        return _RoleNavigationConfig(
          roleName: 'doctor',
          items: const [
            _NavItem(
              label: 'Home',
              icon: HugeIcons.strokeRoundedHome01,
              activeIcon: HugeIcons.strokeRoundedHome09,
              screen: DoctorHomeScreen(),
            ),
            _NavItem(
              label: 'Agenda',
              icon: HugeIcons.strokeRoundedCalendar01,
              activeIcon: HugeIcons.strokeRoundedCalendar03,
              screen: DoctorAgendaScreen(),
            ),
            _NavItem(
              label: 'Turnos',
              icon: HugeIcons.strokeRoundedTime01,
              activeIcon: HugeIcons.strokeRoundedTime02,
              screen: DoctorTurnosScreen(),
            ),
            _NavItem(
              label: 'Shop',
              icon: HugeIcons.strokeRoundedStore03,
              activeIcon: HugeIcons.strokeRoundedShopSign,
              screen: DoctorShopScreen(),
            ),
            _NavItem(
              label: 'Security',
              icon: HugeIcons.strokeRoundedShield01,
              activeIcon: HugeIcons.strokeRoundedShield02,
              screen: DoctorSecurityScreen(),
            ),
            _NavItem(
              label: 'Delivery',
              icon: HugeIcons.strokeRoundedTruck,
              activeIcon: HugeIcons.strokeRoundedTruckDelivery,
              screen: DoctorDeliveryScreen(),
            ),
            _NavItem(
              label: 'Profile',
              icon: HugeIcons.strokeRoundedUser,
              activeIcon: HugeIcons.strokeRoundedUserCircle,
              screen: DoctorProfileScreen(),
            ),
          ],
        );
      case UserRole.employee:
        return _RoleNavigationConfig(
          roleName: 'employee',
          items: const [
            _NavItem(
              label: 'Home',
              icon: HugeIcons.strokeRoundedHome01,
              activeIcon: HugeIcons.strokeRoundedHome09,
              screen: EmployeeHomeScreen(),
            ),
            _NavItem(
              label: 'Agenda',
              icon: HugeIcons.strokeRoundedCalendar01,
              activeIcon: HugeIcons.strokeRoundedCalendar03,
              screen: EmployeeAgendaScreen(),
            ),
            _NavItem(
              label: 'Turnos',
              icon: HugeIcons.strokeRoundedTime01,
              activeIcon: HugeIcons.strokeRoundedTime02,
              screen: EmployeeTurnosScreen(),
            ),
            _NavItem(
              label: 'Shop',
              icon: HugeIcons.strokeRoundedStore03,
              activeIcon: HugeIcons.strokeRoundedShopSign,
              screen: EmployeeShopScreen(),
            ),
            _NavItem(
              label: 'Security',
              icon: HugeIcons.strokeRoundedShield01,
              activeIcon: HugeIcons.strokeRoundedShield02,
              screen: EmployeeSecurityScreen(),
            ),
            _NavItem(
              label: 'Delivery',
              icon: HugeIcons.strokeRoundedTruck,
              activeIcon: HugeIcons.strokeRoundedTruckDelivery,
              screen: EmployeeDeliveryScreen(),
            ),
            _NavItem(
              label: 'Profile',
              icon: HugeIcons.strokeRoundedUser,
              activeIcon: HugeIcons.strokeRoundedUserCircle,
              screen: EmployeeProfileScreen(),
            ),
          ],
        );
      case UserRole.patient:
        return _RoleNavigationConfig(
          roleName: 'patient',
          items: const [
            _NavItem(
              label: 'Home',
              icon: HugeIcons.strokeRoundedHome01,
              activeIcon: HugeIcons.strokeRoundedHome09,
              screen: PatientHomeScreen(),
            ),
            _NavItem(
              label: 'Agenda',
              icon: HugeIcons.strokeRoundedCalendar01,
              activeIcon: HugeIcons.strokeRoundedCalendar03,
              screen: PatientAgendaScreen(),
            ),
            _NavItem(
              label: 'Shop',
              icon: HugeIcons.strokeRoundedStore03,
              activeIcon: HugeIcons.strokeRoundedShopSign,
              screen: PatientShopScreen(),
            ),
            _NavItem(
              label: 'Security',
              icon: HugeIcons.strokeRoundedShield01,
              activeIcon: HugeIcons.strokeRoundedShield02,
              screen: PatientSecurityScreen(),
            ),
            _NavItem(
              label: 'Delivery',
              icon: HugeIcons.strokeRoundedTruck,
              activeIcon: HugeIcons.strokeRoundedTruckDelivery,
              screen: PatientDeliveryScreen(),
            ),
            _NavItem(
              label: 'Profile',
              icon: HugeIcons.strokeRoundedUser,
              activeIcon: HugeIcons.strokeRoundedUserCircle,
              screen: PatientProfileScreen(),
            ),
          ],
        );
      case UserRole.delivery:
        return _RoleNavigationConfig(
          roleName: 'delivery',
          items: const [
            _NavItem(
              label: 'Home',
              icon: HugeIcons.strokeRoundedHome01,
              activeIcon: HugeIcons.strokeRoundedHome09,
              screen: DeliveryMainScreen(),
            ),
            _NavItem(
              label: 'Seguridad',
              icon: HugeIcons.strokeRoundedShield01,
              activeIcon: HugeIcons.strokeRoundedShield02,
              screen: DeliverySecurityScreen(),
            ),
            _NavItem(
              label: 'Entregas',
              icon: HugeIcons.strokeRoundedTruck,
              activeIcon: HugeIcons.strokeRoundedTruckDelivery,
              screen: DeliveryMainScreen(),
            ),
            _NavItem(
              label: 'Perfil',
              icon: HugeIcons.strokeRoundedUser,
              activeIcon: HugeIcons.strokeRoundedUserCircle,
              screen: DeliveryProfileScreen(),
            ),
          ],
        );
    }
  }

  void _onEmployeeSelected(UserModel employee) {
    setState(() {
      _selectedEmployee = employee;
    });
  }

  void _selectTab(int index, {required bool desktop}) {
    setState(() {
      _selectedIndex = index;
      if (index > _maxLoadedIndex) _maxLoadedIndex = index;
      _tabController.index = index;
    });
  }

  PreferredSizeWidget _buildDesktopAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(74),
      child: _buildDesktopTopBar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ScreenTrace(
      tag: 'BOTTOM_NAV',
      message: 'Renderizando contenedor principal de navegacion para rol $_roleName.',
      role: _roleName,
      child: Scaffold(
        appBar: isDesktop ? _buildDesktopAppBar() : null,
          body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: List.generate(_config.items.length, (i) {
                final active = i == _selectedIndex;
                // Nunca montar una pestaÃ±a no visitada: asÃ­ no se inicializan
                // sus providers ni sus streams durante el arranque.
                final child = i <= _maxLoadedIndex
                    ? _config.items[i].screen
                    : const SizedBox.shrink();
                return TickerMode(enabled: active, child: child);
              }),
            ),
            if (_showValeriaAssistant)
              const Positioned(
                bottom: 80,
                right: 20,
                child: ValeriaAssistant(),
              ),
          ],
        ),
        bottomNavigationBar: isDesktop ? null : _buildMobileBottomBar(),
      ),
    );
  }

  Widget _buildMainNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _config.items.length,
        (i) => _buildDesktopNavButton(
          item: _config.items[i],
          isActive: _tabController.index == i,
          index: i,
        ),
      ),
    );
  }
/////////////////////////////////////////////////////////////////  appBar Desktop
  Widget _buildDesktopNavButton({
    required _NavItem item,
    required bool isActive,
    required int index,
  }) {
    return InkWell(
      onTap: () => _selectTab(index, desktop: true),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Tooltip(
            message: item.label,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: isActive ? item.activeIcon : item.icon,
                  color: isActive ? AppColors.primary : AppColors.grey700,
                  size: isActive ? 30 : 20,
                  strokeWidth: isActive ? 2.2 : 1.8,
                ),
                const SizedBox(width: 7),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isActive ? AppColors.black : AppColors.grey700,
                    fontSize: 12,
                    fontFamily: isActive ? 'Ubuntu-Bold' : 'Ubuntu-Medium',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return SearchAnchor(
      searchController: _searchController,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 14),
          ),
          onTap: () => controller.openView(),
          onChanged: (_) => controller.openView(),
          leading: const Icon(Icons.search, size: 18),
          elevation: const WidgetStatePropertyAll<double>(0),
          backgroundColor: const WidgetStatePropertyAll<Color>(Color(0xFFF3F4F6)),
          hintText: 'Buscar',
          constraints: const BoxConstraints(minHeight: 38, maxHeight: 38),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final query = controller.text.toLowerCase();
        final suggestions = _allEmployees
            .where((employee) => employee.fullName.toLowerCase().contains(query))
            .toList();

        return suggestions.map(
          (item) => ListTile(
            title: Text(item.fullName),
            onTap: () {
              setState(() {
                controller.closeView(item.fullName);
                _onEmployeeSelected(item);
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktopTopBar() {
    final authProvider = Provider.of<AuthenticateProvider>(context);
    final user = authProvider.user;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.grey200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F172A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildUserBadge(user),
              const SizedBox(width: 20),
              Expanded(child: _buildMainNavigation()),
              const SizedBox(width: 16),
              SizedBox(
                width: 220,
                child: _buildModernSearchBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
//////////////////////////////////////////////////////////
  Widget _buildMobileBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),  
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x160F172A),
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(
              _config.items.length,
              (index) => Expanded(
                child: _buildMobileBottomNavigations(
                  item: _config.items[index],
                  isActive: _tabController.index == index,
                  onTap: () => _selectTab(index, desktop: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
//////////////////////////////////////////////////////////
  Widget _buildMobileBottomNavigations({
    required _NavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        //margin: const EdgeInsets.symmetric(horizontal: 4),
        //padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: isActive ? item.activeIcon : item.icon,
              size: isActive ? 30 : 28,
              color: isActive ? AppColors.primary : AppColors.grey700,
              strokeWidth: isActive ? 2.5 : 1.8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBadge(UserModel? user) {
    if (user == null) {
      return const Row(
        children: [
          /////////////////////////////////////////////////////////////////////
          CircleAvatar(radius: 50, backgroundColor: AppColors.grey100),
          SizedBox(width: 10),
          Text(
            'Cargando...',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.black,
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        CircleAvatar_Widget(
          imageUrl: user.imageUrl,
          radius: 25,
          placeholderIcon: Icons.person,
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.black,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
            Text(
              user.role.displayName,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.grey600,
                fontFamily: 'Ubuntu-Regular',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
//////////////////////////////////////////////////////////
class _RoleNavigationConfig {
  final String roleName;
  final List<_NavItem> items;

  const _RoleNavigationConfig({
    required this.roleName,
    required this.items,
  });
}
//////////////////////////////////////////////////////////
class _NavItem {
  final String label;
  final dynamic icon;
  final dynamic activeIcon;
  final Widget screen;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}
