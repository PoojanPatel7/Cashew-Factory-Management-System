import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class SupplierProvider extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  SupplierProvider() : super(const AsyncValue.loading()) {
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiClient().dio.get('/suppliers');
      final List<dynamic> data = response.data;
      state = AsyncValue.data(data.cast<Map<String, dynamic>>());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> addSupplier(Map<String, dynamic> supplierData) async {
    try {
      await ApiClient().dio.post('/suppliers', data: supplierData);
      await fetchSuppliers(); // Refresh list
      return true;
    } catch (e) {
      return false;
    }
  }
}

final supplierProvider = StateNotifierProvider<SupplierProvider, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return SupplierProvider();
});
