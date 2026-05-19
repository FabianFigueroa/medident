import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Calls_One_Widget extends StatefulWidget {
  final List<dynamic> calls;
  final Function(dynamic)? onTap;
  final Function(dynamic)? onCallBack;
  final bool isLoading;

  const Calls_One_Widget({
    super.key,
    required this.calls,
    this.onTap,
    this.onCallBack,
    this.isLoading = false,
  });

  @override
  State<Calls_One_Widget> createState() => _Calls_One_WidgetState();
}

class _Calls_One_WidgetState extends State<Calls_One_Widget> {
  final Set<String> _callingIds = {};

  Future<void> _initiateCall(dynamic call) async {
    final callId = call['id'] ?? '';
    if (callId.isEmpty || widget.onCallBack == null) return;
    
    setState(() => _callingIds.add(callId));
    try {
      widget.onCallBack?.call(call);
    } finally {
      if (mounted) setState(() => _callingIds.remove(callId));
    }
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.videocam_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No hay llamadas',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.calls.isEmpty && !widget.isLoading) {
      return _buildEmpty();
    }

    final missedCount = widget.calls.where((c) => c['status'] == 'missed').length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Video Llamadas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (missedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$missedCount perdidas',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Calls list
            widget.isLoading
                ? _buildShimmer()
                : Column(
                    children: widget.calls.take(3).map((call) => _buildCallItem(context, call)).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallItem(BuildContext context, dynamic call) {
    final bool isMissed = call['status'] == 'missed';
    final bool isVideo = call['type'] == 'video';
    final String callerName = call['callerName'] ?? 'Usuario';
    final String? callerPhoto = call['callerPhoto'];
    final String duration = call['duration'] ?? '';
    final String time = call['time'] ?? '';
    final String callId = call['id'] ?? '';
    final bool isCalling = _callingIds.contains(callId);

    return InkWell(
      onTap: () => widget.onTap?.call(call),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isMissed ? const Color(0xFFFFF5F5) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Avatar with indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: callerPhoto != null && callerPhoto.isNotEmpty
                      ? NetworkImage(callerPhoto)
                      : null,
                  child: (callerPhoto == null || callerPhoto.isEmpty)
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isVideo ? const Color(0xFF0F766E) : const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      isVideo ? Icons.videocam : Icons.phone,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    callerName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isMissed ? FontWeight.w700 : FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        isMissed ? Icons.call_missed : Icons.call_received,
                        size: 12,
                        color: isMissed ? const Color(0xFFEF4444) : const Color(0xFF0F766E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMissed ? 'Perdida' : duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: isMissed ? const Color(0xFFEF4444) : Colors.grey[600],
                          fontWeight: isMissed ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time and call back button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: isCalling ? null : () => _initiateCall(call),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isCalling
                          ? Colors.grey[300]
                          : (isVideo ? const Color(0xFF0F766E) : const Color(0xFF3B82F6)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isCalling
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isVideo ? Icons.videocam : Icons.phone,
                            size: 16,
                            color: isVideo ? const Color(0xFF0F766E) : const Color(0xFF3B82F6),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(3, (index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
