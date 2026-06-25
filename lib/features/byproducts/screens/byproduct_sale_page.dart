import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class ByproductSalePage extends StatefulWidget {
  const ByproductSalePage({super.key});

  @override
  State<ByproductSalePage> createState() => _ByproductSalePageState();
}

class _ByproductSalePageState extends State<ByproductSalePage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'CNSL (Oil)';
  double _qty = 0;
  double _rate = 0;
  String _buyer = 'Apex Chemicals';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final total = _qty * _rate;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Sale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Byproduct: $_type'),
              Text('Buyer: $_buyer'),
              Text('Quantity: $_qty ${ _type == 'CNSL (Oil)' ? 'L' : 'kg' }'),
              Text('Rate: ₹$_rate'),
              const Divider(),
              Text('Total Value: ₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 16),
              const Text('This will auto-create a ledger entry.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale recorded successfully')));
                context.pop();
              },
              child: const Text('Confirm Sale'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell Byproduct')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Byproduct Type'),
              items: ['Cashew Shells', 'CNSL (Oil)', 'Testa (Husk)']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _buyer,
              decoration: const InputDecoration(labelText: 'Buyer'),
              items: ['Apex Chemicals', 'Local Fuel Traders', 'Agro Feeds Ltd']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _buyer = v!),
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: _type == 'CNSL (Oil)' ? 'Quantity (Litres)' : 'Quantity (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => _qty = double.tryParse(v!) ?? 0,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Rate (₹)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => _rate = double.tryParse(v!) ?? 0,
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.point_of_sale),
                label: const Text('Record Sale'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
