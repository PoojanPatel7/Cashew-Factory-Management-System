import 'package:flutter/material.dart';

class ExportDocsPage extends StatefulWidget {
  const ExportDocsPage({super.key});

  @override
  State<ExportDocsPage> createState() => _ExportDocsPageState();
}

class _ExportDocsPageState extends State<ExportDocsPage> {
  String _order = 'ORD-2023-006 (Global Snacks Corp)';
  final Map<String, bool> _docs = {
    'Commercial Invoice': true,
    'Packing List': true,
    'Certificate of Origin': false,
    'Phytosanitary Certificate': false,
    'Bill of Lading Draft': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Documentation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _order,
            decoration: const InputDecoration(labelText: 'Select Export Order'),
            items: ['ORD-2023-006 (Global Snacks Corp)', 'ORD-2023-008 (EU Traders)']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _order = v!),
          ),
          const SizedBox(height: 24),
          const Text('Select Documents to Generate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._docs.keys.map((key) => CheckboxListTile(
            title: Text(key),
            value: _docs[key],
            onChanged: (v) => setState(() => _docs[key] = v ?? false),
          )),
          const SizedBox(height: 24),
          const Text('Currency & Exchange Rate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'USD',
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: ['USD', 'EUR', 'GBP'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: '82.50',
                  decoration: const InputDecoration(labelText: 'Rate (₹)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating ZIP file with selected documents...')));
              },
              icon: const Icon(Icons.download),
              label: const Text('Generate & Download ZIP'),
            ),
          ),
        ],
      ),
    );
  }
}
