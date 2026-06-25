import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/processing_provider.dart';

class LotListTab extends ConsumerStatefulWidget {
  const LotListTab({super.key});

  @override
  ConsumerState<LotListTab> createState() => _LotListTabState();
}

class _LotListTabState extends ConsumerState<LotListTab> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;
    
    final lotState = ref.watch(processingProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search Lot ID...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: theme.colorScheme.primary),
                  onSelected: (val) => setState(() => _statusFilter = val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'All', child: Text('All Status')),
                    const PopupMenuItem(value: 'Active', child: Text('Active')),
                    const PopupMenuItem(value: 'Paused', child: Text('Paused')),
                    const PopupMenuItem(value: 'Completed', child: Text('Completed')),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(processingProvider.notifier).fetchLots(),
                ),
              ],
            ),
          ),
          Expanded(
            child: lotState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (lots) {
                final filtered = lots.where((lot) {
                  final status = lot['status'] ?? 'Active';
                  if (_statusFilter != 'All' && status != _statusFilter) return false;
                  if (_searchCtrl.text.isNotEmpty) {
                    final idStr = (lot['id'] ?? '').toString().toLowerCase();
                    return idStr.contains(_searchCtrl.text.toLowerCase());
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No processing lots found.'));
                }

                return isWide ? _buildDesktopTable(theme, filtered) : _buildMobileList(theme, filtered);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(ThemeData theme, List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        columns: const [
          DataColumn(label: Text('Lot ID')),
          DataColumn(label: Text('Date Started')),
          DataColumn(label: Text('Source RCN')),
          DataColumn(label: Text('Initial Qty (kg)')),
          DataColumn(label: Text('Current Stage')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: data.map((lot) {
          final idStr = lot['id']?.toString() ?? 'N/A';
          final dateStr = lot['date']?.toString() ?? lot['createdAt']?.toString() ?? 'N/A';
          final rcn = lot['rcn']?.toString() ?? 'N/A';
          final qty = lot['qty']?.toString() ?? '0';
          final stage = lot['stage']?.toString() ?? 'Pending';
          final status = lot['status']?.toString() ?? 'Active';

          return DataRow(
            onSelectChanged: (_) => context.push('/processing/lot_detail', extra: lot),
            cells: [
              DataCell(Text(idStr, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary))),
              DataCell(Text(dateStr)),
              DataCell(Text(rcn)),
              DataCell(Text(qty)),
              DataCell(Text(stage, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(_statusBadge(status)),
              DataCell(IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () {})),
            ]
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList(ThemeData theme, List<Map<String, dynamic>> data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (ctx, i) {
        final lot = data[i];
        final idStr = lot['id']?.toString() ?? 'N/A';
        final rcn = lot['rcn']?.toString() ?? 'N/A';
        final qty = lot['qty']?.toString() ?? '0';
        final stage = lot['stage']?.toString() ?? 'Pending';
        final status = lot['status']?.toString() ?? 'Active';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: InkWell(
            onTap: () => context.push('/processing/lot_detail', extra: lot),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(idStr, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: theme.colorScheme.primary)),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Source RCN: $rcn', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                Text('Qty: $qty kg', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.label_important_outline, size: 16),
                    const SizedBox(width: 8),
                    Text('Stage: $stage', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Active': color = Colors.blue; break;
      case 'Completed': color = Colors.green; break;
      case 'Paused': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return StatusBadge(label: status, color: color);
  }
}
