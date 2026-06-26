import 'package:flutter/material.dart';
import '../../core/utils/date_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/stock_providers.dart';
import '../../../core/network/api_client.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final wastageProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final factoryId = await ApiClient().getFactoryId();
  if (factoryId == null) return {'totalWastage': 0, 'wastageByStage': [], 'wastageByLot': []};

  final lots = await FirebaseFirestore.instance.collection('lots').where('factoryId', isEqualTo: factoryId).get();
  double total = 0;
  Map<String, double> byStage = {};
  Map<String, double> byLot = {};

  for (var lotDoc in lots.docs) {
    final data = lotDoc.data();
    final steps = data['steps'] as List? ?? [];
    double lotTotal = 0;
    for (var step in steps) {
      final stage = step['stageName'] ?? 'Unknown';
      final wastage = (step['wastage'] as num?)?.toDouble() ?? 0.0;
      total += wastage;
      lotTotal += wastage;
      byStage[stage] = (byStage[stage] ?? 0) + wastage;
    }
    if (lotTotal > 0) {
      byLot[data['name'] ?? 'Unknown'] = lotTotal;
    }
  }

  final byStageList = byStage.entries.map((e) => {'stageName': e.key, '_sum': {'wastage': e.value}}).toList();
  final byLotList = byLot.entries.map((e) => {'lot': {'name': e.key}, '_sum': {'wastage': e.value}}).toList();

  return {
    'totalWastage': total,
    'wastageByStage': byStageList,
    'wastageByLot': byLotList,
  };
});

class WastageScreen extends ConsumerWidget {
  const WastageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wastageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗑️ Waste Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.refresh(wastageProvider)),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final total = (data['totalWastage'] as num?)?.toDouble() ?? 0.0;
          final history = (data['history'] as List<dynamic>?) ?? [];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade800, Colors.red.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Wastage', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 8),
                              Text('${total.toStringAsFixed(1)} kg',
                                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Icon(Icons.delete_sweep_rounded, color: Colors.white30, size: 64),
                      ],
                    ),
                  ),
                  Expanded(
                    child: history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.outline),
                                const SizedBox(height: 16),
                                Text('No wastage recorded', style: TextStyle(color: theme.colorScheme.outline)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: history.length,
                            itemBuilder: (ctx, i) {
                              final h = history[i] as Map<String, dynamic>;
                              final w = (h['wastage'] as num).toDouble();
                              
                              final dateStr = h['date']?.toString() ?? '';
                              final date = formatFirebaseDate(h['date'], 'MMM dd, hh:mm a');
                              
                              final rsDateStr = h['rawStockDate']?.toString() ?? '';
                              final rsDate = formatFirebaseDate(h['rawStockDate'], 'MMM dd, hh:mm a');
                              final rawName = h['rawStockName'] ?? 'Unknown';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text('${w.toInt()}', style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16,
                                        color: Colors.red.shade700,
                                      )),
                                    ),
                                  ),
                                  title: Text('${w.toStringAsFixed(1)} kg - ${h['stageName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${h['lotName']} (${h['category']}) • $date', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('From: $rawName', style: const TextStyle(fontSize: 12)),
                                      Text('Received: $rsDate', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
