import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:medident/main_export.dart';

class RegisterProvider with ChangeNotifier {
  final FirebaseServices _firebaseService;
  static bool? _adminExistsCache;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final birthDateController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final nitController = TextEditingController();

  UserRole? _selectedRole;
  UserRole? get selectedRole => _selectedRole;

  UserGender? _selectedGender;
  UserGender? get selectedGender => _selectedGender;

  DateTime? _selectedBirthDate;
  DateTime? get selectedBirthDate => _selectedBirthDate;

  Uint8List? _imageBytes;
  Uint8List? get imageBytes => _imageBytes;

  Uint8List? _defaultImageBytes;
  Uint8List? get defaultImageBytes => _defaultImageBytes;
  Uint8List? get previewImageBytes => _imageBytes ?? _defaultImageBytes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAdminRoleAvailable = false;
  bool get isAdminRoleAvailable => _isAdminRoleAvailable;

  bool _isAdminCheckLoading = true;
  bool get isAdminCheckLoading => _isAdminCheckLoading;

  bool _isLoadingCards = false;
  bool get isLoadingCards => _isLoadingCards;

  Map<String, String>? _availableCardMap;

  List<String>? get availableCards => _availableCardMap?.keys.toList();

  String? _selectedCardDisplay;
  String? get selectedCardDisplay => _selectedCardDisplay;

  String? get selectedCardCode =>
      _selectedCardDisplay != null && _availableCardMap != null
          ? _availableCardMap![_selectedCardDisplay!]
          : null;
  
  RegisterProvider(this._firebaseService) {
    checkAdminAvailability();
    _initializeDefaultImage();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    birthDateController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    nitController.dispose();
    super.dispose();
  }

