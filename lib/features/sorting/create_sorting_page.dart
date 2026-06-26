import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/stock_providers.dart';

class CreateSortingPage extends ConsumerStatefulWidget {
  const CreateSortingPage({super.key});

  @override
  ConsumerState<CreateSortingPage> createState() => _CreateSortingPageState();
}

class _CreateSortingPageState extends ConsumerState<CreateSortingPage> {
  // Map of rawStockId to the weight entered by the user
  final Map<String, double> _selectedRawStocks = {};
  final Map<String, TextEditingController> _rawStockWeightCtrls = {};
  final _noteCtrl = TextEditingController();
  final List<_LotRow> _lots = [];
  final _formKey = GlobalKey<FormState>();

  final _categories = ['W180', 'W240', 'W320', 'W450', 'Splits', 'Broken', 'Baby Bits', 'Other'];

  @override
  void initState() {
    super.initState();
    _addLot();
  }

  void _addLot() {
    setState(() {
      _lots.add(_LotRow(
        nameCtrl: TextEditingController(),
        weightCtrl: TextEditingController(),
        category: 'W240',
      ));
    });
  }

  void _removeLot(int index) {
    setState(() {
      _lots[index].nameCtrl.dispose();
      _lots[index].weightCtrl.dispose();
      _lots.removeAt(index);
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    for (var l in _lots) {
      l.nameCtrl.dispose();
      l.weightCtrl.dispose();
    }
    for (var c in _rawStockWeightCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  double get _lotWeightSum {
    double sum = 0;
    for (var lot in _lots) {
      sum += double.tryParse(lot.weightCtrl.text) ?? 0;
    }
    return sum;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedRawStocks.isEmpty) {
      _snack('Enter weight for at least one raw stock first');
      return;
    }
    final totalWeight = _selectedRawStocks.values.fold<double>(0, (sum, w) => sum + w);
    if (totalWeight <= 0) {
      _snack('Total raw stock weight must be > 0');
      return;
    }
    if (_lots.isEmpty) {
      _snack('Add at least one lot');
      return;
    }

    // Validate lot weights
    final lotData = <Map<String, dynamic>>[];
    for (var lot in _lots) {
      final w = double.tryParse(lot.weightCtrl.text) ?? 0;
      if (w <= 0) {
        _snack('All lots must have weight > 0');
        return;
      }
      lotData.add({
        'name': lot.nameCtrl.text.isEmpty ? lot.category : lot.nameCtrl.text,
        'category': lot.category,
        'initialWeight': w,
      });
    }

    final sum = lotData.fold<double>(0, (s, l) => s + (l['initialWeight'] as double));
    if ((sum - totalWeight).abs() > 0.5) {
      _snack('Lot weights (${sum.toStringAsFixed(1)} kg) must equal total (${totalWeight.toStringAsFixed(1)} kg)');
      return;
    }

    // Submit
    final ok = await ref.read(sortingProvider.notifier).create({
      'rawStocks': _selectedRawStocks.entries.map((e) => {'id': e.key, 'weight': e.value}).toList(),
      'totalWeight': totalWeight,
      'lots': lotData,
      'note': _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
    });

    if (mounted) {
      if (ok) {
        _snack('✅ Sorting saved! ${lotData.length} lots created');
        ref.read(rawStockProvider.notifier).fetch();
        ref.invalidate(dashboardProvider);
        ref.read(lotsProvider.notifier).fetch();
        context.go('/sorting');
      } else {
        _snack('❌ Failed to save sorting');
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final rawState = ref.watch(rawStockProvider);
    final theme = Theme.of(context);
    final totalWeight = _selectedRawStocks.values.fold<double>(0, (sum, w) => sum + w);
    final lotSum = _lotWeightSum;
    final diff = totalWeight - lotSum;

    return Scaffold(
      appBar: AppBar(title: const Text('Start Sorting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Select raw stock
                  Text('Step 1: Select Raw Stock', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  rawState.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (data) {
                    final stocks = (data['stocks'] as List<dynamic>?) ?? [];
                    final available = stocks.where((s) {
                      final w = (s['weight'] as num).toDouble();
                      final u = (s['usedWeight'] as num).toDouble();
                      return (w - u) > 0.1;
                    }).toList();

                    if (available.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('No raw stock available. Add stock first.', style: TextStyle(color: theme.colorScheme.error)),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: available.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final s = available[i];
                          final id = s['id'] as String;
                          final w = (s['weight'] as num).toDouble();
                          final u = (s['usedWeight'] as num).toDouble();
                          final avail = w - u;
                          final name = s['name'] ?? 'Un-named Batch';
                          final date = (s['date'] ?? '').toString().split('T').first;
                          final isSelected = _selectedRawStocks.containsKey(id);

                          if (!_rawStockWeightCtrls.containsKey(id)) {
                            _rawStockWeightCtrls[id] = TextEditingController();
                          }
                          final ctrl = _rawStockWeightCtrls[id]!;

                          return ListTile(
                            title: Text('$name', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('$date — $avail kg available'),
                            trailing: SizedBox(
                              width: 120,
                              child: TextFormField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0 kg',
                                  suffixText: 'kg',
                                  filled: true,
                                  fillColor: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                validator: (v) {
                                  if (v != null && v.isNotEmpty) {
                                    final w = double.tryParse(v);
                                    if (w == null) return 'Invalid';
                                    if (w < 0) return 'Must be >= 0';
                                    if (w > avail + 0.01) return 'Max ${avail.toStringAsFixed(1)}';
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  final w = double.tryParse(val) ?? 0;
                                  setState(() {
                                    if (w > 0 && w <= avail + 0.01) {
                                      _selectedRawStocks[id] = w;
                                    } else {
                                      _selectedRawStocks.remove(id);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                if (totalWeight > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Raw Weight to Sort:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${totalWeight.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                // Step 2: Add lots
                Row(
                  children: [
                    Expanded(child: Text('Step 2: Create Lots', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                    TextButton.icon(
                      onPressed: _addLot,
                      icon: const Icon(Icons.add_circle_rounded),
                      label: const Text('Add Lot'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ..._lots.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final lot = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Lot ${idx + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                              ),
                              const Spacer(),
                              if (_lots.length > 1)
                                IconButton(
                                  icon: Icon(Icons.close_rounded, color: theme.colorScheme.error, size: 20),
                                  onPressed: () => _removeLot(idx),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: lot.nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Lot Name (optional)',
                              hintText: 'e.g. Large Grade A',
                              prefixIcon: Icon(Icons.label_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: lot.category,
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => lot.category = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: lot.weightCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    labelText: 'Weight',
                                    suffixText: 'kg',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Required';
                                    final w = double.tryParse(v);
                                    if (w == null) return 'Invalid';
                                    if (w <= 0) return '> 0';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Weight balance indicator
                if (totalWeight > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: diff.abs() < 0.5 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: diff.abs() < 0.5 ? Colors.green : Colors.red),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lot Total: ${lotSum.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          diff.abs() < 0.5 ? '✅ Balanced' : '${diff > 0 ? "Remaining" : "Over"}: ${diff.abs().toStringAsFixed(1)} kg',
                          style: TextStyle(fontWeight: FontWeight.bold, color: diff.abs() < 0.5 ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.note_rounded)),
                ),

                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Save Sorting'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

}

class _LotRow {
  final TextEditingController nameCtrl;
  final TextEditingController weightCtrl;
  String category;

  _LotRow({required this.nameCtrl, required this.weightCtrl, required this.category});
}
