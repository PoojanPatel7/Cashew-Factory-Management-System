import 'package:flutter/material.dart';

class DocumentDetailPage extends StatelessWidget {
  const DocumentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: 64, color: Colors.redAccent),
                  SizedBox(height: 16),
                  Text('FSSAI_License_2023.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Tap to preview', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Document Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('Name', 'FSSAI Food License'),
                  const Divider(),
                  _buildInfoRow('Category', 'FSSAI License'),
                  const Divider(),
                  _buildInfoRow('Issue Date', '15-Jun-2022'),
                  const Divider(),
                  _buildInfoRow('Expiry Date', '14-Jun-2023', isExpiry: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening renewal portal...')));
              },
              icon: const Icon(Icons.autorenew),
              label: const Text('Renew Document'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isExpiry = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isExpiry ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}
