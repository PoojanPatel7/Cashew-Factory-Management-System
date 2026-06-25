import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/inventory_provider.dart';

class StockListTab extends ConsumerStatefulWidget {
  const StockListTab({super.key});

  @override
  ConsumerState<StockListTab> createState() => _StockListTabState();
}

class _StockListTabState extends ConsumerState<StockListTab> {
  final _searchCtrl = TextEditingController();
  String _typeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final inventoryState = ref.watch(inventoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/adjust'),
        icon: const Icon(Icons.sync_alt_rounded),
        label: const Text('Stock Adjustment'),
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
                      hintText: 'Search by ID or Name...',
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
                  onSelected: (val) => setState(() => _typeFilter = val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'All', child: Text('All Types')),
                    const PopupMenuItem(value: 'Raw Material', child: Text('Raw Material')),
                    const PopupMenuItem(value: 'Finished Goods', child: Text('Finished Goods')),
                    const PopupMenuItem(value: 'Packaging', child: Text('Packaging')),
                    const PopupMenuItem(value: 'Byproduct', child: Text('Byproduct')),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(inventoryProvider.notifier).fetchInventory(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: inventoryState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (inventory) {
                final filtered = inventory.where((item) {
                  if (_typeFilter != 'All' && item['type'] != _typeFilter) return false;
                  if (_searchCtrl.text.isNotEmpty) {
                    final name = (item['name'] ?? '').toString().toLowerCase();
                    final idStr = (item['id'] ?? '').toString().toLowerCase();
                    final q = _searchCtrl.text.toLowerCase();
                    return name.contains(q) || idStr.contains(q);
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No items found.'));
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
          DataColumn(label: Text('Item ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: data.map((item) {
          final idStr = item['id']?.toString() ?? 'N/A';
          final name = item['name']?.toString() ?? 'N/A';
          final type = item['type']?.toString() ?? 'N/A';
          final qty = '${item['currentStock']} ${item['unit']}';
          final location = item['warehouseLocation']?.toString() ?? 'N/A';
          
          final stock = (item['currentStock'] as num?)?.toDouble() ?? 0.0;
          final minStock = (item['minStockLevel'] as num?)?.toDouble() ?? 0.0;
          final status = stock > minStock ? 'In Stock' : 'Low Stock';

          return DataRow(
            cells: [
              DataCell(Text(idStr, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
              DataCell(Text(name)),
              DataCell(Text(type)),
              DataCell(Text(qty, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(location)),
              DataCell(_statusBadge(status)),
              DataCell(Row(
                children: [
                  IconButton(icon: const Icon(Icons.qr_code_2, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.history, size: 18), onPressed: () {}),
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
        final item = data[i];
        final idStr = item['id']?.toString() ?? 'N/A';
        final name = item['name']?.toString() ?? 'N/A';
        final type = item['type']?.toString() ?? 'N/A';
        final qty = '${item['currentStock']} ${item['unit']}';
        final location = item['warehouseLocation']?.toString() ?? 'N/A';
        
        final stock = (item['currentStock'] as num?)?.toDouble() ?? 0.0;
        final minStock = (item['minStockLevel'] as num?)?.toDouble() ?? 0.0;
        final status = stock > minStock ? 'In Stock' : 'Low Stock';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(idStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'monospace')),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: theme.colorScheme.primary)),
                Text(type, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                        Text(location, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Quantity', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                        Text(qty, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == 'In Stock' ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    return StatusBadge(label: status, color: color);
  }
}
