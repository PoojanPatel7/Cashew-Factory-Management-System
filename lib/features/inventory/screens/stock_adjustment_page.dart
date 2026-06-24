import 'package:flutter/material.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

class StockAdjustmentPage extends StatefulWidget {
  const StockAdjustmentPage({super.key});

  @override
  State<StockAdjustmentPage> createState() => _StockAdjustmentPageState();
}

class _StockAdjustmentPageState extends State<StockAdjustmentPage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedItem;
  String? _adjustmentType = 'Addition';
  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _saveAdjustment() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an item')));
      return;
    }

    final isAddition = _adjustmentType == 'Addition';
    final color = isAddition ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final sign = isAddition ? '+' : '-';

    ConfirmationDialog.show(
      context,
      title: 'Confirm Stock Adjustment',
      icon: Icons.sync_alt_rounded,
      fields: [
        ConfirmField(label: 'Item', value: _selectedItem!),
        ConfirmField(label: 'Type', value: _adjustmentType!, isBold: true, valueColor: color),
        ConfirmField(label: 'Quantity', value: '$sign${_qtyCtrl.text}', isBold: true, valueColor: color),
        ConfirmField(label: 'Reason', value: _reasonCtrl.text),
      ],
      confirmLabel: 'Confirm Adjustment',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock adjusted successfully')));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Adjustment'),
        actions: [
          TextButton.icon(
            onPressed: _saveAdjustment,
            icon: const Icon(Icons.check),
            label: const Text('Apply'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9100).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFFF9100)),
                        SizedBox(width: 12),
                        Expanded(child: Text('Stock adjustments bypass standard procurement/processing flows. All adjustments are logged and audited.', style: TextStyle(color: Color(0xFFFF9100), fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Item *', prefixIcon: Icon(Icons.inventory_2_outlined)),
                    value: _selectedItem,
                    items: [
                      'RCN-24-001 - Raw Cashew Nut (Benin)',
                      'W320-L12 - Cashew Kernel - W320',
                      'PKG-TIN-10 - 10kg Tin Container',
                    ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _selectedItem = v),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Adjustment Type *', prefixIcon: Icon(Icons.sync_alt)),
                    value: _adjustmentType,
                    items: ['Addition', 'Deduction'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _adjustmentType = v),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _reasonCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Adjustment *',
                      hintText: 'e.g. Damage, Audit correction, Physical counting mismatch',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
