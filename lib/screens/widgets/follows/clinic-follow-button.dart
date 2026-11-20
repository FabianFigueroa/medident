import 'package:flutter/material.dart';
import 'package:medident/core/services/clinic-follow-service.dart';

class ClinicFollowButton extends StatefulWidget {
  final String userId;
  final String clinicId;
  final Color accentColor;
  final bool compact;

  const ClinicFollowButton({
    super.key,
    required this.userId,
    required this.clinicId,
    this.accentColor = const Color(0xFF4F46E5),
    this.compact = false,
  });

  @override
  State<ClinicFollowButton> createState() => _ClinicFollowButtonState();
}

class _ClinicFollowButtonState extends State<ClinicFollowButton> {
  final ClinicFollowService _service = ClinicFollowService();
  bool _following = false;
  bool _loading = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final following = await _service.isFollowingClinic(
      userId: widget.userId,
      clinicId: widget.clinicId,
    );
    if (mounted) {
      setState(() {
        _following = following;
        _loading = false;
      });
    }
  }

  Future<void> _toggle() async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      if (_following) {
        await _service.unfollowClinic(
          userId: widget.userId,
          clinicId: widget.clinicId,
        );
        if (mounted) setState(() => _following = false);
      } else {
        await _service.followClinic(
          userId: widget.userId,
          clinicId: widget.clinicId,
        );
        if (mounted) setState(() => _following = true);
      }
    } catch (_) {}
    if (mounted) setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: widget.compact ? 32 : 40,
        width: widget.compact ? 90 : 130,
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final color = widget.accentColor;
    return SizedBox(
      height: widget.compact ? 32 : 40,
      child: ElevatedButton.icon(
        onPressed: _processing ? null : _toggle,
        icon: _processing
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(
                _following ? Icons.check : Icons.add,
                size: widget.compact ? 15 : 18,
                color: _following ? color : Colors.white,
              ),
        label: Text(
          _following ? 'Siguiendo' : 'Seguir clínica',
          style: TextStyle(
            fontSize: widget.compact ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: _following ? color : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _following ? color.withOpacity(0.12) : color,
          foregroundColor: _following ? color : Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 10 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
