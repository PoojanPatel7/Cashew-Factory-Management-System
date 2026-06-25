import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaintenanceCalendarPage extends StatelessWidget {
  const MaintenanceCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Calendar')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Text(
                'Calendar Widget Placeholder\nShows days with Red/Yellow/Green dots',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Upcoming Maintenance Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildTaskCard(context, 'Peeling Machine #2', 'Condition-based Maintenance', 'In 2 days', Colors.orange),
                _buildTaskCard(context, 'Borma Dryer #1', 'Monthly Service', 'In 5 days', Colors.blue),
                _buildTaskCard(context, 'Packaging Line', 'Belt Replacement', 'Overdue by 1 day!', Colors.red),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('schedule_maintenance'),
        icon: const Icon(Icons.add),
        label: const Text('Schedule Task'),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, String machine, String type, String time, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.build, color: color),
        title: Text(machine, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$type\n$time'),
        isThreeLine: true,
        trailing: FilledButton.tonal(
          style: FilledButton.styleFrom(backgroundColor: color.withValues(alpha: 0.2), foregroundColor: color),
          onPressed: () => context.goNamed('maintenance_log'),
          child: const Text('Log'),
        ),
      ),
    );
  }
}
