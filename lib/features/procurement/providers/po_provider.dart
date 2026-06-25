import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../inventory/providers/inventory_provider.dart';

class PoProvider extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref ref;

  PoProvider(this.ref) : super(const AsyncValue.loading()) {
    fetchPOs();
  }

  Future<void> fetchPOs() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiClient().dio.get('/procurement/pos');
      final List<dynamic> data = response.data;
      state = AsyncValue.data(data.cast<Map<String, dynamic>>());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> createPO(Map<String, dynamic> poData) async {
    try {
      await ApiClient().dio.post('/procurement/pos', data: poData);
      await fetchPOs();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> receiveGoods(String poId, List<Map<String, dynamic>> receiptItems) async {
    try {
      await ApiClient().dio.put('/procurement/pos/$poId/receive', data: {
        'receiptItems': receiptItems,
      });
      await fetchPOs();
      // Refresh inventory because receiving goods updates stock
      ref.read(inventoryProvider.notifier).fetchInventory();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final poProvider = StateNotifierProvider<PoProvider, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return PoProvider(ref);
});
