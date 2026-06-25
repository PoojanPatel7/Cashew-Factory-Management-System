import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/machinery_provider.dart';

class MachineListPage extends ConsumerStatefulWidget {
  const MachineListPage({super.key});

  @override
  ConsumerState<MachineListPage> createState() => _MachineListPageState();
}

class _MachineListPageState extends ConsumerState<MachineListPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final machineryState = ref.watch(machineryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Machine Registry'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(machineryProvider.notifier).fetchMachines()),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', _filter == 'All'),
                _buildFilterChip('Running', _filter == 'Running'),
                _buildFilterChip('Idle', _filter == 'Idle'),
                _buildFilterChip('Maintenance', _filter == 'Maintenance'),
                _buildFilterChip('Breakdown', _filter == 'Breakdown'),
              ],
            ),
          ),
          Expanded(
            child: machineryState.machines.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (machines) {
                // Apply WS Telemetry Live Status to filter
                final filtered = machines.where((m) {
                  final telemetry = machineryState.telemetryData[m['id']] ?? {};
                  final status = telemetry['status'] ?? m['status'] ?? 'Idle';
                  if (_filter != 'All' && status != _filter) return false;
                  return true;
                }).toList();

                if (filtered.isEmpty) return const Center(child: Text('No machines found.'));

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 3 : 1,
                    childAspectRatio: isWide ? 1.5 : 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    final telemetry = machineryState.telemetryData[m['id']] ?? {};
                    return _buildMachineCard(context, m, telemetry);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('add_machine'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _filter = label),
      ),
    );
  }

  Widget _buildMachineCard(BuildContext context, Map<String, dynamic> machine, Map<String, dynamic> telemetry) {
    final statusText = telemetry['status'] ?? machine['status'] ?? 'Idle';
    
    Color statusColor;
    if (statusText == 'Running') statusColor = Colors.green;
    else if (statusText == 'Maintenance') statusColor = Colors.orange;
    else if (statusText == 'Breakdown') statusColor = Colors.red;
    else statusColor = Colors.blue;

    final temp = telemetry['temperature'] != null ? '${telemetry['temperature']}°C' : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goNamed('machine_detail'),
        child: Row(
          children: [
            Container(
              width: 100,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.precision_manufacturing, size: 48, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(machine['name'] ?? 'Unknown Machine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('Model: ${machine['model'] ?? 'N/A'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: statusColor, size: 10),
                              const SizedBox(width: 4),
                              Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        if (temp != null) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.thermostat, size: 14, color: Colors.redAccent),
                              Text(temp, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
