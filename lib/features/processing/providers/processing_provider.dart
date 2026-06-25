import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class ProcessingProvider extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  ProcessingProvider() : super(const AsyncValue.loading()) {
    fetchLots();
  }

  Future<void> fetchLots() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiClient().dio.get('/processing/lots');
      final List<dynamic> data = response.data;
      state = AsyncValue.data(data.cast<Map<String, dynamic>>());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> createLot(Map<String, dynamic> lotData) async {
    try {
      await ApiClient().dio.post('/processing/lots', data: lotData);
      await fetchLots();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logStep(String lotId, String stepName, Map<String, dynamic> logData) async {
    try {
      await ApiClient().dio.post('/processing/lots/$lotId/stages', data: {
        'stage': stepName,
        'data': logData,
      });
      await fetchLots();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final processingProvider = StateNotifierProvider<ProcessingProvider, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ProcessingProvider();
});
