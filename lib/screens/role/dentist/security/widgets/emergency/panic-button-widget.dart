import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

/// Botón de pánico flotante (siempre visible)
class PanicButtonWidget extends StatefulWidget {
  final Function()? onPanic;

  const PanicButtonWidget({super.key, this.onPanic});

  @override
  State<PanicButtonWidget> createState() => _PanicButtonWidgetState();
}

class _PanicButtonWidgetState extends State<PanicButtonWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _triggerPanic();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: _isPressed ? 70 : 80,
        height: _isPressed ? 70 : 80,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.red[700] : Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: _isPressed ? 10 : 5,
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.warning,
              color: Colors.white,
              size: 32,
            ),
            Text(
              'PÁNICO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerPanic() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡CONFIRMAR PÁNICO!'),
        content: const Text(
          '¿Está seguro de activar la alerta de emergencia?\n\n'
          'Se notificará a todos los contactos y se capturarán fotos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.onPanic?.call();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Alerta de pánico activada!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('ACTIVAR'),
          ),
        ],
      ),
    );
  }
}
