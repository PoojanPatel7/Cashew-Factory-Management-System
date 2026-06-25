import 'package:flutter/material.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notification Center'),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All marked as read')));
              },
              child: const Text('Mark All Read'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Unread (3)'),
              Tab(text: 'Alerts'),
              Tab(text: 'Approvals'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationList(context, 'All'),
            _buildNotificationList(context, 'Unread'),
            _buildNotificationList(context, 'Alerts'),
            _buildNotificationList(context, 'Approvals'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, String filter) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (filter == 'All' || filter == 'Unread' || filter == 'Alerts')
          _buildNotificationItem(
            context,
            icon: Icons.warning,
            color: Colors.red,
            title: 'Critical: Machine Breakdown',
            message: 'Peeling Machine #2 reported breakdown by Operator Ramesh.',
            time: '10 mins ago',
            isUnread: true,
          ),
        if (filter == 'All' || filter == 'Unread' || filter == 'Approvals')
          _buildNotificationItem(
            context,
            icon: Icons.pending_actions,
            color: Colors.orange,
            title: 'Approval Needed: Expense',
            message: 'New expense report of ₹ 12,000 submitted by Logistics Team.',
            time: '1 hour ago',
            isUnread: true,
          ),
        if (filter == 'All' || filter == 'Alerts')
          _buildNotificationItem(
            context,
            icon: Icons.inventory,
            color: Colors.blue,
            title: 'Low Stock Alert',
            message: 'Packaging Tins stock is below minimum threshold (45 remaining).',
            time: '3 hours ago',
            isUnread: false,
          ),
        if (filter == 'All')
          _buildNotificationItem(
            context,
            icon: Icons.check_circle,
            color: Colors.green,
            title: 'Lot Completed',
            message: 'Lot-2026-015 successfully completed Grading stage.',
            time: 'Yesterday, 4:30 PM',
            isUnread: false,
          ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Card(
      color: isUnread ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      elevation: isUnread ? 2 : 1,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
        title: Text(title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),
            const SizedBox(height: 8),
            Text(time, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
          ],
        ),
        isThreeLine: true,
        onTap: () {},
      ),
    );
  }
}
