import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/delivery/delivery-provider.dart';
import 'package:medident/screens/role/dentist/delivery/dentist_delivery_active.dart';
import 'package:medident/screens/role/dentist/delivery/dentist_delivery_inactive.dart';

class DentistDeliveryDesktop extends StatelessWidget {
  final ScrollController scrollController;
  const DentistDeliveryDesktop({
    super.key,
    required this.scrollController,
  });

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
