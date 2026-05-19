import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TrackingScrollController _scrollController = TrackingScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_VISITOR_HOME',
      message: 'Entrando al home general sin rol autenticado. Cargando panel base.',
      role: 'guest',
      child: ResponsiveUtils(
      mobile: HomeScreenMobile(),  //scrollController: _scrollController
      tablet: HomeScreenMobile(),
      desktop: HomeScreenMobile(),
    ),
    );
  }
}
