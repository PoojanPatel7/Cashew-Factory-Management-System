import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvoiceListPage extends StatelessWidget {
  const InvoiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInvoiceCard(context, 'INV-2023-042', 'Premium Nuts Traders', 123375.0, 'Unpaid', Colors.orange),
          _buildInvoiceCard(context, 'INV-2023-041', 'Global Snacks Corp', 54000.0, 'Paid', Colors.green),
          _buildInvoiceCard(context, 'INV-2023-040', 'Local Wholesalers', 15000.0, 'Overdue', Colors.red),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, String invNo, String customer, double amount, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.receipt_long),
        ),
        title: Text(invNo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$customer\n₹ ${amount.toStringAsFixed(2)}'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(status == 'Unpaid' || status == 'Overdue' ? 'Record Pay' : 'View', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        onTap: () {
          if (status != 'Paid') {
            _showPaymentDialog(context, invNo, amount);
          }
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, String invNo, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment - $invNo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: amount.toStringAsFixed(2),
              decoration: const InputDecoration(labelText: 'Amount Received (₹)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: 'Bank Transfer',
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: ['Bank Transfer', 'Cash', 'Cheque', 'UPI'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Reference / UTR No'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Recorded')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
