import 'package:flutter/material.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

class PaymentDialog extends StatefulWidget {
  final Map<String, dynamic> poData;
  const PaymentDialog({super.key, required this.poData});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  String _mode = 'Bank Transfer';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_amountCtrl.text.isEmpty) return;

    // Show Confirmation Dialog before recording payment
    ConfirmationDialog.show(
      context,
      title: 'Record Payment',
      icon: Icons.payments_outlined,
      fields: [
        ConfirmField(label: 'PO Number', value: widget.poData['id']),
        ConfirmField(label: 'Supplier', value: widget.poData['supplier']),
        ConfirmField(label: 'Amount Paying', value: '₹${_amountCtrl.text}', isBold: true, valueColor: const Color(0xFF00E676)),
        ConfirmField(label: 'Mode', value: _mode),
        if (_refCtrl.text.isNotEmpty) ConfirmField(label: 'Reference No.', value: _refCtrl.text),
      ],
      confirmLabel: 'Confirm Payment',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded successfully')));
        Navigator.pop(context); // Close Confirmation
        Navigator.pop(context); // Close Payment Dialog
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Payment'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Balance Due: ₹${widget.poData['balance']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5252))),
              const SizedBox(height: 24),
              
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _mode,
                decoration: const InputDecoration(labelText: 'Payment Mode', prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
                items: ['Bank Transfer', 'Cash', 'Cheque', 'UPI'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _mode = v!),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reference / UTR Number',
                  prefixIcon: Icon(Icons.receipt_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Review Payment')),
      ],
    );
  }
}
