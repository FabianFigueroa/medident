import 'package:flutter/material.dart';

/// Base class for role-specific main providers.
///
/// Manages lazy creation, loading states, errors, and disposal of
/// section sub-providers. Each role extends this and implements
/// [createSectionProvider] to define section-specific logic.
abstract class MainProviderBase extends ChangeNotifier {
  final String userId;

  MainProviderBase(this.userId);

  final Map<String, ChangeNotifier?> _providers = {};
  final Map<String, bool> _sectionLoading = {};
  final Map<String, String?> _sectionErrors = {};

  /// Creates and initializes the provider for the given [section].
  /// Called by [initializeSection] when the section has not been loaded yet.
  Future<ChangeNotifier> createSectionProvider(String section);

  bool isSectionLoading(String section) => _sectionLoading[section] ?? false;
  String? getSectionError(String section) => _sectionErrors[section];
  ChangeNotifier? getProvider(String section) => _providers[section];
  T? getTypedProvider<T extends ChangeNotifier>(String section) =>
      _providers[section] as T?;

  /// Registers a provider directly without going through [initializeSection].
  /// Useful when data is available from cache and Firestore reads can be skipped.
  void registerSectionProvider(String section, ChangeNotifier provider) {
    _providers[section] = provider;
    _sectionLoading[section] = false;
    _sectionErrors[section] = null;
    notifyListeners();
  }

  bool get hasAnySectionLoaded => _providers.values.any((p) => p != null);

  /// Lazy-loads a section: creates the provider and initializes its data.
  Future<void> initializeSection(String section) async {
    if (_providers[section] != null) return;
    if (_sectionLoading[section] == true) return;

    if (userId.isEmpty) {
      _sectionErrors[section] = 'UserId vacío';
      notifyListeners();
      return;
    }

    _sectionLoading[section] = true;
    _sectionErrors[section] = null;
    notifyListeners();

    try {
      final provider = await createSectionProvider(section);
      _providers[section] = provider;
    } catch (e) {
      _sectionErrors[section] = 'Error al cargar sección $section: $e';
    } finally {
      _sectionLoading[section] = false;
      notifyListeners();
    }
  }

  /// Disposes and removes a specific section provider.
  void clearSection(String section) {
    _providers[section]?.dispose();
    _providers.remove(section);
    _sectionLoading.remove(section);
    _sectionErrors.remove(section);
    notifyListeners();
  }

  /// Disposes and removes all section providers.
  void clearAllSections() {
    for (final key in _providers.keys.toList()) {
      clearSection(key);
    }
  }

  @override
  void dispose() {
    for (final provider in _providers.values) {
      provider?.dispose();
    }
    _providers.clear();
    _sectionLoading.clear();
    _sectionErrors.clear();
    super.dispose();
  }
}
