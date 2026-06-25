import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/constants.dart';
import '../database/app_database.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final _storage = const FlutterSecureStorage();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.defaultApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired or invalid
          await _storage.delete(key: 'jwt_token');
          await _storage.delete(key: 'user_role');
        }

        // Handle offline caching for POST and PUT requests
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.connectionError ||
            e.error is SocketException) {
              
          final method = e.requestOptions.method;
          if (method == 'POST' || method == 'PUT') {
            final path = e.requestOptions.path;
            final payload = jsonEncode(e.requestOptions.data ?? {});
            
            await appDatabase.addSyncTask(method, path, payload);
            
            // Resolve with a fake 202 Accepted so the UI doesn't crash
            return handler.resolve(Response(
              requestOptions: e.requestOptions,
              statusCode: 202,
              data: {'message': 'Saved offline'},
            ));
          }
        }

        return handler.next(e);
      },
    ));
  }

  // Token management
  Future<void> saveToken(String token, String role) async {
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'user_role', value: role);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }
}
