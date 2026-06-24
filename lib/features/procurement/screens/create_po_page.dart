import 'package:flutter/material.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

class CreatePoPage extends StatefulWidget {
  const CreatePoPage({super.key});

  @override
  State<CreatePoPage> createState() => _CreatePoPageState();
}

class _CreatePoPageState extends State<CreatePoPage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedSupplier;
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _moistureCtrl = TextEditingController();
  String? _grade = 'A';
  
  final _vehicleCtrl = TextEditingController();
  final _driverCtrl = TextEditingController();
  final _freightCtrl = TextEditingController();
  
  final _advanceCtrl = TextEditingController();

  double get _totalAmount {
    final q = double.tryParse(_qtyCtrl.text) ?? 0;
    final p = double.tryParse(_priceCtrl.text) ?? 0;
    return q * p;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose(); _priceCtrl.dispose(); _moistureCtrl.dispose();
    _vehicleCtrl.dispose(); _driverCtrl.dispose(); _freightCtrl.dispose();
    _advanceCtrl.dispose();
    super.dispose();
  }

  void _savePo() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a supplier')));
      return;
    }

    ConfirmationDialog.show(
      context,
      title: 'Confirm Purchase Order',
      icon: Icons.receipt_long_rounded,
      fields: [
        ConfirmField(label: 'Supplier', value: _selectedSupplier!),
        ConfirmField(label: 'Quantity', value: '${_qtyCtrl.text} kg'),
        ConfirmField(label: 'Rate', value: '₹${_priceCtrl.text} /kg'),
        ConfirmField(label: 'Total Amount', value: '₹${_totalAmount.toStringAsFixed(2)}', isBold: true, valueColor: Theme.of(context).colorScheme.primary),
        if (_advanceCtrl.text.isNotEmpty) ConfirmField(label: 'Advance Paid', value: '₹${_advanceCtrl.text}'),
      ],
      confirmLabel: 'Create PO',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Order created successfully')));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Purchase Order'),
        actions: [
          TextButton.icon(
            onPressed: _savePo,
            icon: const Icon(Icons.check),
            label: const Text('Save PO'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(theme, 'Supplier Info'),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Supplier *', prefixIcon: Icon(Icons.store_outlined)),
                    value: _selectedSupplier,
                    items: ['Rajan Cashew Farm', 'Global Nuts Exporters', 'Shreeji Traders']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _selectedSupplier = v),
                  ),
                  
                  const SizedBox(height: 24),
                  _sectionTitle(theme, 'RCN Details'),
                  if (isWide)
                    Row(
                      children: [
                        Expanded(child: _buildRcnFields(context)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildRcnTotals(theme)),
                      ],
                    )
                  else ...[
                    _buildRcnFields(context),
                    const SizedBox(height: 16),
                    _buildRcnTotals(theme),
                  ],

                  const SizedBox(height: 24),
                  _sectionTitle(theme, 'Logistics (Optional)'),
                  if (isWide)
                    Row(
                      children: [
                        Expanded(child: _textField(_vehicleCtrl, 'Vehicle Number', Icons.local_shipping_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(_driverCtrl, 'Driver Contact', Icons.phone_android_outlined)),
                      ],
                    )
                  else ...[
                    _textField(_vehicleCtrl, 'Vehicle Number', Icons.local_shipping_outlined),
                    _textField(_driverCtrl, 'Driver Contact', Icons.phone_android_outlined),
                  ],
                  _textField(_freightCtrl, 'Freight Cost (₹)', Icons.currency_rupee_outlined, isNumber: true),

                  const SizedBox(height: 24),
                  _sectionTitle(theme, 'Payments & Advances'),
                  _textField(_advanceCtrl, 'Advance Payment (₹)', Icons.account_balance_wallet_outlined, isNumber: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRcnFields(BuildContext context) {
    return Column(
      children: [
        _textField(_qtyCtrl, 'Quantity (kg) *', Icons.scale_outlined, isNumber: true, req: true, onChanged: (_) => setState((){})),
        _textField(_priceCtrl, 'Price per kg (₹) *', Icons.sell_outlined, isNumber: true, req: true, onChanged: (_) => setState((){})),
        _textField(_moistureCtrl, 'Moisture %', Icons.water_drop_outlined, isNumber: true),
        DropdownButtonFormField<String>(
          value: _grade,
          decoration: const InputDecoration(labelText: 'Expected Grade', prefixIcon: Icon(Icons.grade_outlined)),
          items: ['A', 'B', 'C'].map((g) => DropdownMenuItem(value: g, child: Text('Grade $g'))).toList(),
          onChanged: (v) => setState(() => _grade = v),
        ),
      ],
    );
  }

  Widget _buildRcnTotals(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total PO Value', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '₹${_totalAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calculated based on:'),
              Text('${_qtyCtrl.text.isEmpty ? '0' : _qtyCtrl.text} kg × ₹${_priceCtrl.text.isEmpty ? '0' : _priceCtrl.text}'),
            ],
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, IconData icon, {bool req = false, bool isNumber = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: req ? (v) => v == null || v.isEmpty ? 'Required field' : null : null,
      ),
    );
  }
}
