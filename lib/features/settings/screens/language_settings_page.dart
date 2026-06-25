import 'package:flutter/material.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _selectedLanguage = 'English';

  void _changeLanguage(String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Language'),
        content: Text('Change language to $lang?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() => _selectedLanguage = lang);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language changed to $lang. (Mocked in demo)')));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language / भाषा / ભાષા')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select your preferred app language:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          _buildLangCard('English', 'English', 'A'),
          _buildLangCard('हिंदी (Hindi)', 'Hindi', 'अ'),
          _buildLangCard('ગુજરાતી (Gujarati)', 'Gujarati', 'અ'),
        ],
      ),
    );
  }

  Widget _buildLangCard(String title, String value, String iconChar) {
    final isSelected = _selectedLanguage == value;
    final color = isSelected ? Colors.green : Colors.grey;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Colors.green : Colors.transparent, width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(iconChar, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
        onTap: () => _changeLanguage(value),
      ),
    );
  }
}
