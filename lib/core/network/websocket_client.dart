import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/constants.dart';

class WebSocketClient {
  static final WebSocketClient _instance = WebSocketClient._internal();
  factory WebSocketClient() => _instance;
  WebSocketClient._internal();

  IO.Socket? _socket;
  final _storage = const FlutterSecureStorage();

  void connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _storage.read(key: 'jwt_token');

    // Nginx handles websocket routing at / socket.io/
    final wsUrl = AppConstants.defaultApiBaseUrl.replaceFirst('http', 'ws');

    _socket = IO.io(wsUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build()
    );

    _socket!.onConnect((_) {
      print('WebSocket Connected');
    });

    _socket!.onDisconnect((_) {
      print('WebSocket Disconnected');
    });

    _socket!.onError((error) {
      print('WebSocket Error: $error');
    });
  }

  void subscribeToMachinery(Function(Map<String, dynamic>) onData) {
    if (_socket == null || !_socket!.connected) connect();
    _socket!.on('machine_telemetry', (data) {
      if (data is Map<String, dynamic>) {
        onData(data);
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
