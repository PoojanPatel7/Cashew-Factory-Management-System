import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/websocket_client.dart';

class MachineryState {
  final AsyncValue<List<Map<String, dynamic>>> machines;
  final Map<String, Map<String, dynamic>> telemetryData;

  MachineryState({
    required this.machines,
    this.telemetryData = const {},
  });

  MachineryState copyWith({
    AsyncValue<List<Map<String, dynamic>>>? machines,
    Map<String, Map<String, dynamic>>? telemetryData,
  }) {
    return MachineryState(
      machines: machines ?? this.machines,
      telemetryData: telemetryData ?? this.telemetryData,
    );
  }
}

class MachineryProvider extends StateNotifier<MachineryState> {
  final WebSocketClient _wsClient = WebSocketClient();

  MachineryProvider() : super(MachineryState(machines: const AsyncValue.loading())) {
    fetchMachines();
    _initWebSocket();
  }

  void _initWebSocket() {
    _wsClient.connect();
    _wsClient.subscribeToMachinery((data) {
      final machineId = data['machineId'];
      if (machineId != null) {
        final newTelemetry = Map<String, Map<String, dynamic>>.from(state.telemetryData);
        newTelemetry[machineId] = data;
        state = state.copyWith(telemetryData: newTelemetry);
      }
    });
  }

  Future<void> fetchMachines() async {
    state = state.copyWith(machines: const AsyncValue.loading());
    try {
      final response = await ApiClient().dio.get('/machinery');
      final List<dynamic> data = response.data;
      state = state.copyWith(machines: AsyncValue.data(data.cast<Map<String, dynamic>>()));
    } catch (e) {
      state = state.copyWith(machines: AsyncValue.error(e, StackTrace.current));
    }
  }

  Future<bool> addMachine(Map<String, dynamic> machineData) async {
    try {
      await ApiClient().dio.post('/machinery', data: machineData);
      await fetchMachines();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _wsClient.disconnect();
    super.dispose();
  }
}

final machineryProvider = StateNotifierProvider<MachineryProvider, MachineryState>((ref) {
  return MachineryProvider();
});
