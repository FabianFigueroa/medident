import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class Messages_One_Widget extends StatefulWidget {
  final List<dynamic> messages;
  final Function(dynamic)? onTap;
  final Function(dynamic)? onMarkRead;
  final Function(dynamic, String)? onReply;
  final bool isLoading;

  const Messages_One_Widget({
    super.key,
    required this.messages,
    this.onTap,
    this.onMarkRead,
    this.onReply,
    this.isLoading = false,
  });

  @override
  State<Messages_One_Widget> createState() => _Messages_One_WidgetState();
}

class _Messages_One_WidgetState extends State<Messages_One_Widget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  List<dynamic> _filteredMessages = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredMessages = widget.messages;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant Messages_One_Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _filteredMessages = _isSearching
          ? _filterMessages(_searchController.text)
          : widget.messages;
    }
  }

  List<dynamic> _filterMessages(String query) {
    if (query.isEmpty) return widget.messages;
    final q = query.toLowerCase();
    return widget.messages.where((m) {
      final senderName = (m['senderName'] ?? '').toString().toLowerCase();
      final content = (m['content'] ?? '').toString().toLowerCase();
      return senderName.contains(q) || content.contains(q);
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _filteredMessages = _filterMessages(_searchController.text);
    });
  }

  Future<void> _showReplyDialog(dynamic msg) async {
    _replyController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Responder a ${msg['senderName'] ?? 'usuario'}'),
        content: TextField(
          controller: _replyController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe tu respuesta...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_replyController.text.trim().isNotEmpty) {
                widget.onReply?.call(msg, _replyController.text.trim());
                Navigator.pop(context, true);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respuesta enviada'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replyController.dispose();
    super.dispose();
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
          Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No hay mensajes',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty && !widget.isLoading) {
      return _buildEmpty();
    }

    final unreadCount = widget.messages.where((m) => m['isRead'] == false).length;

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
            // Header with search
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Mensajes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (!_isSearching)
                  GestureDetector(
                    onTap: () => setState(() => _isSearching = true),
                    child: const Icon(Icons.search, size: 20, color: Color(0xFF22C55E)),
                  ),
                if (_isSearching) ...[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _isSearching = false);
                    },
                    child: const Icon(Icons.close, size: 18),
                  ),
                ] else if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$unreadCount nuevos',
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

            // Messages list
            widget.isLoading
                ? _buildShimmer()
                : Column(
                    children: _filteredMessages.take(3).map((msg) => _buildMessageItem(context, msg)).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, dynamic msg) {
    final bool isRead = msg['isRead'] ?? true;
    final String senderName = msg['senderName'] ?? 'Usuario';
    final String content = msg['content'] ?? '';
    final String time = msg['time'] ?? '';
    final String? senderPhoto = msg['senderPhoto'];

    return InkWell(
      onTap: () {
        widget.onTap?.call(msg);
        if (!isRead && widget.onMarkRead != null) {
          widget.onMarkRead?.call(msg);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isRead ? const Color(0xFFF8FAFC) : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: senderPhoto != null && senderPhoto.isNotEmpty
                      ? NetworkImage(senderPhoto)
                      : null,
                  child: (senderPhoto == null || senderPhoto.isEmpty)
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
                ),
                if (!isRead)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          senderName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 12,
                      color: isRead ? Colors.grey[600] : const Color(0xFF0F172A),
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isRead)
                  GestureDetector(
                    onTap: () => widget.onMarkRead?.call(msg),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.mark_email_read, size: 16),
                    ),
                  ),
                if (!isRead && widget.onReply != null)
                  const SizedBox(width: 6),
                if (widget.onReply != null)
                  GestureDetector(
                    onTap: () => _showReplyDialog(msg),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.reply, size: 16),
                    ),
                  ),
                if (isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
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
                      width: double.infinity,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
