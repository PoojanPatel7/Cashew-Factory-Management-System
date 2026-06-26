import 'package:flutter/material.dart';
import '../../core/utils/date_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/stock_providers.dart';
import '../../shared/widgets/logout_action.dart';

class FinishedStockScreen extends ConsumerWidget {
  const FinishedStockScreen({super.key});

  static const _stages = ['CLEANING', 'BOILING', 'COOLING', 'SHELLING', 'DRYING', 'PEELING', 'GRADING', 'PACKING'];
  static const _stageLabels = {
    'CLEANING': 'Clean', 'BOILING': 'Boil', 'COOLING': 'Cool',
    'SHELLING': 'Shell', 'DRYING': 'Dry', 'PEELING': 'Peel',
    'GRADING': 'Grade', 'PACKING': 'Pack',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(finishedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text('✅ Finished Stock', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 0.5)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.refresh(finishedProvider)),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final stocks = (data['stocks'] as List<dynamic>?) ?? [];
          final totalPacked = (data['totalPacked'] as num?)?.toDouble() ?? 0;
          final totalDispatched = (data['totalDispatched'] as num?)?.toDouble() ?? 0;
          final available = (data['available'] as num?)?.toDouble() ?? 0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade500]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('Ready to Sell', style: TextStyle(color: Colors.white60, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('${available.toStringAsFixed(1)} kg',
                            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _summaryPill('Total Packed', '${totalPacked.toStringAsFixed(1)} kg'),
                            _summaryPill('Dispatched', '${totalDispatched.toStringAsFixed(1)} kg'),
                          ],
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
                                        child: Icon(Icons.check_circle_rounded, size: 64, color: theme.colorScheme.primary),
                                      ),
                                      const SizedBox(height: 24),
                                      Text('No finished stock yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Complete processing to see packed cashew here', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
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
                              if (i == stocks.length) return _buildPageGuide(context);

                              final fs = stocks[i] as Map<String, dynamic>;
                              final lot = fs['lot'] as Map<String, dynamic>? ?? {};
                              final packed = (fs['packedWeight'] as num).toDouble();
                              final dispatched = (fs['dispatched'] as num).toDouble();
                              final avail = packed - dispatched;

                              final finDate = formatFirebaseDate(fs['completedAt'], 'MMM dd, hh:mm a');

                              // Get sorting info from the finished stock
                              final sorting = fs['sorting'] ?? lot['sorting'] ?? {};
                              final rsList = sorting['rawStocks'] as List?;
                              String rsName = 'Unknown Raw Stock';
                              if (rsList != null && rsList.isNotEmpty) {
                                rsName = rsList.map((r) => r['rawStock']?['name'] ?? 'Unknown').join(', ');
                              } else if (sorting['rawStock'] != null) {
                                rsName = sorting['rawStock']['name'] ?? 'Unknown';
                              }

                              final initial = (lot['initialWeight'] as num?)?.toDouble() ?? 0;
                              final yieldPct = initial > 0 ? (packed / initial) * 100 : 0.0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
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
                                  onTap: () {
                                    if (fs['lotId'] != null) context.push('/processing/${fs['lotId']}');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header row
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(lot['name'] ?? 'Finished Lot',
                                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.withValues(alpha: 0.15),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text('Completed',
                                                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.inventory_2_rounded, size: 14, color: theme.colorScheme.outline),
                                                      const SizedBox(width: 6),
                                                      Expanded(child: Text('From: $rsName', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                                    ],
                                                  ),
                                                  if (finDate.isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.outline),
                                                        const SizedBox(width: 6),
                                                        Text('Completed: $finDate', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 16),

                                        // Info chips
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: [
                                            if (lot['category'] != null && lot['category'].toString().isNotEmpty)
                                              _infoChip(context, Icons.category_rounded, lot['category']),
                                            _infoChip(context, Icons.scale_rounded, 'In: ${initial.toStringAsFixed(1)} kg'),
                                            _infoChip(context, Icons.shopping_bag_rounded, 'Out: ${packed.toStringAsFixed(1)} kg'),
                                            _infoChip(context, Icons.pie_chart_rounded, 'Yield: ${yieldPct.toStringAsFixed(1)}%'),
                                          ],
                                        ),

                                        const SizedBox(height: 20),

                                        // Completed pipeline (all green)
                                        _buildCompletedPipeline(),

                                        const Divider(height: 24),

                                        // Stats
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _stat('Packed', '${packed.toStringAsFixed(1)} kg'),
                                            _stat('Dispatched', '${dispatched.toStringAsFixed(1)} kg'),
                                            _stat('Available', '${avail.toStringAsFixed(1)} kg', highlight: true),
                                          ],
                                        ),

                                        // Dispatch/Transfer buttons
                                        if (avail >= 0) ...[
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                                  onPressed: () => _showFullInfoDialog(context, fs, lot, rsName),
                                                  icon: const Icon(Icons.info_outline_rounded),
                                                  label: const Text('Full Info'),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          if (avail > 0)
                                            Row(
                                            children: [
                                              Expanded(
                                                child: FilledButton.icon(
                                                  style: FilledButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(vertical: 12)),
                                                  onPressed: () => _showDispatchSheet(context, ref, fs['id'], avail),
                                                  icon: const Icon(Icons.local_shipping_rounded),
                                                  label: const Text('Dispatch', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                                  onPressed: () => _showTransferDialog(context, ref, fs['id']),
                                                  icon: const Icon(Icons.swap_horiz_rounded),
                                                  label: const Text('Transfer'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
    );
  }

  void _showFullInfoDialog(BuildContext context, Map<String, dynamic> fs, Map<String, dynamic> lot, String rsName) {
    final theme = Theme.of(context);
    final sorting = fs['sorting'] ?? lot['sorting'] ?? {};
    final sortDate = formatFirebaseDate(sorting['date'] ?? sorting['createdAt'], 'MMM dd, yyyy - hh:mm a');
    final startDate = formatFirebaseDate(lot['createdAt'], 'MMM dd, yyyy - hh:mm a');
    final finDate = formatFirebaseDate(fs['completedAt'], 'MMM dd, yyyy - hh:mm a');
    
    final steps = (lot['steps'] as List<dynamic>?) ?? [];
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${lot['name'] ?? 'Finished Lot'} - Full Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Raw Stock Info', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Batches: $rsName'),
              Text('Sorted On: $sortDate'),
              const Divider(height: 24),
              Text('Processing Timeline', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Started: $startDate'),
              Text('Completed: $finDate'),
              const SizedBox(height: 12),
              ...steps.map((step) {
                final sName = _stageLabels[step['stageName']] ?? step['stageName'];
                final sDate = formatFirebaseDate(step['completedAt'] ?? step['createdAt'] ?? step['updatedAt'], 'MMM dd, hh:mm a');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('$sName: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(sDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildCompletedPipeline() {
    return Column(
      children: [
        Row(
          children: List.generate(_stages.length, (i) {
            return Expanded(
              child: Container(
                height: 6,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_stageLabels[_stages.first] ?? '', style: const TextStyle(fontSize: 9, color: Colors.grey)),
            const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
            Text(_stageLabels[_stages.last] ?? '', style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _summaryPill(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _stat(String label, String value, {bool highlight = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: highlight ? Colors.green.shade700 : null)),
      ],
    );
  }

  void _showDispatchSheet(BuildContext context, WidgetRef ref, String finishedStockId, double available) {
    final weightCtrl = TextEditingController();
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
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Dispatch Stock', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Available: ${available.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 16, color: Colors.green.shade700)),
              const SizedBox(height: 20),
              TextFormField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Dispatch Weight (kg)',
                  prefixIcon: Icon(Icons.local_shipping_rounded),
                  suffixText: 'kg',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter weight';
                  final w = double.tryParse(v);
                  if (w == null || w <= 0) return 'Enter valid number';
                  if (w > available + 0.01) return 'Max ${available.toStringAsFixed(1)} kg';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g. Buyer name, destination',
                  prefixIcon: Icon(Icons.note_rounded),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final w = double.parse(weightCtrl.text);
                  Navigator.pop(ctx);
                  final ok = await ref.read(finishedProvider.notifier).dispatch(finishedStockId, w, noteCtrl.text.isEmpty ? null : noteCtrl.text);
                  if (context.mounted) {
                    ref.invalidate(dashboardProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? '✅ Dispatched $w kg' : '❌ Failed to dispatch')),
                    );
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text('Confirm Dispatch'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context, WidgetRef ref, String finishedStockId) {
    String? selectedFactoryId;
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Transfer Finished Stock'),
            content: FutureBuilder<List<Map<String, dynamic>>>(
              future: ref.read(factoriesListProvider.future),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) return const Text('Failed to load factories');
                final factories = snapshot.data ?? [];
                if (factories.isEmpty) return const Text('No factories available');

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('This will transfer the entire remaining stock to the selected factory.'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Target Factory'),
                      value: selectedFactoryId,
                      items: factories.map((f) {
                        return DropdownMenuItem<String>(value: f['id'] as String, child: Text(f['name'] as String));
                      }).toList(),
                      onChanged: (val) => setState(() => selectedFactoryId = val),
                      validator: (v) => v == null ? 'Select a factory' : null,
                    ),
                    if (loading) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                );
              },
            ),
            actions: [
              TextButton(onPressed: loading ? null : () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: (loading || selectedFactoryId == null)
                    ? null
                    : () async {
                        setState(() => loading = true);
                        final ok = await ref.read(finishedProvider.notifier).transferFinishedStock(finishedStockId, selectedFactoryId!);
                        if (ctx.mounted) {
                          setState(() => loading = false);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'Transfer successful' : 'Transfer failed')),
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
              Text('How to use Finished Stock', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• The Finished Stock page tracks fully processed cashew ready for sale.\n'
            '• Tap "Dispatch" to remove weight from inventory when selling to a buyer.\n'
            '• Tap "Transfer" to move available stock to another factory.\n'
            '• Tap "Full Info" to view the complete history of this lot, from raw stock source through all processing stages.',
            style: TextStyle(height: 1.5, color: cs.onSecondaryContainer.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
