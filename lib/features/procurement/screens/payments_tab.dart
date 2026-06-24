import 'package:flutter/material.dart';

class PaymentsTab extends StatelessWidget {
  const PaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final payments = [
      {'date': '24-Jun-2026', 'supplier': 'Rajan Cashew Farm', 'amount': '₹1,50,000', 'type': 'Advance', 'mode': 'Bank Transfer'},
      {'date': '21-Jun-2026', 'supplier': 'Global Nuts Exporters', 'amount': '₹4,00,000', 'type': 'Partial', 'mode': 'Cheque'},
      {'date': '18-Jun-2026', 'supplier': 'Shreeji Traders', 'amount': '₹2,37,500', 'type': 'Full', 'mode': 'Bank Transfer'},
      {'date': '12-Jun-2026', 'supplier': 'Rajan Cashew Farm', 'amount': '₹7,20,000', 'type': 'Full', 'mode': 'Bank Transfer'},
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.payment_rounded),
        label: const Text('Record Payment'),
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _summaryCard(theme, 'Total Paid (Month)', '₹15,07,500', Icons.arrow_upward_rounded, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _summaryCard(theme, 'Pending Dues', '₹7,80,000', Icons.warning_amber_rounded, Colors.orange)),
              ],
            ),
          ),

          // Ledger Table
          Expanded(
            child: isWide ? _buildDesktopTable(theme, payments) : _buildMobileList(theme, payments),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(ThemeData theme, String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(amount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(ThemeData theme, List<Map<String, String>> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Mode')),
        ],
        rows: data.map((p) => DataRow(
          cells: [
            DataCell(Text(p['date']!)),
            DataCell(Text(p['supplier']!, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(p['amount']!, style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary))),
            DataCell(Text(p['type']!)),
            DataCell(Text(p['mode']!)),
          ]
        )).toList(),
      ),
    );
  }

  Widget _buildMobileList(ThemeData theme, List<Map<String, String>> data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (ctx, i) {
        final p = data[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          color: theme.colorScheme.surface,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.account_balance_wallet_outlined, color: theme.colorScheme.primary),
            ),
            title: Text(p['supplier']!, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${p['date']} • ${p['mode']}', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                const SizedBox(height: 4),
                Text(p['type']!, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
              ],
            ),
            trailing: Text(p['amount']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        );
      },
    );
  }
}