  bool get isFormValid =>
      emailController.text.isNotEmpty && passwordController.text.isNotEmpty;



  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final role = await _firebaseService.signInWithGoogle();
      return role?.toString();
    } catch (e) {
      _errorMessage = 'Error de Google Sign-In en provider: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
      return 'Si el correo existe, se ha enviado el enlace de restablecimiento.';
    } catch (e) {
      return 'Error al enviar el correo: $e';
    }
  }

  Future<void> checkAdminAvailability() async {
    debugPrint('REGISTER_PROVIDER: Verificando disponibilidad del rol admin...');

    if (_adminExistsCache != null) {
      _isAdminRoleAvailable = !_adminExistsCache!;
      _isAdminCheckLoading = false;
      debugPrint(
        'REGISTER_PROVIDER: Resultado admin desde cache: ${_isAdminRoleAvailable ? 'disponible' : 'no disponible (max 2 alcanzado)'}',
      );
      notifyListeners();
      return;
    }

    try {
      final count = await _firebaseService.adminCount();
      _adminExistsCache = count >= 2;
      _isAdminRoleAvailable = count < 2;
      debugPrint('REGISTER_PROVIDER: Admins en Firestore: $count (max 2, disponible: ${_isAdminRoleAvailable})');
    } catch (e) {
      debugPrint('REGISTER_PROVIDER: Error al verificar cantidad de admins: $e');
      _isAdminRoleAvailable = true;
      _adminExistsCache = false;
      _errorMessage ??=
          'No se pudo validar la cantidad de admins. Se habilitara el rol admin temporalmente.';
    }

    if (!_isAdminRoleAvailable && _selectedRole == UserRole.admin) {
      _selectedRole = null;
    }

    _isAdminCheckLoading = false;
    notifyListeners();
  }

  void setImageBytes(Uint8List imageBytes) {
    _imageBytes = imageBytes;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _initializeDefaultImage() async {
    try {
      _defaultImageBytes = await _buildDefaultProfileImageBytes();
      notifyListeners();
    } catch (e) {
      _errorMessage ??= 'No se pudo preparar la imagen por defecto.';
      notifyListeners();
    }
  }

  Future<Uint8List> _buildDefaultProfileImageBytes() async {
    const double size = 256;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0, 0, size, size);

    final backgroundPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(rect, backgroundPaint);

    final circlePaint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawCircle(const Offset(size / 2, size / 2 - 18), 70, circlePaint);

    final shoulderPaint = Paint()..color = Colors.white.withValues(alpha: 0.28);
    final shoulderRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(48, 150, 160, 70),
      const Radius.circular(36),
    );
    canvas.drawRRect(shoulderRect, shoulderPaint);

    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 40,
        fontWeight: FontWeight.w700,
      ),
    )
      ..pushStyle(ui.TextStyle(color: Colors.white))
      ..addText('MD');

    final paragraph = paragraphBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: size));
    canvas.drawParagraph(paragraph, const Offset(0, 190));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw Exception('No se pudo convertir la imagen por defecto a bytes.');
    }
    return data.buffer.asUint8List();
  }

  Future<void> pickImageFromGallery() async {
    _errorMessage = null;
    var permissionGranted = false;

    if (kIsWeb) {
      permissionGranted = true;
    } else {
      final status = await Permission.photos.request();
      permissionGranted = status.isGranted;
      if (!permissionGranted) {
        _errorMessage = status.isPermanentlyDenied
            ? 'Permiso de galeria denegado. Habilitalo en los ajustes.'
            : 'Se necesita permiso para acceder a la galeria.';
      }
    }

    if (permissionGranted) {
      try {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 800,
        );
        if (pickedFile != null) {
          _imageBytes = await pickedFile.readAsBytes();
        }
      } catch (e) {
        _errorMessage = 'No se pudo seleccionar la imagen: ${e.toString()}';
      }
    }
    notifyListeners();
  }

  void setSelectedRole(UserRole? role) {
    if (role == UserRole.admin && !_isAdminRoleAvailable) {
      debugPrint('REGISTER_PROVIDER: Intento de seleccionar admin bloqueado (max 2 alcanzado).');
      return;
    }

    _selectedRole = role;
    debugPrint('REGISTER_PROVIDER: Rol seleccionado: ${role?.name}');

    if (role == UserRole.employee) {
      _loadEmployeeCardData();
    } else {
      _availableCardMap = null;
      _selectedCardDisplay = null;
    }
    notifyListeners();
  }

  Future<void> _loadEmployeeCardData() async {
    _isLoadingCards = true;
    _errorMessage = null;
    _availableCardMap = null;
    _selectedCardDisplay = null;
    notifyListeners();

    final nit = nitController.text.trim();
    if (nit.isEmpty) {
      _errorMessage = 'El NIT de la tienda es requerido para asignar una tarjeta.';
      _isLoadingCards = false;
      notifyListeners();
      return;
    }

    try {
      final realCodes = await _firebaseService.getFreeCardCodesForStore(nit);
      if (realCodes.isEmpty) {
        _errorMessage = "No se encontraron tarjetas libres para el NIT '$nit'.";
      } else {
        _availableCardMap = {};
        for (int i = 0; i < realCodes.length; i++) {
          _availableCardMap!['Tarjeta ${i + 1}'] = realCodes[i];
        }
      }
    } catch (e) {
      _errorMessage = 'Error al cargar tarjetas: $e';
    } finally {
      _isLoadingCards = false;
      notifyListeners();
    }
  }

  void setSelectedCardCode(String? displayName) {
    _selectedCardDisplay = displayName;
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedGender(UserGender? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setSelectedBirthDate(DateTime date) {
    _selectedBirthDate = date;
    birthDateController.text = '${date.toLocal()}'.split(' ')[0];
    notifyListeners();
  }

  Future<bool> register() async {
    debugPrint('REGISTER_PROVIDER: Inicio de registro para ${emailController.text.trim()}');

    if (passwordController.text != confirmPasswordController.text) {
      _errorMessage = 'Las contraseñas no coinciden.';
      debugPrint('REGISTER_PROVIDER: Registro cancelado, contraseñas no coinciden.');
      notifyListeners();
      return false;
    }

    if (_selectedBirthDate == null || _selectedGender == null || _selectedRole == null) {
      _errorMessage = 'Llena todos los campos.';
      debugPrint('REGISTER_PROVIDER: Registro cancelado, faltan campos obligatorios.');
      notifyListeners();
      return false;
    }

    if (_selectedRole == UserRole.employee) {
      if (nitController.text.trim().isEmpty) {
        _errorMessage = 'El NIT de la tienda es obligatorio.';
        debugPrint('REGISTER_PROVIDER: Registro cancelado, falta NIT para empleado.');
        notifyListeners();
        return false;
      }
      if (selectedCardCode == null) {
        _errorMessage = 'Debes seleccionar una tarjeta libre.';
        debugPrint('REGISTER_PROVIDER: Registro cancelado, falta tarjeta para empleado.');
        notifyListeners();
        return false;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final finalImageBytes = previewImageBytes;
      if (finalImageBytes == null) {
        throw Exception('Error interno: No se pudo preparar la imagen por defecto.');
      }

      final newUserModel = UserModel(
        uid: '',
        email: emailController.text.trim(),
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        role: _selectedRole!,
        birthDate: _selectedBirthDate!,
        gender: _selectedGender!,
        imageUrl: '',
      );

      final finalUserModel = await _firebaseService.createUserWithEmailAndPassword(
        email: newUserModel.email,
        password: passwordController.text,
      );
      debugPrint(
        'REGISTER_PROVIDER: Usuario creado en Auth/Firestore con uid ${finalUserModel.user?.uid}',
      );

      final uid = finalUserModel.user!.uid;
      final userModelWithUid = newUserModel.copyWith(uid: uid);
      await _firebaseService.firestore
          .collection('users')
          .doc(uid)
          .set(userModelWithUid.toMap());
      debugPrint('REGISTER_PROVIDER: Perfil guardado en Firestore para uid $uid');

      if (_selectedRole == UserRole.employee &&
          selectedCardCode != null &&
          nitController.text.isNotEmpty) {
        await _firebaseService.assignCardToEmployee(
          storeNit: nitController.text.trim(),
          employeeUid: finalUserModel.user!.uid,
          cardCode: selectedCardCode!,
        );
        debugPrint(
          'REGISTER_PROVIDER: Tarjeta asignada al empleado ${finalUserModel.user?.uid}',
        );
      }

      debugPrint('REGISTER_PROVIDER: Registro finalizado con exito. Usuario queda logueado.');
      return true;
    } catch (e) {
      debugPrint('REGISTER_PROVIDER: Registro fallo con error: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
