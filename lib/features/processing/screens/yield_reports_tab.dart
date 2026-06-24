import 'package:flutter/material.dart';

class YieldReportsTab extends StatelessWidget {
  const YieldReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Processing Yield Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMetricCard(theme, 'Average Outturn', '24.5%', '+0.2%', Colors.green, isWide, context),
                _buildMetricCard(theme, 'Total Wastage', '12.3%', '-0.5%', Colors.green, isWide, context),
                _buildMetricCard(theme, 'Grade A Recovery', '68.0%', '+1.5%', Colors.green, isWide, context),
                _buildMetricCard(theme, 'Avg Processing Time', '4.2 Days', '-0.1 Days', Colors.green, isWide, context),
              ],
            ),
            const SizedBox(height: 32),
            Text('Stage-wise Wastage Breakdown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildWastageChartMockup(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, String trend, Color trendColor, bool isWide, BuildContext context) {
    return Container(
      width: isWide ? 200 : (MediaQuery.of(context).size.width / 2) - 32,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(width: 8),
              Text(trend, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWastageChartMockup(ThemeData theme) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('[Chart Placeholder]', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          const Text('Top Wastage Stages: Shelling (40%), Peeling (30%), Grading (15%)', style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
