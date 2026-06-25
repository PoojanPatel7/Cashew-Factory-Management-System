import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/supplier_provider.dart';

class SupplierListTab extends ConsumerStatefulWidget {
  const SupplierListTab({super.key});

  @override
  ConsumerState<SupplierListTab> createState() => _SupplierListTabState();
}

class _SupplierListTabState extends ConsumerState<SupplierListTab> {
  final _searchCtrl = TextEditingController();
  String _filter = 'All';
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final supplierState = ref.watch(supplierProvider);

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
                  onSelected: (val) => setState(() => _filter = val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'All', child: Text('All Suppliers')),
                    const PopupMenuItem(value: 'Active', child: Text('Active Only')),
                    const PopupMenuItem(value: 'Inactive', child: Text('Inactive Only')),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(supplierProvider.notifier).fetchSuppliers(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: supplierState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (suppliers) {
                final filtered = suppliers.where((s) {
                  final status = s['status'] ?? 'Active';
                  if (_filter != 'All' && status != _filter) return false;

                  if (_searchCtrl.text.isNotEmpty) {
                    final q = _searchCtrl.text.toLowerCase();
                    final name = (s['name'] ?? '').toString().toLowerCase();
                    return name.contains(q);
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No suppliers found.'));
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
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Rating')),
          DataColumn(label: Text('Contact')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Status')),
        ],
        rows: data.map((s) {
          final status = s['status'] ?? 'Active';
          return DataRow(
            onSelectChanged: (_) => _viewDetail(s),
            cells: [
              DataCell(Text(s['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(s['location']?.toString() ?? '')),
              DataCell(Row(children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 16),
                const SizedBox(width: 4),
                Text((s['rating'] ?? 5.0).toString()),
              ])),
              DataCell(Text(s['contactPerson']?.toString() ?? '')),
              DataCell(Text(s['phone']?.toString() ?? '')),
              DataCell(StatusBadge(
                label: status.toString(),
                color: status == 'Active' ? const Color(0xFF00E676) : const Color(0xFFFF5252),
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
        final s = data[i];
        final status = s['status'] ?? 'Active';
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
                        child: Text(s['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      StatusBadge(
                        label: status.toString(),
                        color: status == 'Active' ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
                      const SizedBox(width: 4),
                      Text(s['location']?.toString() ?? '', style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 16),
                      const SizedBox(width: 4),
                      Text((s['rating'] ?? 5.0).toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoCol(theme, 'Contact', s['contactPerson']?.toString() ?? '-'),
                      _infoCol(theme, 'Phone', s['phone']?.toString() ?? '-'),
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

  void _viewDetail(Map<String, dynamic> supplier) {
    context.push('/procurement/supplier_detail', extra: supplier);
  }
}
