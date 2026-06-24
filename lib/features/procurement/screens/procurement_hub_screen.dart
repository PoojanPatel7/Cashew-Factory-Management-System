import 'package:flutter/material.dart';
import 'supplier_list_tab.dart';
import 'purchase_orders_tab.dart';
import 'payments_tab.dart';

/// Procurement Hub — Main entry point for the Procurement module
class ProcurementHubScreen extends StatelessWidget {
  const ProcurementHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Procurement'),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Suppliers', icon: Icon(Icons.people_alt_outlined)),
              Tab(text: 'Purchase Orders', icon: Icon(Icons.shopping_cart_checkout_rounded)),
              Tab(text: 'Payments', icon: Icon(Icons.payments_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SupplierListTab(),
            PurchaseOrdersTab(),
            PaymentsTab(),
          ],
        ),
      ),
    );
  }
}
