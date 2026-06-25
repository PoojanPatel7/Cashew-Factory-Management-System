import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class AddDocumentPage extends StatefulWidget {
  const AddDocumentPage({super.key});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Document Upload'),
          content: const Text('Save this compliance document and set up expiry alerts?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document Uploaded Successfully')));
                context.pop();
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
      appBar: AppBar(title: const Text('Add Compliance Doc')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Document Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: 'FSSAI License',
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['FSSAI License', 'Factory License', 'Pollution NOC', 'Fire NOC', 'Labour License']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Issue Date', prefixIcon: Icon(Icons.calendar_today)),
                  readOnly: true,
                  initialValue: '15-Jun-2023',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Expiry Date', prefixIcon: Icon(Icons.event_busy)),
                  readOnly: true,
                  initialValue: '14-Jun-2024',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Alert Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(title: const Text('Remind 30 days before'), value: true, onChanged: (v) {}),
            CheckboxListTile(title: const Text('Remind 15 days before'), value: true, onChanged: (v) {}),
            CheckboxListTile(title: const Text('Remind 7 days before'), value: true, onChanged: (v) {}),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload PDF / Image'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Save Document'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
