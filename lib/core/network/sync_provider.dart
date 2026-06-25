import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../database/app_database.dart';

class SyncState {
  final int pendingItems;
  final bool isSyncing;
  final DateTime? lastSync;

  SyncState({
    required this.pendingItems,
    required this.isSyncing,
    this.lastSync,
  });

  SyncState copyWith({int? pendingItems, bool? isSyncing, DateTime? lastSync}) {
    return SyncState(
      pendingItems: pendingItems ?? this.pendingItems,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}

class SyncProvider extends StateNotifier<SyncState> {
  Timer? _timer;

  SyncProvider() : super(SyncState(pendingItems: 0, isSyncing: false)) {
    _init();
  }

  void _init() {
    _updatePendingCount();
    // Simulate periodic connectivity check
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _checkAndSync());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updatePendingCount() async {
    final tasks = await appDatabase.getAllTasks();
    if (mounted) {
      state = state.copyWith(pendingItems: tasks.length);
    }
  }

  Future<void> _checkAndSync() async {
    if (state.isSyncing) return;
    
    final tasks = await appDatabase.getAllTasks();
    if (tasks.isEmpty) return;

    state = state.copyWith(isSyncing: true);

    try {
      // Simulate pushing the queue
      final payload = tasks.map((t) => {
        'method': t.method,
        'path': t.path,
        'payload': t.payload,
      }).toList();

      await ApiClient().dio.post('/sync/push', data: {'queue': payload});
      
      // On success, clear tasks
      await appDatabase.clearTasks();
      
      // Then pull
      await ApiClient().dio.get('/sync/pull');

      state = state.copyWith(
        pendingItems: 0,
        isSyncing: false,
        lastSync: DateTime.now(),
      );
    } catch (e) {
      // Failed to sync (maybe still offline)
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> forceSync() async {
    await _updatePendingCount();
    await _checkAndSync();
  }
}

final syncProvider = StateNotifierProvider<SyncProvider, SyncState>((ref) {
  return SyncProvider();
});
