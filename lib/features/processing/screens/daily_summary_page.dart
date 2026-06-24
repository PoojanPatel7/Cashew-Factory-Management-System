import 'package:flutter/material.dart';
import '../../../shared/widgets/common_widgets.dart';

class DailySummaryPage extends StatelessWidget {
  const DailySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Production Summary'),
        actions: [
          IconButton(icon: const Icon(Icons.print_outlined), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Shift: Morning (06:00 - 14:00) | 24-Jun-2026', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Select Date/Shift'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Text('Overall Production Metrics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(theme, 'Total RCN Input', '4,500 kg', Icons.login_rounded, Colors.blue, isWide, context),
                _buildStatCard(theme, 'Total Kernel Output', '1,120 kg', Icons.logout_rounded, Colors.green, isWide, context),
                _buildStatCard(theme, 'Total Wastage', '560 kg', Icons.delete_outline, Colors.orange, isWide, context),
                _buildStatCard(theme, 'Lots Processed', '8', Icons.view_in_ar_outlined, Colors.purple, isWide, context),
              ],
            ),
            
            const SizedBox(height: 32),
            Text('Operator Performance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildOperatorTable(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color, bool isWide, BuildContext context) {
    return Container(
      width: isWide ? 250 : (MediaQuery.of(context).size.width / 2) - 32,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildOperatorTable(ThemeData theme) {
    final operators = [
      {'name': 'Rajesh Kumar', 'stage': 'Shelling', 'lots': 4, 'output': '520 kg', 'wastage': '12%'},
      {'name': 'Anita S', 'stage': 'Cooling', 'lots': 6, 'output': '850 kg', 'wastage': '2%'},
      {'name': 'Manoj D', 'stage': 'Boiling', 'lots': 5, 'output': '1200 kg', 'wastage': '1%'},
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
          columns: const [
            DataColumn(label: Text('Operator Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Assigned Stage', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Lots Handled', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total Output', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Avg Wastage', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: operators.map((op) => DataRow(
            cells: [
              DataCell(Text(op['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(op['stage'] as String)),
              DataCell(Text(op['lots'].toString())),
              DataCell(Text(op['output'] as String)),
              DataCell(Text(op['wastage'] as String, style: TextStyle(color: (op['wastage'] as String) == '12%' ? Colors.red : Colors.green))),
            ],
          )).toList(),
        ),
      ),
    );
  }
}
