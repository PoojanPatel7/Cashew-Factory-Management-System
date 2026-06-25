import 'package:flutter/material.dart';

class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Detail'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Orders'),
              Tab(text: 'Ledger'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(context),
            _buildOrdersTab(context),
            _buildLedgerTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 40,
          child: Icon(Icons.business, size: 40),
        ),
        const SizedBox(height: 16),
        const Text('Premium Nuts Traders', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text('Mumbai, Maharashtra', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('GSTIN', '27XYZAB5678C1Z2'),
                const Divider(),
                _buildInfoRow('Contact', '+91 9876543210'),
                const Divider(),
                _buildInfoRow('Email', 'purchase@premiumnuts.com'),
                const Divider(),
                _buildInfoRow('Credit Limit', '₹ 5,00,000'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderListCard(context, 'ORD-2023-005', '₹ 3,75,000', 'Dispatched', Colors.blue),
        _buildOrderListCard(context, 'ORD-2023-002', '₹ 1,12,000', 'Delivered', Colors.green),
      ],
    );
  }

  Widget _buildOrderListCard(BuildContext context, String ordNo, String amount, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(ordNo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(amount),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildLedgerTab(BuildContext context) {
    return const Center(child: Text('Ledger view (similar to Accounting Ledger)'));
  }
}
