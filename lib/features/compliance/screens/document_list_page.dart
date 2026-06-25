import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DocumentListPage extends StatelessWidget {
  const DocumentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Compliance Documents'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Expiring Soon'),
              Tab(text: 'Expired'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDocList(context, 'Active', Colors.green),
            _buildDocList(context, 'Expiring Soon', Colors.orange),
            _buildDocList(context, 'Expired', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDocList(BuildContext context, String filter, Color statusColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (filter == 'Active') ...[
          _buildDocCard(context, 'Pollution Control Board Consent', 'Valid till: 15-Dec-2025', 'Active', Colors.green),
          _buildDocCard(context, 'Fire NOC', 'Valid till: 10-Aug-2024', 'Active', Colors.green),
        ],
        if (filter == 'Expiring Soon') ...[
          _buildDocCard(context, 'Factory License', 'Valid till: 30-Jun-2023', 'Expiring', Colors.orange),
          _buildDocCard(context, 'FSSAI License', 'Valid till: 22-Jun-2023', 'Expiring', Colors.red),
        ],
        if (filter == 'Expired') ...[
          _buildDocCard(context, 'Labour License', 'Expired on: 01-Jan-2023', 'Expired', Colors.red),
        ],
      ],
    );
  }

  Widget _buildDocCard(BuildContext context, String title, String expiry, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(expiry),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        onTap: () => context.goNamed('document_detail'),
      ),
    );
  }
}
