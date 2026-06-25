import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/po_provider.dart';

class PurchaseOrdersTab extends ConsumerStatefulWidget {
  const PurchaseOrdersTab({super.key});

  @override
  ConsumerState<PurchaseOrdersTab> createState() => _PurchaseOrdersTabState();
}

class _PurchaseOrdersTabState extends ConsumerState<PurchaseOrdersTab> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final poState = ref.watch(poProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/procurement/create_po'),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Create PO'),
      ),
      body: Column(
        children: [
          // Filter & Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search PO number or supplier...',
                      prefixIcon: const Icon(Icons.search, size: 20),
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
                    const PopupMenuItem(value: 'Draft', child: Text('Draft')),
                    const PopupMenuItem(value: 'In Transit', child: Text('In Transit')),
                    const PopupMenuItem(value: 'Received', child: Text('Received')),
                    const PopupMenuItem(value: 'Closed', child: Text('Closed')),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(poProvider.notifier).fetchPOs(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: poState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (pos) {
                final filtered = pos.where((po) {
                  final status = po['status'] ?? 'Draft';
                  if (_statusFilter != 'All' && status != _statusFilter) return false;
                  
                  if (_searchCtrl.text.isNotEmpty) {
                    final q = _searchCtrl.text.toLowerCase();
                    final idStr = (po['id'] ?? '').toString().toLowerCase();
                    final supplier = (po['supplier'] ?? '').toString().toLowerCase();
                    return idStr.contains(q) || supplier.contains(q);
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No Purchase Orders found.'));
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
          DataColumn(label: Text('PO Number')),
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('RCN Qty')),
          DataColumn(label: Text('Total Amount')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: data.map((po) {
          final idStr = po['id']?.toString() ?? 'N/A';
          final supplier = po['supplier']?.toString() ?? 'N/A';
          final dateStr = po['date']?.toString() ?? 'N/A';
          final qty = po['qty']?.toString() ?? '0';
          final amount = po['amount']?.toString() ?? '0';
          final status = po['status']?.toString() ?? 'Draft';

          return DataRow(
            onSelectChanged: (_) => context.push('/procurement/po_detail', extra: po),
            cells: [
              DataCell(Text(idStr, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary))),
              DataCell(Text(supplier)),
              DataCell(Text(dateStr)),
              DataCell(Text(qty)),
              DataCell(Text(amount)),
              DataCell(_statusBadge(status)),
              DataCell(Row(
                children: [
                  if (status == 'Draft') IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () => context.push('/procurement/po_detail', extra: po)),
                ],
              )),
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
        final po = data[i];
        final idStr = po['id']?.toString() ?? 'N/A';
        final supplier = po['supplier']?.toString() ?? 'N/A';
        final dateStr = po['date']?.toString() ?? 'N/A';
        final qty = po['qty']?.toString() ?? '0';
        final amount = po['amount']?.toString() ?? '0';
        final status = po['status']?.toString() ?? 'Draft';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () => context.push('/procurement/po_detail', extra: po),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(idStr, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: theme.colorScheme.primary)),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.store_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 6),
                    Text(supplier, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 6),
                    Text(dateStr, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                        Text(qty, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Amount', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                        Text(amount, style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                      ],
                    ),
                  ],
                ),
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
      case 'Draft': color = Colors.grey; break;
      case 'In Transit': color = const Color(0xFFFF9100); break;
      case 'Received': color = const Color(0xFF448AFF); break;
      case 'Closed': color = const Color(0xFF00E676); break;
      default: color = Colors.grey;
    }
    return StatusBadge(label: status, color: color);
  }
}
