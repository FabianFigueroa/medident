import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/services/dentist/dentist-home-services.dart';

class FollowButton extends StatefulWidget {
  final String currentUserId;
  final String targetUserId;

  const FollowButton({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final DentistHomeService _service = DentistHomeService();
  String _status = 'loading';
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    if (widget.currentUserId == widget.targetUserId) {
      if (mounted) setState(() => _status = 'own');
      return;
    }
    final status = await _service.checkFollowStatus(widget.currentUserId, widget.targetUserId);
    if (mounted) setState(() => _status = status);
  }

  Future<void> _toggle() async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      if (_status == 'accepted' || _status == 'pending') {
        await _service.unfollowUser(widget.currentUserId, widget.targetUserId);
        if (mounted) setState(() => _status = 'none');
      } else {
        await _service.followUser(widget.currentUserId, widget.targetUserId);
        if (mounted) setState(() => _status = 'pending');
      }
    } catch (_) {}

    if (mounted) setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_status == 'loading' || _status == 'own') return const SizedBox.shrink();

    final bool isPending = _status == 'pending';
    final bool isFollowing = _status == 'accepted';

    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: _processing ? null : _toggle,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.grey.shade300 : isPending ? Colors.orange.shade100 : Colors.blue,
          foregroundColor: isFollowing ? Colors.black87 : isPending ? Colors.orange.shade900 : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _processing
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(
                isFollowing ? 'Siguiendo' : isPending ? 'Solicitado' : 'Seguir',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
