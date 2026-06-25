import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class AddMachinePage extends StatefulWidget {
  const AddMachinePage({super.key});

  @override
  State<AddMachinePage> createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Machine'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: Borma Dryer'),
              Text('Model: BD-5000'),
              Text('Capacity: 500 kg/hr'),
              Text('Cost: ₹4,50,000'),
              Text('Warranty until: 2028-06-15'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine Added & QR Generated')));
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
      appBar: AppBar(title: const Text('Add New Machine')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Basic Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Machine Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                DropdownButtonFormField<String>(
                  value: 'Borma Dryer',
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Borma Dryer', 'Peeling Machine', 'Grader', 'Shelling Machine']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Model Number')),
                TextFormField(decoration: const InputDecoration(labelText: 'Manufacturer')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Specifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Capacity (kg/hr)'), keyboardType: TextInputType.number),
                TextFormField(decoration: const InputDecoration(labelText: 'Power (kW)'), keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Purchase & Warranty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Cost (₹)'), keyboardType: TextInputType.number),
                TextFormField(decoration: const InputDecoration(labelText: 'Warranty Until', prefixIcon: Icon(Icons.calendar_today)), readOnly: true, initialValue: '15-Jun-2028'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Upload Photo'))),
                const SizedBox(width: 16),
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file), label: const Text('Upload Manual'))),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.save), label: const Text('Save & Generate QR')),
            ),
          ],
        ),
      ),
    );
  }
}
