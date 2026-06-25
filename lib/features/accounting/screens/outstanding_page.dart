import 'package:flutter/material.dart';

class OutstandingPage extends StatelessWidget {
  const OutstandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Outstandings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Receivables (To Collect)'),
              Tab(text: 'Payables (To Pay)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, true),
            _buildList(context, false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, bool isReceivable) {
    final title = isReceivable ? 'Premium Nuts Traders' : 'Tanzania RCN Suppliers';
    final amount = isReceivable ? 123375.0 : 540000.0;
    final days = isReceivable ? 45 : 15;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAgingSummary(context, isReceivable),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Invoice Date: 01-May-2023\nOverdue by: $days days'),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹ ${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isReceivable ? Colors.green : Colors.red)),
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: const Size(60, 24),
                  ),
                  child: Text(isReceivable ? 'Send Reminder' : 'Mark Paid', style: const TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgingSummary(BuildContext context, bool isReceivable) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aging Summary', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('0-30 days'),
                Text('₹ 45,000'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('30-60 days', style: TextStyle(color: Colors.orange)),
                Text('₹ 1,23,375', style: TextStyle(color: Colors.orange)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('60-90+ days', style: TextStyle(color: Colors.red)),
                Text('₹ 0'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
