import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/responsive_grid_row.dart';
import '../providers/sales_provider.dart';

class SalesHubScreen extends ConsumerWidget {
  const SalesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final salesState = ref.watch(salesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales & Dispatch Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(salesProvider.notifier).fetchOrders(),
          ),
        ],
      ),
      body: salesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          final orders = state.orders ?? [];
          final activeOrdersCount = orders.where((o) => o['status'] != 'DELIVERED').length;
          final pendingDispatchCount = orders.where((o) => o['status'] == 'PENDING').length;

          double totalSales = 0;
          for (var o in orders) {
            totalSales += (o['totalAmount'] as num?)?.toDouble() ?? 0.0;
          }

          return SingleChildScrollView(
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
                ResponsiveGridRow(
                  children: [
                    _buildSummaryCard(context, 'Active Orders', '$activeOrdersCount', Icons.shopping_bag, cs.primary),
                    _buildSummaryCard(context, 'Pending Dispatch', '$pendingDispatchCount', Icons.local_shipping, Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                ResponsiveGridRow(
                  children: [
                    _buildSummaryCard(context, 'Total Sales', '₹ ${totalSales.toStringAsFixed(2)}', Icons.trending_up, Colors.green),
                    _buildSummaryCard(context, 'Overdue Payments', '₹ 0.00', Icons.warning_amber, Colors.red), // Mocked
                  ],
                ),
                const SizedBox(height: 24),

                Text('Recent Orders', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildOrderList(context, orders),
              ],
            ),
          );
        },
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
                Expanded(child: Text(title, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)))),
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

  Widget _buildOrderList(BuildContext context, List<dynamic> orders) {
    if (orders.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('No recent orders found.')),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length > 5 ? 5 : orders.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final order = orders[index];
          final status = order['status'] ?? 'UNKNOWN';
          final isDelivered = status == 'DELIVERED' || status == 'DISPATCHED';
          final customerName = order['customer'] != null ? order['customer']['encryptedName'] ?? 'Customer' : 'Customer';
          final amount = order['totalAmount'] ?? 0.0;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isDelivered ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
              child: Icon(
                isDelivered ? Icons.check_circle : Icons.pending,
                color: isDelivered ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
            title: Text('ORD-${order['id']} • $customerName'),
            subtitle: Text('Status: $status • ₹ $amount'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed('sales_order_detail'),
          );
        },
      ),
    );
  }
}
