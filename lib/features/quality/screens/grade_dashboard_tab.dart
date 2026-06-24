import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class GradeDashboardTab extends StatelessWidget {
  const GradeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/grading/grading_entry'),
        icon: const Icon(Icons.assessment_rounded),
        label: const Text('Grade a Lot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grade Stock Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildGradeCard(theme, 'W180', '120 kg', '₹1,800/kg', Colors.amber, isWide, context),
                _buildGradeCard(theme, 'W210', '340 kg', '₹1,400/kg', Colors.orange, isWide, context),
                _buildGradeCard(theme, 'W240', '890 kg', '₹1,100/kg', Colors.deepOrange, isWide, context),
                _buildGradeCard(theme, 'W320', '1,500 kg', '₹900/kg', Colors.redAccent, isWide, context),
                _buildGradeCard(theme, 'SW', '200 kg', '₹650/kg', Colors.purple, isWide, context),
              ],
            ),
            const SizedBox(height: 32),
            Text('Current Grade Distribution', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              height: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: isWide 
                  ? Row(
                      children: [
                        Expanded(child: _buildPieChart()),
                        Expanded(child: _buildLegend(theme)),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(child: _buildPieChart()),
                        const SizedBox(height: 24),
                        _buildLegend(theme),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard(ThemeData theme, String grade, String stock, String price, Color color, bool isWide, BuildContext context) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(grade, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text('Stock: $stock', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 4),
          Text('Market: $price', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: [
          PieChartSectionData(value: 30, color: Colors.redAccent, title: 'W320\n30%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 20, color: Colors.deepOrange, title: 'W240\n20%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 15, color: Colors.orange, title: 'W210\n15%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 10, color: Colors.amber, title: 'W180\n10%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 25, color: Colors.grey, title: 'Others\n25%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _legendItem(theme, 'W320 (Standard)', Colors.redAccent),
        const SizedBox(height: 12),
        _legendItem(theme, 'W240 (Premium)', Colors.deepOrange),
        const SizedBox(height: 12),
        _legendItem(theme, 'W210 (Jumbo)', Colors.orange),
        const SizedBox(height: 12),
        _legendItem(theme, 'W180 (King)', Colors.amber),
        const SizedBox(height: 12),
        _legendItem(theme, 'Others (Splits, Pieces)', Colors.grey),
      ],
    );
  }

  Widget _legendItem(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
      ],
    );
  }
}
