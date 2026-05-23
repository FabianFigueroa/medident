import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/delivery/delivery-provider.dart';

class DeliveryMainProvider extends MainProviderBase {
  DeliveryMainProvider(super.userId) {
    initializeSection('home');
  }

  DeliveryProvider? get homeProvider =>
      getTypedProvider<DeliveryProvider>('home');

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        return DeliveryProvider(userId: userId);

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}
