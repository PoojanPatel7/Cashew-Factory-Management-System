import 'package:flutter/material.dart';

class QualityCertificatePage extends StatelessWidget {
  const QualityCertificatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Certificate'),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.print_rounded), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: isWide ? 800 : double.infinity,
            padding: EdgeInsets.all(isWide ? 48 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CASHEWPRO ERP', style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Quality Assurance Department', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(8)),
                      child: const Text('CERTIFIED', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.black26)),
                
                // Details
                const Text('CERTIFICATE OF ANALYSIS', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 32),
                
                _buildInfoRow('Certificate No', 'CERT-26-005', 'Date of Issue', '24-Jun-2026'),
                const SizedBox(height: 12),
                _buildInfoRow('Lot Reference', 'LOT-2026-101', 'Commodity', 'Cashew Kernels'),
                
                const SizedBox(height: 32),
                const Text('1. Physical Characteristics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 16),
                _buildResultTable([
                  ['Parameter', 'Result', 'Standard Limit'],
                  ['Moisture Content', '4.5%', 'Max 5.0%'],
                  ['Broken Ratio', '2.0%', 'Max 5.0%'],
                  ['Color Grade', 'White', 'White'],
                ]),
                
                const SizedBox(height: 32),
                const Text('2. Safety & Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 16),
                _buildResultTable([
                  ['Parameter', 'Result', 'Standard Limit'],
                  ['Foreign Material', 'Nil', 'Nil'],
                  ['Metal Detection', 'Passed', 'Passed'],
                  ['Aflatoxin', 'Cleared', 'Below 10ppb'],
                ]),

                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(width: 150, height: 1, color: Colors.black87),
                        const SizedBox(height: 8),
                        const Text('Quality Inspector', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(width: 150, height: 1, color: Colors.black87),
                        const SizedBox(height: 8),
                        const Text('Authorized Signatory', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String lbl1, String val1, String lbl2, String val2) {
    return Row(
      children: [
        Expanded(child: RichText(text: TextSpan(children: [TextSpan(text: '$lbl1: ', style: const TextStyle(color: Colors.black54)), TextSpan(text: val1, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]))),
        Expanded(child: RichText(text: TextSpan(children: [TextSpan(text: '$lbl2: ', style: const TextStyle(color: Colors.black54)), TextSpan(text: val2, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]))),
      ],
    );
  }

  Widget _buildResultTable(List<List<String>> data) {
    return Table(
      border: TableBorder.all(color: Colors.black12),
      children: data.asMap().entries.map((e) {
        final isHeader = e.key == 0;
        return TableRow(
          decoration: BoxDecoration(color: isHeader ? Colors.grey.shade100 : Colors.white),
          children: e.value.map((cell) => Padding(
            padding: const EdgeInsets.all(12),
            child: Text(cell, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, color: Colors.black87)),
          )).toList(),
        );
      }).toList(),
    );
  }
}
