import 'package:flutter/material.dart';

class SecurityDashboardPage extends StatelessWidget {
  const SecurityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security & Audit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Encrypt Engine Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: const ListTile(
              leading: Icon(Icons.security, color: Colors.green, size: 36),
              title: Text('System is Secure', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              subtitle: Text('AES-256 GCM Encryption Active. Key rotation performed 12 days ago.'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Active Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSessionItem(context, 'Poojan Patel (Owner)', 'Windows PC • Chrome', 'IP: 192.168.1.100', true),
          _buildSessionItem(context, 'Ramesh (Supervisor)', 'Android Phone • App', 'IP: 192.168.1.105', false),
          const SizedBox(height: 24),
          const Text('Security Audit Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAuditLogItem(context, 'Failed Login Attempt', 'User: admin@cashewpro.app', '10 mins ago', Colors.red),
          _buildAuditLogItem(context, 'Database Backup Created', 'User: Poojan Patel', '1 hour ago', Colors.blue),
          _buildAuditLogItem(context, 'Role Permissions Updated', 'User: Poojan Patel (changed Accountant)', 'Yesterday', Colors.orange),
          _buildAuditLogItem(context, 'Encrypt Engine Key Rotation', 'System Auto-Task', '12 days ago', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSessionItem(BuildContext context, String user, String device, String ip, bool isCurrent) {
    return Card(
      child: ListTile(
        leading: Icon(isCurrent ? Icons.computer : Icons.phone_android, color: Colors.blue),
        title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$device\n$ip'),
        isThreeLine: true,
        trailing: isCurrent
            ? const Chip(label: Text('Current', style: TextStyle(fontSize: 10)), backgroundColor: Colors.transparent)
            : IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                tooltip: 'Force Logout',
                onPressed: () {},
              ),
      ),
    );
  }

  Widget _buildAuditLogItem(BuildContext context, String action, String details, String time, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.circle, color: color, size: 12),
        ),
        title: Text(action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(details, style: const TextStyle(fontSize: 12)),
        trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
