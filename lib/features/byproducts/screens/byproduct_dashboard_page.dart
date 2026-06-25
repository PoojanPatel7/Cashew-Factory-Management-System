import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class ByproductDashboardPage extends StatelessWidget {
  const ByproductDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Byproduct Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction(context, 'Sell Byproduct', Icons.point_of_sale, 'byproduct_sale'),
                  _buildQuickAction(context, 'CNSL Extraction', Icons.water_drop, 'cnsl_extraction'),
                  _buildQuickAction(context, 'Waste Log', Icons.delete_sweep, 'waste_log'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ResponsiveGridRow(
              children: [
                _buildStatCard(context, 'Cashew Shells', '4,500 kg', '₹ 18,000', Colors.brown),
                _buildStatCard(context, 'CNSL (Oil)', '1,200 L', '₹ 45,000', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                _buildStatCard(context, 'Testa (Husk)', '850 kg', '₹ 6,800', Colors.amber),
                _buildStatCard(context, 'Rejects', '120 kg', '₹ 0', Colors.grey),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Revenue Trend (This Month)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('Total Byproduct Revenue: ₹ 69,800', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Byproduct Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.water_drop, color: Colors.orange)),
                title: const Text('CNSL Sale • 500 L'),
                subtitle: const Text('Buyer: Apex Chemicals\nRate: ₹ 38/L'),
                isThreeLine: true,
                trailing: const Text('+ ₹ 19,000', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, String routeName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        onPressed: () => context.goNamed(routeName),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String stock, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                Icon(Icons.inventory_2, color: color.withValues(alpha: 0.5), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Stock Available', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(stock, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Est. Value', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
