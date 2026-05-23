import 'package:flutter/material.dart';
import 'package:medident/core/providers/delivery/delivery-provider.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/core/utils/screen-trace.dart';
import 'package:medident/screens/role/dentist/delivery/dentist-delivery-mobile.dart';
import 'package:medident/screens/role/dentist/delivery/dentist-delivery-tablet.dart';
import 'package:medident/screens/role/dentist/delivery/dentist-delivery-desktop.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DentistDeliveryScreen extends StatefulWidget {
  const DentistDeliveryScreen({super.key});

  @override
  State<DentistDeliveryScreen> createState() => _DentistDeliveryScreenState();
}

class _DentistDeliveryScreenState extends State<DentistDeliveryScreen> {
  DeliveryProvider? _deliveryProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<DentistMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty) return;
    if (_deliveryProvider != null) return;

    _deliveryProvider = DeliveryProvider(userId: userId);
  }

  @override
  void dispose() {
    _deliveryProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_deliveryProvider == null) {
      return Scaffold(
        body: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: List.generate(5, (_) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _deliveryProvider,
      child: ResponsiveUtils(
        mobile: DentistDeliveryMobile(),
        tablet: DentistDeliveryTablet(scrollController: ScrollController()),
        desktop: DentistDeliveryDesktop(scrollController: ScrollController()),
      ),
    );
  }
}
