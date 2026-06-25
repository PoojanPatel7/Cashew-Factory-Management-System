import 'package:flutter/material.dart';

class AdvanceManagementPage extends StatefulWidget {
  const AdvanceManagementPage({super.key});

  @override
  State<AdvanceManagementPage> createState() => _AdvanceManagementPageState();
}

class _AdvanceManagementPageState extends State<AdvanceManagementPage> {
  final _formKey = GlobalKey<FormState>();
  String _employeeId = 'E001';
  double _amount = 0;
  int _emiMonths = 1;
  String _purpose = '';

  void _handleGrantAdvance() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final emiAmount = _amount / _emiMonths;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Advance Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Employee: Ramesh Kumar ($_employeeId)'),
              Text('Amount: ₹$_amount'),
              Text('Purpose: $_purpose'),
              const Divider(),
              const Text('Repayment Plan', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Duration: $_emiMonths Months'),
              Text('Monthly EMI: ₹${emiAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
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
                  const SnackBar(content: Text('Advance granted successfully')),
                );
              },
              child: const Text('Confirm & Grant'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advance Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Summary
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Outstanding Advances'),
                        SizedBox(height: 8),
                        Text('₹45,000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.account_balance_wallet, size: 48, color: Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form to give advance
            const Text('Grant New Advance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _employeeId,
                    decoration: const InputDecoration(
                      labelText: 'Select Employee',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'E001', child: Text('Ramesh Kumar - Shelling')),
                      DropdownMenuItem(value: 'E002', child: Text('Suresh Singh - Peeling')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _employeeId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Advance Amount (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (double.tryParse(val) == null) return 'Invalid number';
                      return null;
                    },
                    onSaved: (val) => _amount = double.parse(val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'EMI Duration (Months)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (int.tryParse(val) == null || int.parse(val) < 1) return 'Min 1 month';
                      return null;
                    },
                    onSaved: (val) => _emiMonths = int.parse(val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Purpose',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (val) => _purpose = val ?? '',
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _handleGrantAdvance,
                      icon: const Icon(Icons.check_circle),
                      label: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Grant Advance', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
