import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class DispatchDashboardPage extends StatelessWidget {
  const DispatchDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ResponsiveGridRow(
            children: [
              _buildStatCard(context, 'Pending', '4', Colors.orange),
              _buildStatCard(context, 'In Transit', '2', Colors.blue),
              _buildStatCard(context, 'Delivered', '18', Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Active Dispatches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDispatchCard(context, 'DSP-23-102', 'Premium Nuts Traders', 'In Transit', Colors.blue, 'MH-04-AB-1234'),
          _buildDispatchCard(context, 'DSP-23-103', 'Global Snacks Corp', 'Pending', Colors.orange, 'Unassigned'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('create_dispatch'),
        icon: const Icon(Icons.local_shipping),
        label: const Text('New Dispatch'),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchCard(BuildContext context, String dspNo, String customer, String status, Color color, String vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(dspNo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$customer\nVehicle: $vehicle'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        onTap: () => context.goNamed('dispatch_tracking'),
      ),
    );
  }
}
