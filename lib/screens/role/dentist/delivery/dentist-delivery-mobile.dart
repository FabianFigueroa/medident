import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/delivery/delivery-provider.dart';
import 'package:medident/screens/role/dentist/delivery/dentist_delivery_active.dart';
import 'package:medident/screens/role/dentist/delivery/dentist_delivery_inactive.dart';

class DentistDeliveryMobile extends StatelessWidget {
  const DentistDeliveryMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
        if (provider.isServiceActive) {
          return const DeliveryActiveScreen();
        } else {
          return const DeliveryInactiveScreen();
        }
      },
    );
  }
}
