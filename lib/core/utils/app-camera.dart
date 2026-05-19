import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AppCameraScreen extends StatefulWidget {
  const AppCameraScreen({super.key});

  @override
  State<AppCameraScreen> createState() => _AppCameraScreenState();
}

class _AppCameraScreenState extends State<AppCameraScreen> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 0; // 0 for back, 1 for front
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera({int cameraIndex = 0}) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (!mounted) return;
        _showErrorDialog('No se encontraron cámaras disponibles.');
        return;
      }
      // Asegurarse que el índice es válido
      _selectedCameraIndex = cameraIndex < _cameras.length ? cameraIndex : 0;

      final newController = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false, // El audio no es necesario para fotos de perfil
      );

      await newController.initialize();

      if (!mounted) return;
      setState(() {
        _controller = newController;
        _isInitializing = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al inicializar la cámara: ${e.description}');
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Ocurrió un error inesperado: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de Cámara'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Aceptar'))],
      ),
    ).then((_) => Navigator.of(context).pop()); // Cierra la pantalla de la cámara si hay error
  }

  Future<void> _onTakePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      // Devuelve los bytes de la imagen a la pantalla anterior
      Navigator.of(context).pop(bytes);
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar la foto: ${e.description}')),
      );
    }
  }

  void _onSwitchCamera() {
    if (_cameras.length < 2) return; // No se puede cambiar si hay menos de 2 cámaras

    // Cambia al siguiente índice de cámara, volviendo a 0 si llega al final
    final newIndex = (_selectedCameraIndex + 1) % _cameras.length;

    // Reinicia la cámara con la nueva selección
    setState(() { _isInitializing = true; });
    _initializeCamera(cameraIndex: newIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
        alignment: Alignment.center,
        children: [
          // Visor de la cámara que ocupa toda la pantalla
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          // Botón para volver atrás
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Controles en la parte inferior
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 64), // Espaciador para centrar el botón de captura
                // Botón para tomar la foto
                GestureDetector(
                  onTap: _onTakePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 3),
                    ),
                  ),
                ),
                // Botón para cambiar de cámara
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 30),
                  onPressed: _onSwitchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
