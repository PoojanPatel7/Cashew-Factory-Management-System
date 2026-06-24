import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/common_widgets.dart';

class PurchaseOrdersTab extends StatefulWidget {
  const PurchaseOrdersTab({super.key});

  @override
  State<PurchaseOrdersTab> createState() => _PurchaseOrdersTabState();
}

class _PurchaseOrdersTabState extends State<PurchaseOrdersTab> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'All';

  // Demo POs
  final _pos = [
    {'id': 'PO-2024-001', 'supplier': 'Rajan Cashew Farm', 'date': '24-Jun-2026', 'qty': '5,000 kg', 'amount': '₹4,50,000', 'status': 'Draft'},
    {'id': 'PO-2024-002', 'supplier': 'Global Nuts Exporters', 'date': '20-Jun-2026', 'qty': '10,000 kg', 'amount': '₹8,80,000', 'status': 'In Transit'},
    {'id': 'PO-2024-003', 'supplier': 'Shreeji Traders', 'date': '15-Jun-2026', 'qty': '2,500 kg', 'amount': '₹2,37,500', 'status': 'Received'},
    {'id': 'PO-2024-004', 'supplier': 'Rajan Cashew Farm', 'date': '10-Jun-2026', 'qty': '8,000 kg', 'amount': '₹7,20,000', 'status': 'Closed'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final filtered = _pos.where((po) {
      if (_statusFilter != 'All' && po['status'] != _statusFilter) return false;
      if (_searchCtrl.text.isNotEmpty) {
        return po['id']!.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
               po['supplier']!.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      }
      return true;
    }).toList();

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
          DataColumn(label: Text('PO Number')),
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('RCN Qty')),
          DataColumn(label: Text('Total Amount')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: data.map((po) => DataRow(
          onSelectChanged: (_) => context.push('/procurement/po_detail', extra: po),
          cells: [
            DataCell(Text(po['id']!, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary))),
            DataCell(Text(po['supplier']!)),
            DataCell(Text(po['date']!)),
            DataCell(Text(po['qty']!)),
            DataCell(Text(po['amount']!)),
            DataCell(_statusBadge(po['status']!)),
            DataCell(Row(
              children: [
                if (po['status'] == 'Draft') IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
                IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () => context.push('/procurement/po_detail', extra: po)),
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
        final po = data[i];
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
                    Text(po['id']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: theme.colorScheme.primary)),
                    _statusBadge(po['status']!),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.store_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 6),
                    Text(po['supplier']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 6),
                    Text(po['date']!, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
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
                        Text(po['qty']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Amount', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                        Text(po['amount']!, style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
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
