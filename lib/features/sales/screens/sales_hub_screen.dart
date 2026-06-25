import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SalesHubScreen extends StatelessWidget {
  const SalesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales & Dispatch Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction(context, 'Customers', Icons.people, 'customer_list'),
                  _buildQuickAction(context, 'New Order', Icons.add_shopping_cart, 'create_sales_order'),
                  _buildQuickAction(context, 'Invoices', Icons.receipt_long, 'invoice_list'),
                  _buildQuickAction(context, 'Price List', Icons.price_change, 'price_list'),
                  _buildQuickAction(context, 'Dispatch', Icons.local_shipping, 'dispatch_dashboard'),
                  _buildQuickAction(context, 'Export Docs', Icons.flight_takeoff, 'export_docs'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard(context, 'Active Orders', '12', Icons.shopping_bag, cs.primary)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard(context, 'Pending Dispatch', '4', Icons.local_shipping, Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard(context, 'This Month Sales', '₹ 12.4L', Icons.trending_up, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard(context, 'Overdue Payments', '₹ 1.2L', Icons.warning_amber, Colors.red)),
              ],
            ),
            const SizedBox(height: 24),

            Text('Recent Orders', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildOrderList(context),
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

  Widget _buildSummaryCard(BuildContext context, String title, String amount, IconData icon, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final isDelivered = index > 2;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isDelivered ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
              child: Icon(
                isDelivered ? Icons.check_circle : Icons.pending,
                color: isDelivered ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
            title: Text('ORD-2023-00${5 - index} • Premium Nuts Traders'),
            subtitle: Text('W320: 500kg • ₹ 3,75,000'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed('sales_order_detail'),
          );
        },
      ),
    );
  }
}
