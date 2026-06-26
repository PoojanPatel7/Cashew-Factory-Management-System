import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class FactorySelector extends StatefulWidget {
  const FactorySelector({super.key});

  @override
  State<FactorySelector> createState() => _FactorySelectorState();
}

class _FactorySelectorState extends State<FactorySelector> {
  List<dynamic> _factories = [];
  String? _selectedFactoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFactories();
  }

  Future<void> _loadFactories() async {
    try {
      final res = await FirebaseFirestore.instance.collection('factories').get();
      final list = res.docs.map((e) {
        final data = e.data();
        data['id'] = e.id;
        return data;
      }).toList();
      final currentId = await ApiClient().getFactoryId();
      if (mounted) {
        setState(() {
          _factories = list;
          _isLoading = false;
          if (_factories.isNotEmpty) {
            _selectedFactoryId = currentId ?? _factories.first['id'];
            if (currentId == null) {
              ApiClient().setFactoryId(_selectedFactoryId!);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onFactorySelected(String? newId) async {
    if (newId != null) {
      await ApiClient().setFactoryId(newId);
      setState(() => _selectedFactoryId = newId);
      // Restart app or reload data
      // For now, just show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Switched Factory! Please refresh screen.', style: TextStyle(color: Colors.white))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator());
    if (_factories.isEmpty) return const Text('No Factories');

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedFactoryId,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor: Theme.of(context).colorScheme.primary,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        items: _factories.map((f) {
          return DropdownMenuItem<String>(
            value: f['id'],
            child: Text(f['name']),
          );
        }).toList(),
        onChanged: _onFactorySelected,
      ),
    );
  }
}
