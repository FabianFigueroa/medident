import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class OnboardingVideoProvider with ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isDisposed = false;
  bool _isVideoPlaying = false;
  bool _hasError = false;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isVideoPlaying => _isVideoPlaying;
  bool get hasError => _hasError;

  OnboardingVideoProvider();

  Future<void> initializeVideo() async {
    final tempController = VideoPlayerController.asset('assets/videos/onboard.mp4');

    try {
      await tempController.initialize();
      await tempController.setLooping(true);
      await tempController.setVolume(0.0);
      await tempController.play();

      _controller = tempController; // Assign only on success
      _isVideoPlaying = true;
      _hasError = false;

    } on PlatformException catch (e) {
      debugPrint('Error al inicializar el video de onboarding: $e');
      tempController.dispose();
      _controller = null;
      _isVideoPlaying = false;
      _hasError = true; // Set error flag
    } catch (e) {
      debugPrint('Error general al inicializar el video: $e');
      tempController.dispose();
      _controller = null;
      _isVideoPlaying = false;
      _hasError = true; // Set error flag
    }

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> playVideo() async {
    if (_controller != null && _controller!.value.isInitialized) {
      if (!_controller!.value.isPlaying) {
        await _controller!.play();
      }
      _isVideoPlaying = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    _controller = null;
    _isVideoPlaying = false;
    super.dispose();
  }
}
