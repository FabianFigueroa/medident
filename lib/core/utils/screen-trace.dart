import 'package:flutter/material.dart';
import 'package:medident/core/auth/authgate.dart';
import 'app-logger.dart';

class ScreenTrace extends StatefulWidget {
  final String tag;
  final String message;
  final String? role;
  final Widget child;

  const ScreenTrace({
    super.key,
    required this.tag,
    required this.message,
    this.role,
    required this.child,
  });

  @override
  State<ScreenTrace> createState() => _ScreenTraceState();
}

class _ScreenTraceState extends State<ScreenTrace> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppLogger.logWithRole(
          tag: widget.tag,
          message: widget.message,
          role: widget.role,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant ScreenTrace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tag != widget.tag || oldWidget.message != widget.message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppLogger.logWithRole(
            tag: widget.tag,
            message: widget.message,
            role: widget.role,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
