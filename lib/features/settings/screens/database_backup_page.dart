import 'package:flutter/material.dart';

class DatabaseBackupPage extends StatelessWidget {
  const DatabaseBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text('Secure Offline Backup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Create an encrypted snapshot of the entire local SQLite database. This backup can be used to restore data if the device is lost.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Create Full Backup?'),
                          content: const Text('This will take a few moments and save a secure .db backup file to your device.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup created successfully.')));
                              },
                              child: const Text('Start Backup'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.backup),
                    label: const Text('Create New Backup'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Recent Backups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildBackupItem(context, 'Backup_2026-06-25_1000.db', '25 Jun 2026, 10:00 AM', '4.2 MB'),
          _buildBackupItem(context, 'Backup_2026-06-24_1800.db', '24 Jun 2026, 06:00 PM', '4.1 MB'),
          _buildBackupItem(context, 'Backup_2026-06-23_1800.db', '23 Jun 2026, 06:00 PM', '3.9 MB'),
        ],
      ),
    );
  }

  Widget _buildBackupItem(BuildContext context, String filename, String time, String size) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(Icons.storage, color: Colors.grey),
        ),
        title: Text(filename, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('$time  •  $size'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.share, color: Colors.blue), onPressed: () {}, tooltip: 'Share'),
            IconButton(icon: const Icon(Icons.restore, color: Colors.orange), onPressed: () {}, tooltip: 'Restore'),
          ],
        ),
      ),
    );
  }
}
