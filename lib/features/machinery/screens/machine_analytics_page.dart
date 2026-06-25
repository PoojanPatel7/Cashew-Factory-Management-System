import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class MachineAnalyticsPage extends StatelessWidget {
  const MachineAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Machine Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Factory Uptime & Efficiency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveGridRow(
            children: [
              _buildMetricCard(context, 'Average Uptime', '94%', Colors.green),
              _buildMetricCard(context, 'Overall OEE', '82%', Colors.blue),
              _buildMetricCard(context, 'Maint. Cost / kg', '₹ 1.25', Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Energy Consumption vs Output', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Energy vs Output Line Chart', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Machine Leaderboard (Efficiency %)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildLeaderboardRow('1', 'Borma Dryer #1', '98%', Colors.green),
          _buildLeaderboardRow('2', 'Grader A', '95%', Colors.green),
          _buildLeaderboardRow('3', 'Shelling Line B', '88%', Colors.orange),
          _buildLeaderboardRow('4', 'Peeling Machine #2', '75%', Colors.red),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export Analytics Report'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(String rank, String machine, String efficiency, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(rank, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(machine, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(efficiency, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      ),
    );
  }
}
