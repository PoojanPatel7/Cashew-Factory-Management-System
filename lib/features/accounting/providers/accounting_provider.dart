import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class AccountingProvider extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  AccountingProvider() : super(const AsyncValue.loading()) {
    fetchData();
  }

  Future<void> fetchData() async {
    state = const AsyncValue.loading();
    try {
      final transRes = await ApiClient().dio.get('/accounting/transactions');
      final accRes = await ApiClient().dio.get('/accounting/accounts');
      
      state = AsyncValue.data({
        'transactions': transRes.data as List<dynamic>,
        'accounts': accRes.data as List<dynamic>,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> logTransaction({
    required String description,
    required String debitAccountId,
    required String creditAccountId,
    required double amount,
    String? referenceId,
  }) async {
    try {
      await ApiClient().dio.post('/accounting/transactions', data: {
        'description': description,
        'debitAccountId': debitAccountId,
        'creditAccountId': creditAccountId,
        'amount': amount,
        'referenceId': referenceId,
      });
      await fetchData();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final accountingProvider = StateNotifierProvider<AccountingProvider, AsyncValue<Map<String, dynamic>>>((ref) {
  return AccountingProvider();
});
