import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

/// Grade Master Page — configure cashew grades and market prices
class GradeMasterPage extends StatefulWidget {
  const GradeMasterPage({super.key});

  @override
  State<GradeMasterPage> createState() => _GradeMasterPageState();
}

class _GradeMasterPageState extends State<GradeMasterPage> {
  late List<Map<String, dynamic>> _grades;

  @override
  void initState() {
    super.initState();
    _grades = AppConstants.cashewGrades.map((g) => {
      ...g,
      'price': _demoPrice(g['code'] as String),
      'stock': _demoStock(g['code'] as String),
    }).toList();
  }

  double _demoPrice(String code) {
    final prices = {
      'W180': 1800.0, 'W210': 1400.0, 'W240': 1100.0, 'W320': 900.0,
      'W450': 700.0, 'SW': 650.0, 'SSW': 500.0, 'S': 550.0, 'B': 400.0, 'P': 350.0,
    };
    return prices[code] ?? 500.0;
  }

  double _demoStock(String code) {
    final stocks = {
      'W180': 120.0, 'W210': 340.0, 'W240': 890.0, 'W320': 1500.0,
      'W450': 450.0, 'SW': 200.0, 'SSW': 80.0, 'S': 300.0, 'B': 180.0, 'P': 250.0,
    };
    return stocks[code] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Master'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Grade'),
          ),
        ],
      ),
      body: isWide ? _buildDesktopView(theme) : _buildMobileView(theme),
    );
  }

  Widget _buildDesktopView(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cashew Kernel Grades', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Manage grade classifications and current market prices',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          DataTable(
            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surface),
            columns: const [
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Count/lb')),
              DataColumn(label: Text('Stock (kg)'), numeric: true),
              DataColumn(label: Text('Price (₹/kg)'), numeric: true),
              DataColumn(label: Text('Actions')),
            ],
            rows: _grades.map((g) => DataRow(cells: [
              DataCell(_gradeBadge(theme, g['code'])),
              DataCell(Text(g['name'])),
              DataCell(Text(g['countPerLb'])),
              DataCell(Text('${g['stock']}')),
              DataCell(Text('₹${(g['price'] as double).toStringAsFixed(0)}')),
              DataCell(
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
                  onPressed: () => _editPrice(context, g),
                ),
              ),
            ])).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _grades.length,
      itemBuilder: (ctx, i) {
        final g = _grades[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outline, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _gradeBadge(theme, g['code']),
            title: Text('${g['code']} — ${g['name']}', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (g['countPerLb'] != '-')
                  Text('${g['countPerLb']} kernels/lb', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Stock: ${g['stock']} kg', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                    const Spacer(),
                    Text('₹${(g['price'] as double).toStringAsFixed(0)}/kg',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
              onPressed: () => _editPrice(context, g),
            ),
          ),
        );
      },
    );
  }

  Widget _gradeBadge(ThemeData theme, String code) {
    return Container(
      width: 50, height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(code,
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  void _editPrice(BuildContext context, Map<String, dynamic> grade) {
    final priceCtrl = TextEditingController(text: (grade['price'] as double).toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Update Price — ${grade['code']}', style: theme.textTheme.titleLarge),
              Text(grade['name'], style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price per kg (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ConfirmationDialog.show(
                      context,
                      title: 'Update Grade Price',
                      icon: Icons.price_change,
                      fields: [
                        ConfirmField(label: 'Grade', value: '${grade['code']} — ${grade['name']}'),
                        ConfirmField(label: 'Old Price', value: '₹${(grade['price'] as double).toStringAsFixed(0)}/kg'),
                        ConfirmField(label: 'New Price', value: '₹${priceCtrl.text}/kg', isBold: true, valueColor: const Color(0xFF00E676)),
                      ],
                      onConfirm: () {
                        setState(() {
                          grade['price'] = double.tryParse(priceCtrl.text) ?? grade['price'];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Price updated successfully!')),
                        );
                      },
                    );
                  },
                  child: const Text('Update Price'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
