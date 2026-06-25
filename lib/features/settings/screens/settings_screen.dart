import 'package:flutter/material.dart';
import 'theme_settings_page.dart';
import 'user_management_page.dart';
import 'grade_master_page.dart';
import 'language_settings_page.dart';
import 'data_export_page.dart';
import 'database_backup_page.dart';

/// Settings screen — each section navigates to its own dedicated page
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Manage your factory configuration', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),

          _sectionLabel(theme, 'General'),
          _tile(context, theme, Icons.factory_outlined, 'Factory Profile',
              'Name, address, GSTIN, FSSAI, logo', () {}),
          _tile(context, theme, Icons.people_outline, 'User Management',
              'Add users, assign roles & permissions', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()));
          }),
          _tile(context, theme, Icons.shield_outlined, 'Roles & Permissions',
              'Configure what each role can access', () {}),

          const SizedBox(height: 20),
          _sectionLabel(theme, 'Configuration'),
          _tile(context, theme, Icons.grade_rounded, 'Grade Master',
              'Cashew grades, market prices, count ranges', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GradeMasterPage()));
          }),
          _tile(context, theme, Icons.linear_scale_rounded, 'Processing Stages',
              'Configure & reorder the 12 processing steps', () {}),
          _tile(context, theme, Icons.receipt_long_outlined, 'Tax Configuration',
              'GST rates, HSN codes, invoice numbering', () {}),

          const SizedBox(height: 20),
          _sectionLabel(theme, 'Appearance'),
          _tile(context, theme, Icons.palette_outlined, 'Theme',
              'Switch between 5 built-in themes', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeSettingsPage()));
          }, trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('5 themes', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
          )),
          _tile(context, theme, Icons.language_rounded, 'Language',
              'English, हिंदी, ગુજરાતી', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageSettingsPage()));
          }),

          const SizedBox(height: 20),
          _sectionLabel(theme, 'Notifications'),
          _tile(context, theme, Icons.notifications_outlined, 'Alert Preferences',
              'Push, SMS & email alert settings', () {}),

          const SizedBox(height: 20),
          _sectionLabel(theme, 'Security & Data'),
          _tile(context, theme, Icons.security_rounded, 'Security',
              'Encrypt Engine status, audit logs, sessions',
              () {}, iconColor: const Color(0xFF00E676)),
          _tile(context, theme, Icons.backup_rounded, 'Database Backup',
              'Secure offline backup snapshot', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DatabaseBackupPage()));
          }),
          _tile(context, theme, Icons.import_export, 'Data Export',
              'Export tables to Excel (.xlsx)', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DataExportPage()));
          }),
          _tile(context, theme, Icons.dns_rounded, 'Server Connection',
              'API server URL & connection status', () {}),

          const SizedBox(height: 20),
          _sectionLabel(theme, 'About'),
          _tile(context, theme, Icons.info_outline, 'About CashewPro',
              'Version 0.1.0 — Phase 1', () {}),
        ],
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(label,
        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1)),
    );
  }

  Widget _tile(BuildContext context, ThemeData theme, IconData icon, String title,
      String subtitle, VoidCallback onTap, {Color? iconColor, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
