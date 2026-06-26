import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../providers/stock_providers.dart';

class FactoryManagementScreen extends ConsumerStatefulWidget {
  const FactoryManagementScreen({super.key});

  @override
  ConsumerState<FactoryManagementScreen> createState() => _FactoryManagementScreenState();
}

class _FactoryManagementScreenState extends ConsumerState<FactoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _weighAtEveryStage = true;
  bool _isSaving = false;

  void _showAddFactorySheet() {
    _nameCtrl.clear();
    _weighAtEveryStage = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Factory', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Factory Name', prefixIcon: Icon(Icons.business_rounded)),
                validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Weigh at Every Processing Stage'),
                subtitle: const Text('If off, weight is only required at cleaning and packing.'),
                value: _weighAtEveryStage,
                onChanged: (v) => setState(() => _weighAtEveryStage = v),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  try {
                    await FirebaseFirestore.instance.collection('factories').add({
                      'name': _nameCtrl.text.trim(),
                      'weighAtEveryStage': _weighAtEveryStage,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ref.invalidate(globalDashboardProvider);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Factory Created!')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  } finally {
                    setState(() => _isSaving = false);
                  }
                },
                child: _isSaving ? const CircularProgressIndicator() : const Text('Create Factory'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditFactorySheet(Map<String, dynamic> factoryData) {
    _nameCtrl.text = factoryData['name'];
    _weighAtEveryStage = factoryData['weighAtEveryStage'] ?? true;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Factory', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Factory Name', prefixIcon: Icon(Icons.business_rounded)),
                    validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Weigh at Every Processing Stage'),
                    subtitle: const Text('If off, weight is only required at cleaning and packing.'),
                    value: _weighAtEveryStage,
                    onChanged: (v) => setSheetState(() => _weighAtEveryStage = v),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setSheetState(() => _isSaving = true);
                      try {
                        await FirebaseFirestore.instance.collection('factories').doc(factoryData['id']).update({
                          'name': _nameCtrl.text.trim(),
                          'weighAtEveryStage': _weighAtEveryStage,
                        });
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ref.invalidate(globalDashboardProvider);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Factory Updated!')));
                        }
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        setSheetState(() => _isSaving = false);
                      }
                    },
                    child: _isSaving ? const CircularProgressIndicator() : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteFactory(String id, String name) async {
    final confirm = await ConfirmationDialog.showDelete(
      context,
      itemName: 'Factory',
      details: name,
      onConfirm: () {},
    );
    if (confirm && mounted) {
      try {
        await FirebaseFirestore.instance.collection('factories').doc(id).delete();
        ref.invalidate(globalDashboardProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Factory deleted')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardAsync = ref.watch(globalDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text('All Factories Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 0.5)),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final global = data['global'] ?? {};
          final factories = (data['factories'] as List?) ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildMetricCard(context, 'Global Raw Stock', '${global['rawAvailable']?.toStringAsFixed(1) ?? 0} / ${global['rawTotal']?.toStringAsFixed(1) ?? 0} kg', Icons.inventory_2_outlined, Colors.brown),
                      const SizedBox(height: 12),
                      _buildMetricCard(context, 'Active Processing', '${global['processingWeight']?.toStringAsFixed(1) ?? 0} kg', Icons.autorenew_rounded, Colors.orange),
                      const SizedBox(height: 12),
                      _buildMetricCard(context, 'Total Finished Output', '${global['finishedTotal']?.toStringAsFixed(1) ?? 0} kg', Icons.check_circle_outline_rounded, Colors.green),
                      const SizedBox(height: 12),
                      _buildMetricCard(context, 'Global Performance', 'Yield: ${global['yieldPct']?.toStringAsFixed(1) ?? 0}% | Wastage: ${global['wastage']?.toStringAsFixed(1) ?? 0} kg', Icons.analytics_outlined, Colors.purple),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Factory Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              if (factories.isEmpty)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('No factories found.'))))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final f = factories[i];
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
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(Icons.factory_rounded, color: theme.colorScheme.onPrimaryContainer, size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(f['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.scale_rounded, size: 14, color: theme.colorScheme.outline),
                                              const SizedBox(width: 6),
                                              Text('Weigh Every Stage: ${f['weighAtEveryStage'] == true ? 'Yes' : 'No'}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit_rounded, color: theme.colorScheme.primary),
                                          onPressed: () => _showEditFactorySheet(f),
                                          tooltip: 'Edit Factory',
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                                          onPressed: () => _deleteFactory(f['id'], f['name']),
                                          tooltip: 'Delete Factory',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Divider(height: 1),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 32,
                                  runSpacing: 20,
                                  alignment: WrapAlignment.start,
                                  children: [
                                    _buildFactoryMetric('Raw Stock', '${f['rawAvailable']?.toStringAsFixed(1) ?? 0} / ${f['rawTotal']?.toStringAsFixed(1) ?? 0} kg', Colors.brown, Icons.inventory_2_rounded),
                                    _buildFactoryMetric('Processing', '${f['processingWeight']?.toStringAsFixed(1) ?? 0} kg', Colors.orange, Icons.autorenew_rounded),
                                    _buildFactoryMetric('Outcome (Finished)', '${f['finishedTotal']?.toStringAsFixed(1) ?? 0} kg', Colors.green, Icons.check_circle_rounded),
                                    _buildFactoryMetric('Yield', '${f['yieldPct']?.toStringAsFixed(1) ?? 0}%', Colors.blue, Icons.pie_chart_rounded),
                                    _buildFactoryMetric('Wastage', '${f['wastage']?.toStringAsFixed(1) ?? 0} kg', Colors.red, Icons.delete_outline_rounded),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: factories.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildPageGuide(context),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFactorySheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Factory'),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactoryMetric(String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ],
        ),
      ],
    );
  }

  Widget _buildPageGuide(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 40),
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
              Text('How to use Factory Management', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• The Factory Management page tracks performance across all your factories.\n'
            '• "Global" metrics at the top combine data from all your locations into one summary.\n'
            '• Scroll down to see a detailed breakdown for each individual factory.\n'
            '• You can create new factories, edit settings (like weight requirements), or delete empty factories using the icons on each factory card.',
            style: TextStyle(height: 1.5, color: cs.onSecondaryContainer.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
