import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/common_widgets.dart';

class SupplierListTab extends StatefulWidget {
  const SupplierListTab({super.key});

  @override
  State<SupplierListTab> createState() => _SupplierListTabState();
}

class _SupplierListTabState extends State<SupplierListTab> {
  final _searchCtrl = TextEditingController();
  
  // Demo Data
  final _suppliers = [
    {'id': 'SUP-001', 'name': 'Rajan Cashew Farm', 'location': 'Kollam, Kerala', 'rating': 4.5, 'totalQty': '12,500 kg', 'lastPo': '12-Oct-2024', 'status': 'Active'},
    {'id': 'SUP-002', 'name': 'Global Nuts Exporters', 'location': 'Goa', 'rating': 4.8, 'totalQty': '45,000 kg', 'lastPo': '05-Nov-2024', 'status': 'Active'},
    {'id': 'SUP-003', 'name': 'Shreeji Traders', 'location': 'Surat, Gujarat', 'rating': 3.9, 'totalQty': '4,200 kg', 'lastPo': '28-Sep-2024', 'status': 'Inactive'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/procurement/add_supplier'),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add Supplier'),
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
                      hintText: 'Search suppliers...',
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
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'All', child: Text('All Suppliers')),
                    const PopupMenuItem(value: 'Active', child: Text('Active Only')),
                    const PopupMenuItem(value: 'Inactive', child: Text('Inactive Only')),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: isWide ? _buildDesktopTable(theme) : _buildMobileList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        columns: const [
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Rating')),
          DataColumn(label: Text('Total Purchased')),
          DataColumn(label: Text('Last PO Date')),
          DataColumn(label: Text('Status')),
        ],
        rows: _suppliers.map((s) => DataRow(
          onSelectChanged: (_) => _viewDetail(s),
          cells: [
            DataCell(Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(s['location'] as String)),
            DataCell(Row(children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 16),
              const SizedBox(width: 4),
              Text('${s['rating']}'),
            ])),
            DataCell(Text(s['totalQty'] as String)),
            DataCell(Text(s['lastPo'] as String)),
            DataCell(StatusBadge(
              label: s['status'] as String,
              color: s['status'] == 'Active' ? const Color(0xFF00E676) : const Color(0xFFFF5252),
            )),
          ]
        )).toList(),
      ),
    );
  }

  Widget _buildMobileList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _suppliers.length,
      itemBuilder: (ctx, i) {
        final s = _suppliers[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          color: theme.colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _viewDetail(s),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      StatusBadge(
                        label: s['status'] as String,
                        color: s['status'] == 'Active' ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
                      const SizedBox(width: 4),
                      Text(s['location'] as String, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 16),
                      const SizedBox(width: 4),
                      Text('${s['rating']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoCol(theme, 'Total Qty', s['totalQty'] as String),
                      _infoCol(theme, 'Last PO', s['lastPo'] as String),
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

  Widget _infoCol(ThemeData theme, String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
      ],
    );
  }

  void _viewDetail(Map<String, Object> supplier) {
    context.push('/procurement/supplier_detail', extra: supplier);
  }
}
