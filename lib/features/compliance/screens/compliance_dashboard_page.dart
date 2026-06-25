import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class ComplianceDashboardPage extends StatelessWidget {
  const ComplianceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compliance Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Health Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ActionChip(
                avatar: const Icon(Icons.folder, size: 16),
                label: const Text('View All Docs'),
                onPressed: () => context.goNamed('document_list'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Text('95%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green)),
                    Text('of documents are valid and active', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Action Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 16),
          _buildAlertCard(context, 'FSSAI License', 'Expires in 7 Days (22-Jun-2023)', Colors.red),
          _buildAlertCard(context, 'Factory License', 'Expires in 15 Days (30-Jun-2023)', Colors.orange),
          const SizedBox(height: 24),
          const Text('Upcoming Renewals (Calendar)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Calendar Widget Placeholder\n(Dots indicate expiry dates)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('add_document'),
        icon: const Icon(Icons.add_moderator),
        label: const Text('Add Document'),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, String docName, String alert, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.warning, color: color),
        title: Text(docName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(alert, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        trailing: FilledButton.tonal(
          style: FilledButton.styleFrom(backgroundColor: color.withValues(alpha: 0.2), foregroundColor: color),
          onPressed: () => context.goNamed('document_detail'),
          child: const Text('Renew'),
        ),
      ),
    );
  }
}
