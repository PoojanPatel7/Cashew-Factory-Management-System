import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class CnslExtractionLogPage extends StatefulWidget {
  const CnslExtractionLogPage({super.key});

  @override
  State<CnslExtractionLogPage> createState() => _CnslExtractionLogPageState();
}

class _CnslExtractionLogPageState extends State<CnslExtractionLogPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm CNSL Extraction'),
          content: const Text('Log 150 Litres of CNSL oil extracted from 1000kg shells?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CNSL Stock Updated')));
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
      appBar: AppBar(title: const Text('CNSL Extraction Log')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Date'),
              initialValue: '15-Jun-2023',
              readOnly: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: 'Expeller Press',
              decoration: const InputDecoration(labelText: 'Extraction Method'),
              items: ['Expeller Press', 'Solvent Extraction', 'Roasting']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Shells Input (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'CNSL Output (Litres)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Log Extraction'),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Recent Extractions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.water_drop)),
                title: const Text('14-Jun-2023'),
                subtitle: const Text('Input: 800 kg Shells\nMethod: Expeller Press'),
                trailing: const Text('120 L', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                isThreeLine: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
