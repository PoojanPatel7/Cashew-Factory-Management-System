import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class WasteDisposalLogPage extends StatefulWidget {
  const WasteDisposalLogPage({super.key});

  @override
  State<WasteDisposalLogPage> createState() => _WasteDisposalLogPageState();
}

class _WasteDisposalLogPageState extends State<WasteDisposalLogPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Disposal'),
          content: const Text('Log waste disposal entry?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disposal Logged Successfully')));
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waste Disposal Log')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ResponsiveGridRow(
              children: [
                DropdownButtonFormField<String>(
                  value: 'Rejects (Black/Rotten)',
                  decoration: const InputDecoration(labelText: 'Waste Type'),
                  items: ['Rejects (Black/Rotten)', 'Testa Dust', 'Factory Sweepings']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {},
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: 'Composting',
              decoration: const InputDecoration(labelText: 'Disposal Method'),
              items: ['Composting', 'Landfill (Municipal)', 'Incineration', 'Sold as Fuel']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture Proof'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Log Disposal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
