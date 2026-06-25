import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class SalesOrderDetailPage extends StatelessWidget {
  const SalesOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildStatusTimeline(context),
          const SizedBox(height: 24),
          _buildItemsTable(context),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ORD-2023-005', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Text('Confirmed', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text('Customer: Premium Nuts Traders', style: TextStyle(fontSize: 16)),
            const Text('Date: 15-Jun-2023', style: TextStyle(color: Colors.grey)),
            const Text('Delivery By: 20-Jun-2023', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTimelineNode('Order Placed', '15-Jun 10:00 AM', isCompleted: true),
            _buildTimelineNode('Confirmed', '15-Jun 11:30 AM', isCompleted: true),
            _buildTimelineNode('Packed', 'Pending', isCompleted: false),
            _buildTimelineNode('Dispatched', 'Pending', isCompleted: false),
            _buildTimelineNode('Delivered', 'Pending', isCompleted: false, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineNode(String title, String time, {bool isCompleted = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? Colors.green : Colors.grey, size: 20),
            if (!isLast)
              Container(width: 2, height: 30, color: isCompleted ? Colors.green : Colors.grey),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal)),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('W320 (500kg x ₹750)'),
                Text('₹ 3,75,000'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('W240 (200kg x ₹850)'),
                Text('₹ 1,70,000'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹ 5,45,000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ResponsiveGridRow(
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.inventory_2),
          label: const Text('Generate Packing Slip'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.local_shipping),
          label: const Text('Create Dispatch'),
        ),
      ],
    );
  }
}
