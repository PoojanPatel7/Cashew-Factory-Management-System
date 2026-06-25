import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class MachineryDashboardPage extends StatelessWidget {
  const MachineryDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machinery Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {},
            tooltip: 'Scan Machine QR',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickAction(context, 'Machine List', Icons.precision_manufacturing, 'machine_list'),
                _buildQuickAction(context, 'Maintenance', Icons.build, 'maintenance_calendar'),
                _buildQuickAction(context, 'Spare Parts', Icons.inventory, 'spare_parts'),
                _buildQuickAction(context, 'Analytics', Icons.analytics, 'machine_analytics'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Live Status Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveGridRow(
            children: [
              _buildStatusCard(context, 'Running', '8', Colors.green),
              _buildStatusCard(context, 'Idle', '2', Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveGridRow(
            children: [
              _buildStatusCard(context, 'Maintenance', '1', Colors.orange),
              _buildStatusCard(context, 'Breakdown', '0', Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Factory Floor Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => context.goNamed('machine_list'), child: const Text('List View')),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Stack(
              children: [
                const Center(child: Text('Floor Map Rendering...', style: TextStyle(color: Colors.grey))),
                Positioned(
                  top: 50, left: 50,
                  child: _buildMapPin(context, 'Borma #1', Colors.green),
                ),
                Positioned(
                  top: 150, left: 100,
                  child: _buildMapPin(context, 'Peeling #2', Colors.orange),
                ),
                Positioned(
                  top: 80, right: 80,
                  child: _buildMapPin(context, 'Grader A', Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Alerts & Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('Peeling Machine #2'),
              subtitle: const Text('Maintenance due in 2 days (2000 hours reached)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.goNamed('schedule_maintenance'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('add_machine'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, String routeName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        onPressed: () => context.goNamed(routeName),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, String count, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                Icon(Icons.circle, color: color, size: 12),
              ],
            ),
            const SizedBox(height: 8),
            Text(count, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin(BuildContext context, String name, Color statusColor) {
    return GestureDetector(
      onTap: () => context.goNamed('machine_detail'),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2),
              ],
            ),
            child: const Icon(Icons.precision_manufacturing, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
            child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
