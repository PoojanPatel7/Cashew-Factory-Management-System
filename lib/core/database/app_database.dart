import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SyncTask {
  final String method;
  final String path;
  final String payload;
  final DateTime createdAt;

  SyncTask({
    required this.method,
    required this.path,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'method': method,
    'path': path,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SyncTask.fromJson(Map<String, dynamic> json) => SyncTask(
    method: json['method'],
    path: json['path'],
    payload: json['payload'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class AppDatabase {
  static const String _queueKey = 'sync_queue';

  Future<void> addSyncTask(String method, String path, String payload) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getAllTasks();
    tasks.add(SyncTask(
      method: method,
      path: path,
      payload: payload,
      createdAt: DateTime.now(),
    ));
    
    final serialized = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_queueKey, serialized);
  }

  Future<List<SyncTask>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    return list.map((item) => SyncTask.fromJson(jsonDecode(item))).toList();
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }
}

// Singleton pattern
final appDatabase = AppDatabase();
