import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_providers.dart';
import '../auth/providers/auth_provider.dart';
import '../../shared/widgets/logout_action.dart';

class RawStockScreen extends ConsumerStatefulWidget {
  const RawStockScreen({super.key});

  @override
  ConsumerState<RawStockScreen> createState() => _RawStockScreenState();
}

class _RawStockScreenState extends ConsumerState<RawStockScreen> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rawStockProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: _selectedIds.isNotEmpty 
          ? Text('${_selectedIds.length} Selected', style: const TextStyle(fontWeight: FontWeight.bold)) 
          : const Text('📦 Raw Stock', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 0.5)),
        actions: [
          if (_selectedIds.length >= 2)
            IconButton(
              icon: const Icon(Icons.call_merge_rounded),
              tooltip: 'Merge Selected',
              onPressed: () => _showMergeDialog(context, ref),
            ),
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() => _selectedIds.clear()),
            ),
          if (_selectedIds.isEmpty)
            IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.refresh(rawStockProvider)),
          if (_selectedIds.isEmpty)
            const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          var stocks = (data['stocks'] as List<dynamic>?) ?? [];
          stocks = stocks.where((s) => ((s['weight'] as num) - ((s['usedWeight'] ?? 0) as num)) > 0).toList();
          final totalRaw = (data['totalRaw'] as num?)?.toDouble() ?? 0;
          final available = (data['available'] as num?)?.toDouble() ?? 0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  // Header summary
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade700, Colors.deepOrange.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Available Raw Stock', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 16),
                              Text('${available.toStringAsFixed(1)} kg',
                                  style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, height: 1.1)),
                              const SizedBox(height: 8),
                              Text('Total received: ${totalRaw.toStringAsFixed(1)} kg',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 48),
                        ),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: stocks.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              SizedBox(
                                height: 300,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.inbox_rounded, size: 64, color: theme.colorScheme.primary),
                                      ),
                                      const SizedBox(height: 24),
                                      Text('No raw stock entries yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Tap + to add your first batch of raw cashew stock', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                                    ],
                                  ),
                                ),
                              ),
                              _buildPageGuide(context),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: stocks.length + 1,
                            itemBuilder: (ctx, i) {
                              if (i == stocks.length) {
                                return _buildPageGuide(context);
                              }

                              final s = stocks[i] as Map<String, dynamic>;
                              final w = (s['weight'] as num).toDouble();
                              final used = (s['usedWeight'] as num).toDouble();
                              final remaining = w - used;
                              final date = (s['date'] ?? '').toString().split('T').first;
                              final name = s['name'] ?? 'Un-named Batch';
                              final note = s['note']?.toString();
                              final sortings = (s['sortings'] as List?)?.length ?? 0;
                              final isSelected = _selectedIds.contains(s['id']);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.1),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onLongPress: () {
                                    setState(() {
                                      if (isSelected) _selectedIds.remove(s['id']);
                                      else _selectedIds.add(s['id']);
                                    });
                                  },
                                  onTap: () {
                                    if (_selectedIds.isNotEmpty) {
                                      setState(() {
                                        if (isSelected) _selectedIds.remove(s['id']);
                                        else _selectedIds.add(s['id']);
                                      });
                                    } else {
                                      context.push('/raw-stock/${s['id']}');
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Leading Weight Indicator
                                        Container(
                                          width: 64, height: 64,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isSelected 
                                                ? [theme.colorScheme.primary, theme.colorScheme.primary]
                                                : (remaining > 0 ? [Colors.orange.shade400, Colors.orange.shade600] : [Colors.grey.shade400, Colors.grey.shade600]),
                                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              if (remaining > 0 && !isSelected)
                                                BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                                            ],
                                          ),
                                          child: Center(
                                            child: isSelected 
                                              ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32)
                                              : Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('${w.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, height: 1)),
                                                    const Text('kg', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Body
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('$name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.2)),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.inventory_2_rounded, size: 14, color: theme.colorScheme.primary),
                                                  const SizedBox(width: 4),
                                                  Text('Available: ${remaining.toStringAsFixed(1)} kg', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today_rounded, size: 14, color: theme.colorScheme.outline),
                                                  const SizedBox(width: 4),
                                                  Text(date, style: TextStyle(color: theme.colorScheme.outline, fontSize: 13)),
                                                ],
                                              ),
                                              if (note != null && note.isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.notes_rounded, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                                      const SizedBox(width: 4),
                                                      Flexible(child: Text(note, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              if (sortings > 0) ...[
                                                const SizedBox(height: 6),
                                                Text('Sorted $sortings time(s)', style: TextStyle(fontSize: 12, color: Colors.green.shade600, fontWeight: FontWeight.w600)),
                                              ],
                                            ],
                                          ),
                                        ),
                                        // Actions
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                                              tooltip: 'Edit',
                                              onPressed: () => _showEditRawStockDialog(context, ref, s),
                                            ),
                                            if (remaining > 0)
                                              IconButton(
                                                icon: const Icon(Icons.swap_horiz_rounded, color: Colors.blue),
                                                tooltip: 'Transfer',
                                                onPressed: () => _showTransferDialog(context, ref, s['id'], remaining),
                                              ),
                                            if (sortings == 0)
                                              IconButton(
                                                icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                                                tooltip: 'Delete',
                                                onPressed: () => _confirmDelete(context, ref, s['id'], w),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _selectedIds.isEmpty ? FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Stock'),
      ) : null,
    );
  }

  void _showMergeDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Merge Raw Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You are about to merge ${_selectedIds.length} batches into one.'),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'New Merged Batch Name',
                hintText: 'e.g. Merged Batch A',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final newId = await ref.read(rawStockProvider.notifier).mergeRawStock(_selectedIds.toList(), name: name.isEmpty ? null : name);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (newId != null) {
                  setState(() => _selectedIds.clear());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Batches merged successfully!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to merge batches.')));
                }
              }
            },
            child: const Text('Merge'),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final weightCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text('Add Raw Cashew Stock', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'e.g. 2000',
                  prefixIcon: Icon(Icons.scale_rounded),
                  suffixText: 'kg',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Weight is required';
                  final w = double.tryParse(v);
                  if (w == null) return 'Enter a valid number';
                  if (w <= 0) return 'Weight must be greater than 0';
                  if (w > 99999) return 'Weight too large';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Batch Name (e.g. Vendor A)',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: (v) {
                  if (v != null && v.length > 100) return 'Name too long';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g. Supplier name, batch info',
                  prefixIcon: Icon(Icons.note_rounded),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final w = double.parse(weightCtrl.text);
                  final name = nameCtrl.text.trim().isEmpty ? 'Un-named Batch' : nameCtrl.text.trim();
                  Navigator.pop(ctx);
                  final ok = await ref.read(rawStockProvider.notifier).add(w, name, noteCtrl.text.isEmpty ? null : noteCtrl.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? '✅ Added $w kg raw stock' : '❌ Failed to add'),
                    ));
                    ref.invalidate(dashboardProvider);
                  }
                },
                child: const Text('Add Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, double weight) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text('Remove ${weight.toStringAsFixed(1)} kg raw stock entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(rawStockProvider.notifier).delete(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Deleted' : 'Cannot delete — already sorted')));
                ref.invalidate(dashboardProvider);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context, WidgetRef ref, String rawStockId, double maxWeight) {
    String? selectedFactoryId;
    final weightCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Transfer Raw Stock'),
            content: FutureBuilder<List<Map<String, dynamic>>>(
              future: ref.read(factoriesListProvider.future),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Text('Failed to load factories');
                }
                final factories = snapshot.data ?? [];
                if (factories.isEmpty) {
                  return const Text('No factories available');
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Target Factory'),
                      value: selectedFactoryId,
                      items: factories.map((f) {
                        return DropdownMenuItem<String>(
                          value: f['id'] as String,
                          child: Text(f['name'] as String),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedFactoryId = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Weight to Transfer (Max: ${maxWeight.toStringAsFixed(1)} kg)',
                        suffixText: 'kg',
                      ),
                    ),
                    if (loading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: (loading || selectedFactoryId == null)
                    ? null
                    : () async {
                        final w = double.tryParse(weightCtrl.text);
                        if (w == null || w <= 0 || w > maxWeight) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Invalid weight entered')),
                          );
                          return;
                        }

                        setState(() => loading = true);
                        final ok = await ref.read(rawStockProvider.notifier).transferRawStock(
                              rawStockId,
                              selectedFactoryId!,
                              w,
                            );

                        if (ctx.mounted) {
                          setState(() => loading = false);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? 'Transfer successful' : 'Transfer failed'),
                            ),
                          );
                        }
                      },
                child: const Text('Transfer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditRawStockDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> stock) {
    final nameCtrl = TextEditingController(text: stock['name']);
    final weightCtrl = TextEditingController(text: stock['weight'].toString());
    final noteCtrl = TextEditingController(text: stock['note']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Raw Stock'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Batch Name'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightCtrl,
                  decoration: const InputDecoration(labelText: 'Total Quantity (kg)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Weight is required';
                    final w = double.tryParse(v);
                    if (w == null) return 'Enter a valid number';
                    if (w <= 0) return 'Must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Note (Optional)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final w = double.parse(weightCtrl.text);
              final ok = await ref.read(rawStockProvider.notifier).edit(
                stock['id'], w, nameCtrl.text, noteCtrl.text,
              );
              if (ok) {
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(dashboardProvider);
              } else {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Failed to update')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageGuide(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.secondaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: cs.primary),
              const SizedBox(width: 8),
              Text('How to use Raw Stock', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Tap the + button to add newly received cashew bags.\n'
            '• Tap any card to view its details and history.\n'
            '• Long press a card to select multiple batches for merging.\n'
            '• Tap the blue Transfer icon to move raw stock to a different factory.\n'
            '• To begin processing, go to the "Sort" tab.',
            style: TextStyle(height: 1.5, color: cs.onSecondaryContainer.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

