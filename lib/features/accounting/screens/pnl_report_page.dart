import 'package:flutter/material.dart';

class PnlReportPage extends StatelessWidget {
  const PnlReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss Statement'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Period: Jun 2023', style: TextStyle(fontWeight: FontWeight.bold)),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.date_range, size: 16),
                label: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPnlSection(context, 'Revenue', [
            {'label': 'Sales - W320', 'amount': 600000.0},
            {'label': 'Sales - W240', 'amount': 450000.0},
            {'label': 'Sales - Splits/Pieces', 'amount': 195000.0},
          ], 1245000.0),
          _buildPnlSection(context, 'Cost of Goods Sold (COGS)', [
            {'label': 'Raw Cashew Nuts (RCN) Purchase', 'amount': -540000.0},
            {'label': 'Processing Wages', 'amount': -85000.0},
          ], -625000.0),
          _buildTotalRow(context, 'Gross Profit', 620000.0, isHighlight: true),
          const SizedBox(height: 16),
          _buildPnlSection(context, 'Operating Expenses', [
            {'label': 'Electricity', 'amount': -12500.0},
            {'label': 'Transport & Logistics', 'amount': -15000.0},
            {'label': 'Factory Rent', 'amount': -40000.0},
            {'label': 'Admin & Office', 'amount': -8000.0},
          ], -75500.0),
          _buildTotalRow(context, 'Net Profit (Before Tax)', 544500.0, isHighlight: true, isFinal: true),
        ],
      ),
    );
  }

  Widget _buildPnlSection(BuildContext context, String title, List<Map<String, dynamic>> items, double total) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          '₹ ${total.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: total >= 0 ? Colors.green : Colors.red,
          ),
        ),
        children: items.map((item) {
          final amt = item['amount'] as double;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['label'], style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8))),
                Text(
                  '₹ ${amt.abs().toStringAsFixed(2)}',
                  style: TextStyle(color: amt >= 0 ? Colors.green[300] : Colors.red[300]),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String title, double amount, {bool isHighlight = false, bool isFinal = false}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isFinal ? (amount >= 0 ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: isFinal ? Border.all(color: amount >= 0 ? Colors.green : Colors.red) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isFinal ? 18 : 16)),
          Text(
            '₹ ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isFinal ? 20 : 16,
              color: amount >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
