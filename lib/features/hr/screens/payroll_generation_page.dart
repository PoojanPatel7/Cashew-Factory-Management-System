import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hr_provider.dart';

class PayrollGenerationPage extends ConsumerStatefulWidget {
  const PayrollGenerationPage({super.key});

  @override
  ConsumerState<PayrollGenerationPage> createState() => _PayrollGenerationPageState();
}

class _PayrollGenerationPageState extends ConsumerState<PayrollGenerationPage> {
  String _selectedMonth = 'June 2026';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hrProvider.notifier).fetchPayroll(_selectedMonth);
    });
  }

  void _handleGenerateAll(List<dynamic> payrollData) {
    double totalPayout = payrollData.fold(0, (sum, emp) => sum + (emp['net'] ?? 0));

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
    final hrState = ref.watch(hrProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payroll Generation')),
      body: hrState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          final payrollData = state.payrollData ?? [];
          return Column(
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
                        if (val != null) {
                          setState(() => _selectedMonth = val);
                          ref.read(hrProvider.notifier).fetchPayroll(_selectedMonth);
                        }
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
                          DataCell(Text('₹${emp['basic'] ?? 0}')),
                          DataCell(Text('₹${emp['piece'] ?? 0}')),
                          DataCell(Text('₹${emp['ot'] ?? 0}')),
                          DataCell(Text('₹${emp['gross'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('₹${emp['pf'] ?? 0}', style: const TextStyle(color: Colors.red))),
                          DataCell(Text('₹${emp['advance'] ?? 0}', style: const TextStyle(color: Colors.red))),
                          DataCell(Text(
                            '₹${emp['net'] ?? 0}', 
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
                    onPressed: () => _handleGenerateAll(payrollData),
                    icon: const Icon(Icons.calculate),
                    label: const Text('Generate All Payslips', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
