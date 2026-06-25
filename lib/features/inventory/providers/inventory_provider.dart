import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class InventoryProvider extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  InventoryProvider() : super(const AsyncValue.loading()) {
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiClient().dio.get('/inventory/stock');
      final List<dynamic> data = response.data;
      state = AsyncValue.data(data.cast<Map<String, dynamic>>());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final inventoryProvider = StateNotifierProvider<InventoryProvider, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return InventoryProvider();
});
