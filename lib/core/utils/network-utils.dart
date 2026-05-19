import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network/network-provider.dart';

class NetworkUtils extends StatefulWidget {
  final Widget child;
  const NetworkUtils({super.key, required this.child});

  @override
  State<NetworkUtils> createState() => _NetworkUtilsState();
}

class _NetworkUtilsState extends State<NetworkUtils> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        if (networkProvider.isOnline) {
          return widget.child;
        }

        return AbsorbPointer(
          absorbing: true,
          child: Stack(
            children: [
              widget.child,
              const Center(
                child: Material(
                  color: Colors.black87,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.amber, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Sin Conexión',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'La aplicación requiere conexión a Internet para funcionar. Por favor, verifique su red.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Intentando reconectar...',
                          style: TextStyle(color: Colors.amber, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
