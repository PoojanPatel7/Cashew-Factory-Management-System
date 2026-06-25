import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sales_provider.dart';

class CreateDispatchPage extends ConsumerStatefulWidget {
  const CreateDispatchPage({super.key});

  @override
  ConsumerState<CreateDispatchPage> createState() => _CreateDispatchPageState();
}

class _CreateDispatchPageState extends ConsumerState<CreateDispatchPage> {
  String _order = 'ORD-2023-005';
  String _vehicle = 'MH-04-AB-1234';
  String _driver = 'Raju';

  void _submit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Dispatch'),
        content: const Text('Dispatch 500kg W320 to Premium Nuts Traders?\n\nThis will permanently deduct the quantity from your Finished Goods Inventory.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              final success = await ref.read(salesProvider.notifier).dispatchOrder(_order, _vehicle, _driver);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispatch created and stock updated')));
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to dispatch order.')));
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Dispatch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _order,
              decoration: const InputDecoration(labelText: 'Select Pending Order'),
              items: ['ORD-2023-005', 'ORD-2023-006']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _order = v!),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Customer: Premium Nuts Traders\nItems: W320 (500kg)\nTotal Weight: 500kg', style: TextStyle(height: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: _vehicle,
              decoration: const InputDecoration(labelText: 'Vehicle Number'),
              onChanged: (v) => _vehicle = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Driver Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Driver Contact'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Create Dispatch', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
