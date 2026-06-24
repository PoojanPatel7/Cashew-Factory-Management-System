import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/common_widgets.dart';

class LotListTab extends StatefulWidget {
  const LotListTab({super.key});

  @override
  State<LotListTab> createState() => _LotListTabState();
}

class _LotListTabState extends State<LotListTab> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'All';

  final List<Map<String, dynamic>> _lots = [
    {'id': 'LOT-101', 'date': '24-Jun-2026', 'rcn': 'RCN-2026-001', 'qty': '1000', 'stage': 'Boiling', 'status': 'Active'},
    {'id': 'LOT-102', 'date': '24-Jun-2026', 'rcn': 'RCN-2026-002', 'qty': '850', 'stage': 'Cooling', 'status': 'Active'},
    {'id': 'LOT-103', 'date': '23-Jun-2026', 'rcn': 'RCN-2026-001', 'qty': '500', 'stage': 'Shelling', 'status': 'Active'},
    {'id': 'LOT-099', 'date': '20-Jun-2026', 'rcn': 'RCN-2026-001', 'qty': '2000', 'stage': 'Packing', 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final filtered = _lots.where((lot) {
      if (_statusFilter != 'All' && lot['status'] != _statusFilter) return false;
      if (_searchCtrl.text.isNotEmpty) {
        return lot['id'].toLowerCase().contains(_searchCtrl.text.toLowerCase());
      }
      return true;
    }).toList();

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
        rows: data.map((lot) => DataRow(
          onSelectChanged: (_) => context.push('/processing/lot_detail', extra: lot),
          cells: [
            DataCell(Text(lot['id'], style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary))),
            DataCell(Text(lot['date'])),
            DataCell(Text(lot['rcn'])),
            DataCell(Text(lot['qty'])),
            DataCell(Text(lot['stage'], style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(_statusBadge(lot['status'])),
            DataCell(IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () {})),
          ]
        )).toList(),
      ),
    );
  }

  Widget _buildMobileList(ThemeData theme, List<Map<String, dynamic>> data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (ctx, i) {
        final lot = data[i];
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
                    Text(lot['id'], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: theme.colorScheme.primary)),
                    _statusBadge(lot['status']),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Source RCN: ${lot['rcn']}', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                Text('Qty: ${lot['qty']} kg', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.label_important_outline, size: 16),
                    const SizedBox(width: 8),
                    Text('Stage: ${lot['stage']}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
