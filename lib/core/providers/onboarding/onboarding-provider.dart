import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../authgate/authgate-provider.dart';
import 'onboarding-video-provider.dart';

class OnboardingProvider with ChangeNotifier {
  late PageController _pageController;
  int _pageIndex = 0;
  PageController get pageController => _pageController;
  int get pageIndex => _pageIndex;

  OnboardingProvider() {
    _pageController = PageController(initialPage: 0);
  }

  void onPageChanged(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
    );
  }

  void previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
    );
  }

  Future<void> completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboard_completed', true);
    if (!context.mounted) return;
    final videoProvider = Provider.of<OnboardingVideoProvider>(
      context,
      listen: false,
    );
    videoProvider.controller?.pause();
    Provider.of<AuthGateProvider>(context, listen: false).completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
