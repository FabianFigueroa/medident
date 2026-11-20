import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/delivery/delivery-provider.dart';
import 'package:medident/core/providers/delivery/delivery-profile-provider.dart';

class DeliveryMainProvider extends MainProviderBase {
  DeliveryMainProvider(super.userId) {
    initializeSection('home');
  }

  DeliveryProvider? get homeProvider =>
      getTypedProvider<DeliveryProvider>('home');

  DeliveryProfileProvider? get profileProvider =>
      getTypedProvider<DeliveryProfileProvider>('profile');

  DeliveryProfileProvider? get securityProvider =>
      getTypedProvider<DeliveryProfileProvider>('security');

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        return DeliveryProvider(userId: userId);

      case 'profile':
        final provider = DeliveryProfileProvider(userId: userId);
        await provider.initialize();
        return provider;

      case 'security':
        final provider = DeliveryProfileProvider(userId: userId);
        await provider.initialize();
        return provider;

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}
