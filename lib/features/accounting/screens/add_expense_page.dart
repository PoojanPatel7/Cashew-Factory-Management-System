import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Electricity';
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _paymentMode = 'Cash';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: $_category'),
              Text('Amount: ₹ ${_amountCtrl.text}'),
              Text('Mode: $_paymentMode'),
              Text('Desc: ${_descCtrl.text}'),
              const SizedBox(height: 16),
              const Text('Submit for approval?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense submitted for approval')),
                );
                context.pop(); // Go back
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Expense Category'),
                items: ['Electricity', 'Maintenance', 'Transport', 'Office Supplies', 'Miscellaneous']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMode,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                items: ['Cash', 'Bank Transfer', 'UPI', 'Credit']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMode = v!),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Upload Receipt'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Submit Expense', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
