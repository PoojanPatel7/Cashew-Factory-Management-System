import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme_provider.dart';
import 'config/routes.dart';

/// CashewPro ERP — Root Application Widget with Multi-Theme Support
class CashewProApp extends ConsumerWidget {
  const CashewProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'CashewPro ERP',
      debugShowCheckedModeBanner: false,
      theme: getThemeData(themeMode),
      routerConfig: appRouter,
    );
  }
}
