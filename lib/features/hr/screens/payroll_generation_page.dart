import 'package:flutter/material.dart';

class PayrollGenerationPage extends StatefulWidget {
  const PayrollGenerationPage({super.key});

  @override
  State<PayrollGenerationPage> createState() => _PayrollGenerationPageState();
}

class _PayrollGenerationPageState extends State<PayrollGenerationPage> {
  String _selectedMonth = 'June 2026';

  final List<Map<String, dynamic>> payrollData = [
    {
      'id': 'E001',
      'name': 'Ramesh Kumar',
      'basic': 12000.0,
      'piece': 4500.0,
      'ot': 500.0,
      'gross': 17000.0,
      'pf': 1440.0,
      'advance': 2000.0,
      'net': 13560.0,
    },
    {
      'id': 'E002',
      'name': 'Suresh Singh',
      'basic': 15000.0,
      'piece': 0.0,
      'ot': 1000.0,
      'gross': 16000.0,
      'pf': 1800.0,
      'advance': 0.0,
      'net': 14200.0,
    },
    {
      'id': 'E003',
      'name': 'Geeta Devi',
      'basic': 10000.0,
      'piece': 6000.0,
      'ot': 0.0,
      'gross': 16000.0,
      'pf': 1200.0,
      'advance': 1000.0,
      'net': 13800.0, // Anomaly: usually lower
    },
  ];

  void _handleGenerateAll() {
    double totalPayout = payrollData.fold(0, (sum, emp) => sum + emp['net']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Payroll Generation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Month: $_selectedMonth'),
              Text('Total Employees: ${payrollData.length}'),
              const Divider(),
              Text(
                'Total Net Payout: ₹${totalPayout.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 16),
              const Text('This will generate payslips for all listed employees and lock the month.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payroll Generated Successfully! Payslips are ready.')),
                );
              },
              child: const Text('Confirm & Generate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payroll Generation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Select Month: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedMonth,
                  items: ['May 2026', 'June 2026', 'July 2026'].map((m) {
                    return DropdownMenuItem(value: m, child: Text(m));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMonth = val);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest),
                columns: const [
                  DataColumn(label: Text('Employee')),
                  DataColumn(label: Text('Basic')),
                  DataColumn(label: Text('Piece Earn')),
                  DataColumn(label: Text('OT')),
                  DataColumn(label: Text('Gross')),
                  DataColumn(label: Text('PF/ESI')),
                  DataColumn(label: Text('Advance EMI')),
                  DataColumn(label: Text('Net Pay')),
                ],
                rows: payrollData.map((emp) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${emp['name']}\n(${emp['id']})')),
                      DataCell(Text('₹${emp['basic']}')),
                      DataCell(Text('₹${emp['piece']}')),
                      DataCell(Text('₹${emp['ot']}')),
                      DataCell(Text('₹${emp['gross']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('₹${emp['pf']}', style: const TextStyle(color: Colors.red))),
                      DataCell(Text('₹${emp['advance']}', style: const TextStyle(color: Colors.red))),
                      DataCell(Text(
                        '₹${emp['net']}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _handleGenerateAll,
                icon: const Icon(Icons.calculate),
                label: const Text('Generate All Payslips', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
