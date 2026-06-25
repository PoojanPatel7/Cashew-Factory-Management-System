import 'package:flutter/material.dart';

class PriceListPage extends StatelessWidget {
  const PriceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Price List'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: () {
            _showConfirmationDialog(context);
          }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Standard Selling Prices (₹ per kg)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPriceRow('W320 (Premium)', '750.00'),
          _buildPriceRow('W240 (Jumbo)', '850.00'),
          _buildPriceRow('W210 (Super Jumbo)', '950.00'),
          _buildPriceRow('W450 (Standard)', '650.00'),
          _buildPriceRow('Splits (LWP)', '450.00'),
          _buildPriceRow('Pieces (SWP)', '300.00'),
          _buildPriceRow('Baby Bits (BB)', '200.00'),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String grade, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(grade, style: const TextStyle(fontWeight: FontWeight.bold))),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: price,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Price Changes'),
        content: const Text('Are you sure you want to update the standard price list? New sales orders will use these prices.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prices updated successfully')));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
