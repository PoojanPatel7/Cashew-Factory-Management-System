import 'package:flutter/material.dart';

class TrialBalancePage extends StatelessWidget {
  const TrialBalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trial Balance'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Account Name')),
              DataColumn(label: Text('Debit (₹)'), numeric: true),
              DataColumn(label: Text('Credit (₹)'), numeric: true),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Raw Material Inventory')),
                DataCell(Text('5,40,000.00')),
                DataCell(Text('')),
              ]),
              DataRow(cells: [
                DataCell(Text('HDFC Bank')),
                DataCell(Text('8,20,000.00')),
                DataCell(Text('')),
              ]),
              DataRow(cells: [
                DataCell(Text('Cash in Hand')),
                DataCell(Text('45,000.00')),
                DataCell(Text('')),
              ]),
              DataRow(cells: [
                DataCell(Text('Sales Revenue')),
                DataCell(Text('')),
                DataCell(Text('12,45,000.00')),
              ]),
              DataRow(cells: [
                DataCell(Text('Accounts Payable')),
                DataCell(Text('')),
                DataCell(Text('1,60,000.00')),
              ]),
              DataRow(
                color: WidgetStatePropertyAll(Colors.black12),
                cells: [
                DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('14,05,000.00', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('14,05,000.00', style: TextStyle(fontWeight: FontWeight.bold))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
