import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class HrState {
  final List<dynamic>? payrollData;
  final List<dynamic>? employees;
  HrState({this.payrollData, this.employees});
  
  HrState copyWith({List<dynamic>? payrollData, List<dynamic>? employees}) {
    return HrState(
      payrollData: payrollData ?? this.payrollData,
      employees: employees ?? this.employees,
    );
  }
}

class HrProvider extends StateNotifier<AsyncValue<HrState>> {
  HrProvider() : super(AsyncValue.data(HrState()));

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    try {
      await ApiClient().dio.post('/hr/employees', data: data);
      await fetchEmployees();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchEmployees() async {
    try {
      final res = await ApiClient().dio.get('/hr/employees');
      state = AsyncValue.data(state.value?.copyWith(employees: res.data) ?? HrState(employees: res.data));
    } catch (e) {
      print('Failed to fetch employees: $e');
    }
  }

  Future<bool> setCredentials(String employeeId, String email, String password) async {
    try {
      await ApiClient().dio.post('/hr/employees/$employeeId/generate-password', data: {
        'email': email,
        'password': password,
      });
      await fetchEmployees();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEmployee(String employeeId) async {
    try {
      await ApiClient().dio.delete('/hr/employees/$employeeId');
      await fetchEmployees();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateEmployee(String employeeId, Map<String, dynamic> data) async {
    try {
      await ApiClient().dio.put('/hr/employees/$employeeId', data: data);
      await fetchEmployees();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIn(String employeeId) async {
    try {
      await ApiClient().dio.post('/hr/attendance/check-in', data: {
        'employeeId': employeeId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logPieceWork(String employeeId, String stageName, double kgProcessed, double ratePerKg) async {
    try {
      await ApiClient().dio.post('/hr/piece-work', data: {
        'employeeId': employeeId,
        'stageName': stageName,
        'kgProcessed': kgProcessed,
        'ratePerKg': ratePerKg,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchPayroll(String month) async {
    state = const AsyncValue.loading();
    try {
      final res = await ApiClient().dio.get('/hr/payroll?month=$month');
      state = AsyncValue.data(HrState(payrollData: res.data));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final hrProvider = StateNotifierProvider<HrProvider, AsyncValue<HrState>>((ref) {
  return HrProvider();
});
