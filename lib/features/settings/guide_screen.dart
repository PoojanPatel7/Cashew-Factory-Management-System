import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to HM Nuts', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
                const SizedBox(height: 8),
                Text(
                  'This system is designed to help you track every step of your cashew processing lifecycle, from raw stock all the way to finished, packed goods.',
                  style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.8), fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            icon: Icons.inventory_2_rounded,
            color: Colors.orange,
            title: '1. Raw Stock',
            content: 'Everything starts here. When you receive cashew bags from your suppliers, you add them to the Raw Stock.\n\n'
                '• Go to the "Stock" tab.\n'
                '• Click "Add Stock" to record the supplier name, number of bags, and total weight.\n'
                '• This stock represents available inventory that hasn\'t been sorted yet.',
          ),
          _buildSection(
            context,
            icon: Icons.call_split_rounded,
            color: Colors.indigo,
            title: '2. Sorting',
            content: 'Raw stock isn\'t uniform. You must sort it into specific grades or sizes (like W180, W210) before processing.\n\n'
                '• Go to the "Sort" tab.\n'
                '• Select which Raw Stock entry you want to sort.\n'
                '• Define the output sizes (e.g. 50kg of W180, 20kg of W210).\n'
                '• These outputs become "Pending Lots" ready for processing.',
          ),
          _buildSection(
            context,
            icon: Icons.precision_manufacturing_rounded,
            color: Colors.blue,
            title: '3. Processing Pipeline',
            content: 'This is where the magic happens. A "Lot" goes through multiple stages: Boiling, Drying, Peeling, Grading, and finally Packing.\n\n'
                '• Go to the "Process" tab and select a Lot.\n'
                '• Enter the output weight after each stage. The system automatically calculates the Wastage/Shrinkage.\n'
                '• If you make a mistake, you can "Revert" the lot back to any previous stage. This will erase the steps made after that point.',
          ),
          _buildSection(
            context,
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            title: '4. Finished Stock',
            content: 'Once a Lot passes the "Packing" stage, it becomes Finished Stock.\n\n'
                '• Go to the "Done" tab to see all packed stock ready for sale.\n'
                '• You can "Dispatch" this stock. Enter the weight being dispatched, and it will be subtracted from your available finished stock.',
          ),
          _buildSection(
            context,
            icon: Icons.business_rounded,
            color: Colors.purple,
            title: '5. Multi-Factory Management',
            content: 'If you have multiple factories, you can manage them all from one account.\n\n'
                '• Go to the "Factories" tab (or use the Factory Selector dropdown).\n'
                '• Switch between factories to view their specific stock and processing lines.\n'
                '• The Dashboard will aggregate data so you can see your entire operation at a glance.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required IconData icon, required Color color, required String title, required String content}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
