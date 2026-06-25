import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GstDashboardPage extends StatelessWidget {
  const GstDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Compliance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Month (June 2023)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                OutlinedButton(onPressed: () {}, child: const Text('Change')),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTaxRow('CGST (Central Tax)', '₹ 24,500', cs),
                    const Divider(),
                    _buildTaxRow('SGST (State Tax)', '₹ 24,500', cs),
                    const Divider(),
                    _buildTaxRow('IGST (Integrated Tax)', '₹ 12,000', cs),
                    const Divider(thickness: 2),
                    _buildTaxRow('Total GST Liability', '₹ 61,000', cs, isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Input Tax Credit (ITC)'),
                          const SizedBox(height: 8),
                          Text('₹ 18,500', style: TextStyle(color: Colors.green[400], fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.orange.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Net Tax Payable'),
                          const SizedBox(height: 8),
                          Text('₹ 42,500', style: TextStyle(color: Colors.orange[400], fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Cashew HSN Codes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Cashew Nuts, Shelled'),
                subtitle: const Text('HSN: 08013200'),
                trailing: const Text('5% GST'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Cashew Nuts, In Shell'),
                subtitle: const Text('HSN: 08013100'),
                trailing: const Text('5% GST'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () => context.goNamed('gst_invoice'),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Generate GST Invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxRow(String label, String amount, ColorScheme cs, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : 14, color: isTotal ? cs.primary : null)),
        ],
      ),
    );
  }
}
