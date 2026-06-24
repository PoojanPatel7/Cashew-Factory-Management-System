import 'package:flutter/material.dart';
import 'stock_list_tab.dart';
// import 'warehouse_map_tab.dart';

class InventoryHubScreen extends StatelessWidget {
  const InventoryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Management'),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Stock List', icon: Icon(Icons.inventory_2_outlined)),
              Tab(text: 'Warehouse Map', icon: Icon(Icons.map_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StockListTab(),
            Center(child: Text('Warehouse Map — Coming Soon')),
          ],
        ),
      ),
    );
  }
}
