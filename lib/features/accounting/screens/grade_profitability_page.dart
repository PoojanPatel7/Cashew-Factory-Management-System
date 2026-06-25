import 'package:flutter/material.dart';

class GradeProfitabilityPage extends StatelessWidget {
  const GradeProfitabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Profitability'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Top Performing Grades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildGradeCard(context, 'W320', 750.0, 480.0, 5000),
          _buildGradeCard(context, 'W240', 850.0, 520.0, 2000),
          _buildGradeCard(context, 'W210', 950.0, 600.0, 1000),
          _buildGradeCard(context, 'Splits (LWP)', 450.0, 400.0, 3000),
        ],
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, String grade, double avgSellingPrice, double avgCostPrice, double qtySold) {
    final marginPerKg = avgSellingPrice - avgCostPrice;
    final totalMargin = marginPerKg * qtySold;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(grade, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '₹ ${totalMargin.toStringAsFixed(0)} Total',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Avg Cost', '₹ $avgCostPrice/kg'),
                _buildStat('Avg Price', '₹ $avgSellingPrice/kg'),
                _buildStat('Margin', '₹ $marginPerKg/kg', color: Colors.green),
                _buildStat('Qty Sold', '${qtySold}kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String val, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
