import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/network/api_client.dart';
import '../../providers/stock_providers.dart';
import 'package:go_router/go_router.dart';

class FactorySelectorWidget extends ConsumerStatefulWidget {
  const FactorySelectorWidget({super.key});

  @override
  ConsumerState<FactorySelectorWidget> createState() => _FactorySelectorWidgetState();
}

class _FactorySelectorWidgetState extends ConsumerState<FactorySelectorWidget> {
  String? _currentFactoryId;
  List<Map<String, dynamic>> _factories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFactories();
  }

  Future<void> _loadFactories() async {
    try {
      final id = await ApiClient().getFactoryId();
      final res = await FirebaseFirestore.instance.collection('factories').get();
      final list = res.docs.map((e) {
        final data = e.data();
        data['id'] = e.id;
        return data;
      }).toList();
      if (mounted) {
        setState(() {
          _factories = list;
          _currentFactoryId = id;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _switchFactory(String factoryId) async {
    await ApiClient().setFactoryId(factoryId);
    setState(() => _currentFactoryId = factoryId);
    // Invalidate all data providers to reload with new factory
    ref.invalidate(dashboardProvider);
    ref.invalidate(rawStockProvider);
    ref.invalidate(sortingProvider);
    ref.invalidate(lotsProvider);
    ref.invalidate(finishedProvider);
    ref.invalidate(currentFactoryProvider);
    
    final currentRoute = GoRouterState.of(context).uri.toString();
    if (currentRoute.contains('/lots/') || currentRoute.contains('/raw-stock/') || currentRoute.contains('/finished/')) {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
    if (_factories.isEmpty) return const SizedBox.shrink();

    final current = _factories.where((f) => f['id'] == _currentFactoryId).firstOrNull;
    final name = current?['name'] ?? 'Select Factory';

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.factory_rounded, size: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ],
        ),
      ),
      itemBuilder: (ctx) => [
        ..._factories.map((f) => PopupMenuItem<String>(
          value: f['id'],
          child: Row(
            children: [
              Icon(
                f['id'] == _currentFactoryId ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 18,
                color: f['id'] == _currentFactoryId ? Theme.of(ctx).colorScheme.primary : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(f['name'], style: TextStyle(
                fontWeight: f['id'] == _currentFactoryId ? FontWeight.bold : FontWeight.normal,
              ))),
            ],
          ),
        )),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: '__add_new__',
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, size: 18, color: Theme.of(ctx).colorScheme.primary),
              const SizedBox(width: 12),
              Text('Add New Factory', style: TextStyle(color: Theme.of(ctx).colorScheme.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == '__add_new__') {
          _showAddFactorySheet(context);
        } else {
          _switchFactory(value);
        }
      },
    );
  }

  void _showAddFactorySheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    bool weighEvery = true;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create New Factory', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Factory Name', prefixIcon: Icon(Icons.business_rounded)),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Weigh at Every Stage'),
                  subtitle: const Text('If off, weight only at start and end'),
                  value: weighEvery,
                  onChanged: (v) => setSheetState(() => weighEvery = v),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      final doc = await FirebaseFirestore.instance.collection('factories').add({
                        'name': nameCtrl.text.trim(),
                        'weighAtEveryStage': weighEvery,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      await ApiClient().setFactoryId(doc.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadFactories();
                      // Invalidate providers
                      ref.invalidate(dashboardProvider);
                      ref.invalidate(rawStockProvider);
                      ref.invalidate(sortingProvider);
                      ref.invalidate(lotsProvider);
                      ref.invalidate(finishedProvider);
                      ref.invalidate(currentFactoryProvider);
                      
                      final currentRoute = GoRouterState.of(context).uri.toString();
                      if (currentRoute.contains('/lots/') || currentRoute.contains('/raw-stock/') || currentRoute.contains('/finished/')) {
                        if (mounted) context.go('/home');
                      }
                    } catch (e) {
                      if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Create & Switch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
