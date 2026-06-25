import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class ReportsHubPage extends StatelessWidget {
  const ReportsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports Hub')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Favorite Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveGridRow(
            children: [
              _buildReportCard(context, 'Daily Production', 'Production', Icons.precision_manufacturing, Colors.green),
              _buildReportCard(context, 'Profit & Loss', 'Financial', Icons.account_balance, Colors.blue),
            ],
          ),
          const SizedBox(height: 24),
          const Text('All Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildCategoryCard(context, 'Production Reports', 'Yield, Wastage, Output', Icons.factory, Colors.green, ['Daily Production Summary', 'Stage-wise Output', 'Yield Report']),
          _buildCategoryCard(context, 'Inventory Reports', 'Stock, Aging, Movements', Icons.inventory, Colors.orange, ['Current Stock Position', 'Stock Movement Report']),
          _buildCategoryCard(context, 'Financial Reports', 'P&L, Cash Flow, Aging', Icons.attach_money, Colors.blue, ['Profit & Loss Statement', 'Cash Flow Statement', 'Expense Analysis']),
          _buildCategoryCard(context, 'Employee Reports', 'Attendance, Productivity', Icons.people, Colors.purple, ['Attendance Summary', 'Piece-rate Earnings', 'Productivity Report']),
          _buildCategoryCard(context, 'Machinery & Quality', 'Uptime, QC pass/fail', Icons.build, Colors.teal, ['Machine Uptime Report', 'QC Pass/Fail Ratio', 'Moisture Trend']),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String category, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.goNamed('report_viewer', queryParameters: {'reportName': title}),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String subtitle, IconData icon, Color color, List<String> reports) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        children: reports.map((r) => ListTile(
          title: Text(r),
          trailing: const Icon(Icons.arrow_right_alt, color: Colors.grey),
          onTap: () => context.goNamed('report_viewer', queryParameters: {'reportName': r}),
        )).toList(),
      ),
    );
  }
}
