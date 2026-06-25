import 'package:flutter/material.dart';

class LotProfitabilityPage extends StatelessWidget {
  const LotProfitabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot Profitability'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLotCard(context, 'LOT-2023-001', 'Benin RCN', 5000, 480000.0, 620000.0),
          _buildLotCard(context, 'LOT-2023-002', 'Ivory Coast RCN', 3500, 310000.0, 290000.0), // Loss
          _buildLotCard(context, 'LOT-2023-003', 'Tanzania RCN', 8000, 750000.0, 1050000.0),
        ],
      ),
    );
  }

  Widget _buildLotCard(BuildContext context, String lotId, String origin, double qty, double cost, double revenue) {
    final profit = revenue - cost;
    final isProfit = profit >= 0;
    final margin = (profit / cost) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lotId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isProfit ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isProfit ? 'PROFIT' : 'LOSS',
                    style: TextStyle(color: isProfit ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('$origin • $qty kg', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Cost (incl. Process)'),
                    Text('₹ ${cost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Revenue'),
                    Text('₹ ${revenue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Result', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${isProfit ? '+' : ''}₹ ${profit.toStringAsFixed(2)} (${margin.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      color: isProfit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
