import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class AddSparePartPage extends StatefulWidget {
  const AddSparePartPage({super.key});

  @override
  State<AddSparePartPage> createState() => _AddSparePartPageState();
}

class _AddSparePartPageState extends State<AddSparePartPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Spare Part'),
          content: const Text('Add this spare part to the inventory?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Spare Part Added Successfully')));
                context.pop();
              },
              child: const Text('Confirm ✓'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Spare Part')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Part Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(decoration: const InputDecoration(labelText: 'Part Number (SKU)')),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Quantity in Stock'), keyboardType: TextInputType.number),
                TextFormField(decoration: const InputDecoration(labelText: 'Minimum Stock Alert Level'), keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Unit Cost (₹)'), keyboardType: TextInputType.number),
                TextFormField(decoration: const InputDecoration(labelText: 'Vendor / Supplier')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Compatible Machines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            CheckboxListTile(title: const Text('Borma Dryers'), value: true, onChanged: (v) {}),
            CheckboxListTile(title: const Text('Peeling Machines'), value: false, onChanged: (v) {}),
            CheckboxListTile(title: const Text('Grading Machines'), value: false, onChanged: (v) {}),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.save), label: const Text('Save Spare Part')),
            ),
          ],
        ),
      ),
    );
  }
}
