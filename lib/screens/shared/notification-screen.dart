import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, p, __) => p.unreadCount > 0
                ? TextButton(
                    onPressed: () => p.markAllAsRead(),
                    child: const Text('Marcar leídas'),
                  )
                : const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Solicitudes'),
            Tab(text: 'No leídas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotificationList(filter: 'all'),
          _NotificationList(filter: 'follow_request'),
          _NotificationList(filter: 'unread'),
        ],
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final String filter;
  const _NotificationList({required this.filter});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = _filtered(provider.notifications);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: notifications.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay notificaciones',
                            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: notifications.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                return _NotificationCard(notification: notifications[index]);
              },
            ),
    );
  }

  List<NotificationModel> _filtered(List<NotificationModel> all) {
    switch (filter) {
      case 'follow_request':
        return all.where((n) => n.type == 'follow_request').toList();
      case 'unread':
        return all.where((n) => !n.isRead).toList();
      default:
        return all;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    if (notification.type == 'follow_request') {
      return _FollowRequestCard(notification: notification);
    }
    return _SimpleNotificationCard(notification: notification);
  }
}

class _FollowRequestCard extends StatelessWidget {
  final NotificationModel notification;
  const _FollowRequestCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: !notification.isRead
            ? const Border(left: BorderSide(color: Colors.blue, width: 4))
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: (notification.fromUserPhoto != null && notification.fromUserPhoto!.isNotEmpty)
                  ? NetworkImage(notification.fromUserPhoto!)
                  : null,
              child: (notification.fromUserPhoto == null || notification.fromUserPhoto!.isEmpty)
                  ? Text(notification.fromUserName.isNotEmpty
                      ? notification.fromUserName[0].toUpperCase()
                      : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(text: notification.fromUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' quiere seguirte'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(_formatTimestamp(notification.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _accept(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.check, color: Colors.green, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _reject(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, color: Colors.red, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    try {
      await context.read<NotificationProvider>().acceptFollowRequest(notification.fromUserId, notification.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud aceptada'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {}
  }

  Future<void> _reject(BuildContext context) async {
    try {
      await context.read<NotificationProvider>().rejectFollowRequest(notification.fromUserId, notification.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud rechazada'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {}
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SimpleNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _SimpleNotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    switch (notification.type) {
      case 'follow_accepted':
        icon = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case 'new_post':
        icon = Icons.article;
        iconColor = Colors.teal;
        break;
      case 'new_promotion':
        icon = Icons.card_giftcard;
        iconColor = Colors.amber;
        break;
      case 'appointment':
        icon = Icons.calendar_today;
        iconColor = Colors.teal;
        break;
      case 'system':
        icon = Icons.info;
        iconColor = Colors.grey;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.blueGrey;
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationProvider>().markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: !notification.isRead
              ? const Border(left: BorderSide(color: Colors.blue, width: 4))
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(notification.title,
              style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
          subtitle: notification.body.isNotEmpty
              ? Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis)
              : null,
          trailing: Text(_formatTimestamp(notification.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}
