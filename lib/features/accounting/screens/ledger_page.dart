import 'package:flutter/material.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  final List<Map<String, dynamic>> _accounts = [
    {'name': 'Raw Material Purchases', 'balance': 540000.0, 'type': 'Expense'},
    {'name': 'Sales Revenue', 'balance': 1245000.0, 'type': 'Income'},
    {'name': 'Wages Payable', 'balance': 45000.0, 'type': 'Liability'},
    {'name': 'Cash in Hand', 'balance': 45000.0, 'type': 'Asset'},
    {'name': 'HDFC Bank', 'balance': 820000.0, 'type': 'Asset'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledgers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting Ledger to PDF...')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: _getAccountIcon(account['type']),
              title: Text(account['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(account['type']),
              trailing: Text(
                '₹ ${account['balance'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              children: [
                const Divider(),
                _buildTransactionRow('01-Jun', 'Opening Balance', '', '', account['balance']),
                _buildTransactionRow('05-Jun', 'Transaction 1', '10000.00', '', account['balance'] + 10000),
                _buildTransactionRow('12-Jun', 'Transaction 2', '', '5000.00', account['balance'] + 5000),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('View Full Statement'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _getAccountIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'Asset': icon = Icons.account_balance; color = Colors.blue; break;
      case 'Liability': icon = Icons.credit_card; color = Colors.orange; break;
      case 'Income': icon = Icons.trending_up; color = Colors.green; break;
      case 'Expense': icon = Icons.trending_down; color = Colors.red; break;
      default: icon = Icons.folder; color = Colors.grey;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.2),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildTransactionRow(String date, String desc, String dr, String cr, double bal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(date, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 12))),
          SizedBox(width: 60, child: Text(dr, style: const TextStyle(fontSize: 12, color: Colors.green), textAlign: TextAlign.right)),
          SizedBox(width: 60, child: Text(cr, style: const TextStyle(fontSize: 12, color: Colors.red), textAlign: TextAlign.right)),
          SizedBox(width: 80, child: Text(bal.toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
