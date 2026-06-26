import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/theme_provider.dart';
import '../../core/network/api_client.dart';
import '../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isResetting = false;

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text('This will permanently delete all factory, stock, and processing data. Your user account will be kept. This action CANNOT be undone!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isResetting = true);
      try {
        final db = FirebaseFirestore.instance;
        final collections = ['raw_stocks', 'lots', 'processing_steps', 'finished_stock', 'activity_logs', 'factories'];
        
        for (final collection in collections) {
          final snapshot = await db.collection(collection).get();
          for (final doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }
        
        await ApiClient().setFactoryId('');
        
        // Remove factoryId from all users
        final users = await db.collection('users').get();
        for (final doc in users.docs) {
          await doc.reference.update({'factoryId': null});
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data reset successfully.'), backgroundColor: Colors.green));
          context.go('/home'); // will redirect to factory setup
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reset: $e'), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isResetting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Appearance', style: theme.textTheme.titleMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  secondary: const Icon(Icons.light_mode_rounded, color: Colors.orange),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (m) => ref.read(themeProvider.notifier).setTheme(m!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.dark_mode_rounded, color: Colors.indigo),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (m) => ref.read(themeProvider.notifier).setTheme(m!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  secondary: const Icon(Icons.brightness_auto_rounded),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (m) => ref.read(themeProvider.notifier).setTheme(m!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Help & Support', style: theme.textTheme.titleMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: Colors.green),
              title: const Text('App Guide / About Us'),
              subtitle: const Text('Learn how to use HM Nuts'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/guide'),
            ),
          ),
          const SizedBox(height: 32),
          Text('Danger Zone', style: theme.textTheme.titleMedium?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            color: Colors.red.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: _isResetting 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                  : const Icon(Icons.delete_forever_rounded, color: Colors.red),
              title: const Text('Reset All Factory Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: Text('Delete all factories, stock, and logs for testing purposes.', style: TextStyle(color: Colors.red.shade300)),
              onTap: _isResetting ? null : _resetData,
            ),
          ),
        ],
      ),
    );
  }
}
