import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../providers/supplier_provider.dart';

class AddSupplierPage extends ConsumerStatefulWidget {
  const AddSupplierPage({super.key});

  @override
  ConsumerState<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends ConsumerState<AddSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _acctNoCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose(); _locationCtrl.dispose(); _contactCtrl.dispose();
    _phoneCtrl.dispose(); _bankNameCtrl.dispose(); _acctNoCtrl.dispose();
    _ifscCtrl.dispose();
    super.dispose();
  }

  void _saveSupplier() {
    if (!_formKey.currentState!.validate()) return;

    // Show Confirmation Dialog before saving to database
    ConfirmationDialog.show(
      context,
      title: 'Create Supplier',
      icon: Icons.store_rounded,
      fields: [
        ConfirmField(label: 'Name', value: _nameCtrl.text),
        ConfirmField(label: 'Location', value: _locationCtrl.text),
        ConfirmField(label: 'Contact', value: '${_contactCtrl.text} (${_phoneCtrl.text})'),
        ConfirmField(label: 'Bank A/C', value: 'XXXX XXXX ${_acctNoCtrl.text.length > 4 ? _acctNoCtrl.text.substring(_acctNoCtrl.text.length - 4) : _acctNoCtrl.text} (Encrypted)'),
      ],
      confirmLabel: 'Save Supplier',
      onConfirm: () async {
        final success = await ref.read(supplierProvider.notifier).addSupplier({
          'name': _nameCtrl.text,
          'location': _locationCtrl.text,
          'contactPerson': _contactCtrl.text,
          'phone': _phoneCtrl.text,
          'bankName': _bankNameCtrl.text,
          'accountNumber': _acctNoCtrl.text,
          'ifsc': _ifscCtrl.text,
        });

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier created successfully')));
            Navigator.pop(context); // close dialog
            Navigator.pop(context); // pop page
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create supplier')));
            Navigator.pop(context); // close dialog
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Supplier'),
        actions: [
          TextButton.icon(
            onPressed: _saveSupplier,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
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
                  _sectionTitle(theme, 'Basic Information'),
                  _textField(_nameCtrl, 'Supplier Name *', Icons.store_outlined, req: true),
                  _textField(_locationCtrl, 'Location (City, State) *', Icons.location_on_outlined, req: true),
                  
                  const SizedBox(height: 24),
                  _sectionTitle(theme, 'Contact Details'),
                  if (isWide)
                    Row(
                      children: [
                        Expanded(child: _textField(_contactCtrl, 'Contact Person', Icons.person_outline)),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(_phoneCtrl, 'Phone Number *', Icons.phone_outlined, req: true)),
                      ],
                    )
                  else ...[
                    _textField(_contactCtrl, 'Contact Person', Icons.person_outline),
                    _textField(_phoneCtrl, 'Phone Number *', Icons.phone_outlined, req: true),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _sectionTitle(theme, 'Bank Details (Encrypted) '),
                      const Icon(Icons.lock, size: 16, color: Color(0xFF00E676)),
                    ],
                  ),
                  const Text('These details will be stored securely using AES-256-GCM encryption.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  _textField(_bankNameCtrl, 'Bank Name', Icons.account_balance_outlined),
                  if (isWide)
                    Row(
                      children: [
                        Expanded(child: _textField(_acctNoCtrl, 'Account Number', Icons.numbers)),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(_ifscCtrl, 'IFSC Code', Icons.password)),
                      ],
                    )
                  else ...[
                    _textField(_acctNoCtrl, 'Account Number', Icons.numbers),
                    _textField(_ifscCtrl, 'IFSC Code', Icons.password),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, IconData icon, {bool req = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: req ? (v) => v == null || v.isEmpty ? 'Required field' : null : null,
      ),
    );
  }
}
