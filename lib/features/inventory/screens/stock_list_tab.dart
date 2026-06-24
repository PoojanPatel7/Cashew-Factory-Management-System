import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/common_widgets.dart';

class StockListTab extends StatefulWidget {
  const StockListTab({super.key});

  @override
  State<StockListTab> createState() => _StockListTabState();
}

class _StockListTabState extends State<StockListTab> {
  final _searchCtrl = TextEditingController();
  String _typeFilter = 'All';

  // Demo Inventory Data
  final _inventory = [
    {'id': 'RCN-24-001', 'name': 'Raw Cashew Nut (Benin)', 'type': 'Raw Material', 'qty': '12,500 kg', 'location': 'Warehouse A - Sec 1', 'status': 'In Stock'},
    {'id': 'W320-L12', 'name': 'Cashew Kernel - W320', 'type': 'Finished Goods', 'qty': '1,500 kg', 'location': 'Finished Goods Store', 'status': 'In Stock'},
    {'id': 'PKG-TIN-10', 'name': '10kg Tin Container', 'type': 'Packaging', 'qty': '50 units', 'location': 'Store Room 1', 'status': 'Low Stock'},
    {'id': 'CNSL-001', 'name': 'CNSL Oil', 'type': 'Byproduct', 'qty': '800 L', 'location': 'Tank 2', 'status': 'In Stock'},
    {'id': 'SW-L05', 'name': 'Cashew Kernel - SW', 'type': 'Finished Goods', 'qty': '400 kg', 'location': 'Finished Goods Store', 'status': 'In Stock'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final filtered = _inventory.where((item) {
      if (_typeFilter != 'All' && item['type'] != _typeFilter) return false;
      if (_searchCtrl.text.isNotEmpty) {
        return item['name']!.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
               item['id']!.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      }
      return true;
    }).toList();

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
              ],
            ),
          ),
          
          Expanded(
            child: isWide ? _buildDesktopTable(theme, filtered) : _buildMobileList(theme, filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(ThemeData theme, List<Map<String, String>> data) {
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
        rows: data.map((item) => DataRow(
          cells: [
            DataCell(Text(item['id']!, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
            DataCell(Text(item['name']!)),
            DataCell(Text(item['type']!)),
            DataCell(Text(item['qty']!, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(item['location']!)),
            DataCell(_statusBadge(item['status']!)),
            DataCell(Row(
              children: [
                IconButton(icon: const Icon(Icons.qr_code_2, size: 18), onPressed: () {}),
                IconButton(icon: const Icon(Icons.history, size: 18), onPressed: () {}),
              ],
            )),
          ]
        )).toList(),
      ),
    );
  }

  Widget _buildMobileList(ThemeData theme, List<Map<String, String>> data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (ctx, i) {
        final item = data[i];
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
                    Text(item['id']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'monospace')),
                    _statusBadge(item['status']!),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item['name']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: theme.colorScheme.primary)),
                Text(item['type']!, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                        Text(item['location']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Quantity', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                        Text(item['qty']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
