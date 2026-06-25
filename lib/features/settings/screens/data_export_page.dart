import 'package:flutter/material.dart';

class DataExportPage extends StatelessWidget {
  const DataExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select Module to Export', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildExportTile(context, 'Full System Backup', 'Export all tables (Excel)', Icons.dns, Colors.purple),
          _buildExportTile(context, 'Inventory Records', 'Current stock and history', Icons.inventory, Colors.blue),
          _buildExportTile(context, 'Production Data', 'Lot processing and yield', Icons.precision_manufacturing, Colors.green),
          _buildExportTile(context, 'Financial Records', 'Expenses, invoices, ledger', Icons.account_balance, Colors.orange),
          _buildExportTile(context, 'Employee Data', 'Attendance and payroll', Icons.people, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildExportTile(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.download),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Export'),
              content: Text('Export $title data as Excel (.xlsx)?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title exported successfully to Downloads.')));
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Export'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
