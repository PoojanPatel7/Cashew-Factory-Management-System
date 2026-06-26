import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  Future<void> saveToken(String token, String role, [String? name]) async {
    // legacy, Firebase Auth handles tokens now
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    if (name != null) await prefs.setString('user_name', name);
  }

  Future<void> clearAuth() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('factory_id');
  }

  Future<bool> isLoggedIn() async {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<String?> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.data()?['role'] as String?;
    }
    return null;
  }

  Future<String?> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.data()?['name'] as String?;
    }
    return null;
  }

  Future<void> setFactoryId(String factoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('factory_id', factoryId);
  }

  Future<String?> getFactoryId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('factory_id');
  }
}
