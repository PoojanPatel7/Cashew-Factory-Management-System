import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class QualityProvider extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  QualityProvider() : super(const AsyncValue.loading()) {
    fetchGrades();
  }

  Future<void> fetchGrades() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiClient().dio.get('/quality/grades');
      final List<dynamic> data = response.data;
      state = AsyncValue.data(data.cast<Map<String, dynamic>>());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> submitGrade(String lotId, Map<String, double> grades, String qcNotes) async {
    try {
      await ApiClient().dio.post('/quality/grades', data: {
        'lotId': lotId,
        'grades': grades, // { 'W320': 50, 'W240': 20, ... }
        'qcNotes': qcNotes,
      });
      await fetchGrades();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadCertificate(String lotId, String certUrl) async {
    try {
      await ApiClient().dio.post('/quality/certificates', data: {
        'lotId': lotId,
        'certificateUrl': certUrl,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}

final qualityProvider = StateNotifierProvider<QualityProvider, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return QualityProvider();
});
