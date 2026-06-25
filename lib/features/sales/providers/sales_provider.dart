import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class SalesState {
  final List<dynamic>? orders;
  SalesState({this.orders});
}

class SalesProvider extends StateNotifier<AsyncValue<SalesState>> {
  SalesProvider() : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    state = const AsyncValue.loading();
    try {
      final res = await ApiClient().dio.get('/sales/orders');
      state = AsyncValue.data(SalesState(orders: res.data as List<dynamic>));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> data) async {
    try {
      await ApiClient().dio.post('/sales/customers', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createOrder(Map<String, dynamic> data) async {
    try {
      await ApiClient().dio.post('/sales/orders', data: data);
      await fetchOrders();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> dispatchOrder(String orderId, String vehicleNumber, String driverName) async {
    try {
      await ApiClient().dio.put('/sales/orders/$orderId/dispatch', data: {
        'vehicleNumber': vehicleNumber,
        'driverName': driverName,
      });
      await fetchOrders();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final salesProvider = StateNotifierProvider<SalesProvider, AsyncValue<SalesState>>((ref) {
  return SalesProvider();
});
