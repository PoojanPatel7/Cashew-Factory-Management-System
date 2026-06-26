import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/raw_stock/raw_stock_screen.dart';
import 'features/sorting/sorting_screen.dart';
import 'features/sorting/create_sorting_page.dart';
import 'features/processing/processing_screen.dart';
import 'features/processing/lot_detail_page.dart';
import 'features/finished/finished_stock_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/wastage/wastage_screen.dart';
import 'features/factory/factory_management_screen.dart';
import 'features/factory/factory_setup_screen.dart';
import 'features/raw_stock/raw_stock_detail_page.dart';
import 'core/network/api_client.dart';
import 'features/factory/factory_selector_widget.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'providers/theme_provider.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/guide_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const ProviderScope(child: CashewStockApp()));
}

// ─── Router ──────────────────────────────────────────────────
final _shellNavKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/setup', builder: (_, __) => const FactorySetupScreen()),
    ShellRoute(
      navigatorKey: _shellNavKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/raw-stock', builder: (_, __) => const RawStockScreen()),
        GoRoute(path: '/raw-stock/:id', builder: (_, state) => RawStockDetailPage(id: state.pathParameters['id']!)),
        GoRoute(path: '/wastage', builder: (_, __) => const WastageScreen()),
        GoRoute(path: '/sorting', builder: (_, __) => const SortingScreen()),
        GoRoute(path: '/sorting/new', builder: (_, __) => const CreateSortingPage()),
        GoRoute(path: '/processing', builder: (_, __) => const ProcessingScreen()),
        GoRoute(
          path: '/processing/:id',
          builder: (_, state) => LotDetailPage(lotId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/finished', builder: (_, __) => const FinishedStockScreen()),
        GoRoute(path: '/factories', builder: (_, __) => const FactoryManagementScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/guide', builder: (_, __) => const GuideScreen()),
      ],
    ),
  ],
  redirect: (context, state) async {
    final isSplash = state.matchedLocation == '/';
    final isAuth = state.matchedLocation == '/login' || state.matchedLocation == '/forgot-password';
    final isSetup = state.matchedLocation == '/setup';
    final loggedIn = await ApiClient().isLoggedIn();
    
    if (isSplash) return null;
    if (!loggedIn && !isAuth) return '/login';
    if (loggedIn && isAuth) return '/home';
    
    // Check if user has a factory selected
    if (loggedIn && !isSetup && !isAuth) {
      final factoryId = await ApiClient().getFactoryId();
      if (factoryId == null) {
        // Check if any factories exist
        try {
          final res = await FirebaseFirestore.instance.collection('factories').get();
          final factories = res.docs;
          if (factories.isNotEmpty) {
            await ApiClient().setFactoryId(factories.first.id);
            return null; // continue to requested route factory
          } else {
            return '/setup';
          }
        } catch (_) {
          // If API fails, let them proceed
        }
      }
    }
    
    return null;
  },
);

// ─── App Shell (Bottom Nav) ─────────────────────────────────
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/raw-stock')) return 1;
    if (loc.startsWith('/sorting')) return 2;
    if (loc.startsWith('/processing')) return 3;
    if (loc.startsWith('/finished')) return 4;
    if (loc.startsWith('/factories')) return 5;
    return 0; // Default is /home
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: idx,
              extended: MediaQuery.of(context).size.width > 1000,
              labelType: MediaQuery.of(context).size.width > 1000
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', height: 100),
                    if (MediaQuery.of(context).size.width > 1000) ...[
                      const SizedBox(height: 12),
                      const Text('HM Nuts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.2)),
                    ],
                    const SizedBox(height: 24),
                    if (MediaQuery.of(context).size.width > 1000)
                      const FactorySelectorWidget(),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.inventory_2_rounded), label: Text('Raw Stock')),
                NavigationRailDestination(icon: Icon(Icons.call_split_rounded), label: Text('Sorting')),
                NavigationRailDestination(icon: Icon(Icons.precision_manufacturing_rounded), label: Text('Processing')),
                NavigationRailDestination(icon: Icon(Icons.check_circle_rounded), label: Text('Finished')),
                NavigationRailDestination(icon: Icon(Icons.business_rounded), label: Text('Factories')),
                NavigationRailDestination(icon: Icon(Icons.menu_book_rounded), label: Text('Guide')),
              ],
              onDestinationSelected: (i) => _navigate(context, i),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const FactorySelectorWidget(),
          ),
          NavigationBar(
            selectedIndex: idx,
            onDestinationSelected: (i) => _navigate(context, i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            height: 70,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.inventory_2_rounded), label: 'Stock'),
              NavigationDestination(icon: Icon(Icons.call_split_rounded), label: 'Sort'),
              NavigationDestination(icon: Icon(Icons.precision_manufacturing_rounded), label: 'Process'),
              NavigationDestination(icon: Icon(Icons.check_circle_rounded), label: 'Done'),
              NavigationDestination(icon: Icon(Icons.business_rounded), label: 'Factories'),
            ],
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/raw-stock'); break;
      case 2: context.go('/sorting'); break;
      case 3: context.go('/processing'); break;
      case 4: context.go('/finished'); break;
      case 5: context.go('/factories'); break;
      case 6: context.go('/guide'); break;
    }
  }
}

// ─── Theme ──────────────────────────────────────────────────
class CashewStockApp extends ConsumerWidget {
  const CashewStockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'HM Nuts',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildTheme(),
      darkTheme: _buildDarkTheme(),
      routerConfig: _router,
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF10B981), // Premium Emerald Green
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    );
    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme), // Modern, premium font
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        iconTheme: IconThemeData(color: Colors.black87),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: base.colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: base.colorScheme.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: base.colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: base.colorScheme.primary);
          }
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey);
        }),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF10B981),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    );
    
    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF1E293B),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E293B), // Slate 800
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: base.colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: base.colorScheme.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        indicatorColor: base.colorScheme.primary.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: base.colorScheme.primary);
          }
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade400);
        }),
      ),
    );
  }
}
