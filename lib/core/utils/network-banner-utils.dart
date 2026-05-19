import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network/network-provider.dart';

class NetworkBannerUtils extends StatelessWidget {
  //
  const NetworkBannerUtils({super.key});
  //
  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, provider, child) {
        if (provider.isOnline) {
          return const SizedBox.shrink();
        }
        return const Align(
          alignment: Alignment.center,
          child: Material(
            color: Color.fromARGB(247, 189, 179, 179),
            child: SizedBox(
              width: 500,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color.fromARGB(255, 172, 28, 18)),
                child: Center(
                  child: Text(
                    'No tienes conexión a internet, espera mientras te reconectas!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
