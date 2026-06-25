import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/network/sync_provider.dart';

/// Responsive app shell: Bottom Nav (mobile) → NavigationRail (tablet) → Sidebar (desktop)
class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  bool _railExtended = false;

  UserSession get _user {
    final authState = ref.watch(authProvider);
    final roleStr = authState.role?.toLowerCase() ?? 'owner';
    final UserRole roleEnum = UserRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => UserRole.worker,
    );

    return UserSession(
      id: 'current-user',
      name: authState.name ?? roleEnum.displayName,
      email: '',
      role: roleEnum,
      factoryId: 'factory-001',
    );
  }

  /// All nav items — filtered by role
  List<_NavItem> get _allNavItems => [
    const _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/'),
    const _NavItem(icon: Icons.local_shipping_rounded, label: 'Procurement', route: '/procurement'),
    const _NavItem(icon: Icons.inventory_2_rounded, label: 'Inventory', route: '/inventory'),
    const _NavItem(icon: Icons.precision_manufacturing_rounded, label: 'Processing', route: '/processing'),
    const _NavItem(icon: Icons.grade_rounded, label: 'Grading', route: '/grading'),
    const _NavItem(icon: Icons.people_rounded, label: 'Employees', route: '/employees'),
    const _NavItem(icon: Icons.account_balance_rounded, label: 'Accounting', route: '/accounting'),
    const _NavItem(icon: Icons.point_of_sale_rounded, label: 'Sales', route: '/sales'),
    const _NavItem(icon: Icons.recycling_rounded, label: 'Byproducts', route: '/byproducts'),
    const _NavItem(icon: Icons.verified_rounded, label: 'Compliance', route: '/compliance'),
    const _NavItem(icon: Icons.build_circle_rounded, label: 'Machinery', route: '/machinery'),
    const _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports', route: '/reports'),
    const _NavItem(icon: Icons.settings_rounded, label: 'Settings', route: '/settings'),
  ];

  /// Only show nav items the user's role allows
  List<_NavItem> get _visibleNavItems =>
      _allNavItems.where((item) => _user.canAccessModule(item.route)).toList();

  /// Bottom nav shows max 5 items (mobile)
  List<_NavItem> get _bottomNavItems {
    final items = _visibleNavItems;
    if (items.length <= 5) return items;
    return items.take(4).toList()..add(
      const _NavItem(icon: Icons.more_horiz_rounded, label: 'More', route: '__more__'),
    );
  }

  int get _selectedIndex {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final items = _visibleNavItems;
    for (int i = 0; i < items.length; i++) {
      if (currentLocation == items[i].route) return i;
    }
    return 0;
  }

  void _onDestinationSelected(int index) {
    final items = _visibleNavItems;
    if (index < items.length) {
      context.go(items[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Desktop: > 1024px → persistent sidebar
    if (width > 1024) return _buildDesktopLayout();
    // Tablet: 600-1024px → navigation rail
    if (width > 600) return _buildTabletLayout();
    // Mobile: < 600px → bottom nav + drawer
    return _buildMobileLayout();
  }

  // ═══════════════════════════════════════════
  // DESKTOP LAYOUT — Persistent sidebar
  // ═══════════════════════════════════════════
  Widget _buildDesktopLayout() {
    return CallbackShortcuts(
      bindings: _buildShortcuts(),
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outline, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          _buildLogoHeader(theme),
          Divider(color: theme.colorScheme.outline),
          Expanded(child: _buildNavList(theme)),
          Divider(color: theme.colorScheme.outline),
          _buildUserTile(theme),
        ],
      ),
    );
  }

  Widget _buildNavList(ThemeData theme) {
    final Map<String, List<_NavItem>> groupedItems = {
      'Core': [],
      'Operations': [],
      'Administration': [],
      'Settings & Help': [],
    };

    for (var item in _visibleNavItems) {
      if (['/', '/dashboard'].contains(item.route)) {
        groupedItems['Core']!.add(item);
      } else if (['/procurement', '/inventory', '/processing', '/grading', '/sales', '/byproducts'].contains(item.route)) {
        groupedItems['Operations']!.add(item);
      } else if (['/employees', '/accounting', '/compliance', '/machinery', '/reports'].contains(item.route)) {
        groupedItems['Administration']!.add(item);
      } else {
        groupedItems['Settings & Help']!.add(item);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: groupedItems.entries.where((e) => e.value.isNotEmpty).map((entry) {
        return ExpansionTile(
          title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary)),
          initiallyExpanded: true,
          shape: const Border(), // Remove the top/bottom borders
          iconColor: theme.colorScheme.primary,
          collapsedIconColor: theme.colorScheme.onSurfaceVariant,
          children: entry.value.map((item) {
            final index = _allNavItems.indexOf(item);
            return _buildSidebarTile(theme, item, index);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildLogoHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(Icons.spa_rounded, color: theme.colorScheme.onPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CashewPro',
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                Text('ERP v0.1.0',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTile(ThemeData theme, _NavItem item, int index) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected ? BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 0.5) : BorderSide.none,
        ),
        child: ListTile(
          dense: true,
          leading: Icon(item.icon, color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color, size: 22),
          title: Text(item.label,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () => _onDestinationSelected(index),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // TABLET LAYOUT — NavigationRail
  // ═══════════════════════════════════════════
  Widget _buildTabletLayout() {
    final theme = Theme.of(context);
    final items = _visibleNavItems;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex < items.length ? _selectedIndex : 0,
            onDestinationSelected: _onDestinationSelected,
            extended: _railExtended,
            minWidth: 72,
            minExtendedWidth: 200,
            leading: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.spa_rounded, color: theme.colorScheme.onPrimary, size: 20),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(_railExtended ? Icons.chevron_left : Icons.chevron_right, size: 18),
                  onPressed: () => setState(() => _railExtended = !_railExtended),
                  tooltip: _railExtended ? 'Collapse' : 'Expand',
                ),
              ],
            ),
            destinations: items.map((item) => NavigationRailDestination(
              icon: Icon(item.icon, size: 22),
              selectedIcon: Icon(item.icon, size: 22),
              label: Text(item.label),
            )).toList(),
          ),
          VerticalDivider(thickness: 0.5, width: 0.5, color: theme.colorScheme.outline),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ═══════════════════════════════════════════
  // MOBILE LAYOUT — Bottom nav + Drawer
  // ═══════════════════════════════════════════
  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    final bottomItems = _bottomNavItems;

    // Calculate bottom nav selected index
    int bottomIndex = 0;
    final currentLocation = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < bottomItems.length; i++) {
      if (bottomItems[i].route == currentLocation) {
        bottomIndex = i;
        break;
      }
    }

    // If current route is in "More" section, select the More tab
    if (bottomIndex == 0 && currentLocation != '/') {
      final isInBottomItems = bottomItems.any((item) => item.route == currentLocation);
      if (!isInBottomItems) bottomIndex = bottomItems.length - 1;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_visibleNavItems[_selectedIndex].label),
        actions: [
          _buildNotificationBell(theme),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        child: Column(
          children: [
            _buildLogoHeader(theme),
            Divider(color: theme.colorScheme.outline),
            Expanded(child: _buildNavList(theme)),
            Divider(color: theme.colorScheme.outline),
            _buildUserTile(theme),
          ],
        ),
      ),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.colorScheme.outline, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: bottomIndex.clamp(0, bottomItems.length - 1),
          onTap: (i) {
            if (bottomItems[i].route == '__more__') {
              _scaffoldKey.currentState?.openDrawer();
            } else {
              context.go(bottomItems[i].route);
            }
          },
          items: bottomItems.map((item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          )).toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // SHARED COMPONENTS
  // ═══════════════════════════════════════════
  Widget _buildTopBar() {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            _visibleNavItems[_selectedIndex].label,
            style: theme.textTheme.titleLarge,
          ),
          const Spacer(),
          // Search
          SizedBox(
            width: 240,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildSyncIndicator(context),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.help_outline, color: theme.textTheme.bodySmall?.color),
            onPressed: () => context.goNamed('help'),
            tooltip: 'Help & FAQ',
          ),
          const SizedBox(width: 8),
          _buildNotificationBell(theme),
          const SizedBox(width: 8),
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Text(
              _user.name[0],
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator(BuildContext context) {
    final syncState = ref.watch(syncProvider);
    final isOffline = syncState.pendingItems > 0;
    
    return PopupMenuButton(
      tooltip: 'Sync Status',
      icon: Badge(
        smallSize: 8,
        isLabelVisible: isOffline,
        backgroundColor: Colors.orange,
        child: Icon(
          isOffline ? Icons.cloud_off : Icons.cloud_done, 
          color: isOffline ? Colors.orange : Colors.green
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          child: Text('Offline Sync Engine', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        PopupMenuItem(
          enabled: false,
          child: Text('Pending Items: ${syncState.pendingItems}', style: TextStyle(color: isOffline ? Colors.orange : Colors.green)),
        ),
        if (syncState.lastSync != null)
          PopupMenuItem(
            enabled: false,
            child: Text('Last Sync: ${syncState.lastSync?.toLocal().toString().split('.')[0]}', style: const TextStyle(fontSize: 12)),
          ),
        PopupMenuItem(
          child: const Text('Force Sync Now'),
          onTap: () {
            ref.read(syncProvider.notifier).forceSync();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing data with server...')));
          },
        ),
      ],
    );
  }

  Widget _buildNotificationBell(ThemeData theme) {
    return IconButton(
      icon: Badge(
        smallSize: 8,
        backgroundColor: const Color(0xFFFF5252),
        child: Icon(Icons.notifications_outlined, color: theme.textTheme.bodySmall?.color),
      ),
      onPressed: () {
        context.goNamed('notifications');
      },
      tooltip: 'Notifications',
    );
  }

  Widget _buildUserTile(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user.name,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(_user.role.displayName,
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: theme.textTheme.bodySmall?.color, size: 20),
            onPressed: () => context.go('/login'),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  /// Keyboard shortcuts for desktop (Ctrl+1..9)
  Map<ShortcutActivator, VoidCallback> _buildShortcuts() {
    final items = _visibleNavItems;
    final map = <ShortcutActivator, VoidCallback>{};
    for (int i = 0; i < items.length && i < 9; i++) {
      map[SingleActivator(LogicalKeyboardKey(LogicalKeyboardKey.digit1.keyId + i), control: true)] =
          () => _onDestinationSelected(i);
    }
    return map;
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}
