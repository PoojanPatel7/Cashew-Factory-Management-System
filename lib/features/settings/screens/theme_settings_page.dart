import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme_provider.dart';

/// Theme Settings Page — preview cards to switch between 5 themes
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Theme', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Select a theme that suits your preference',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),

            // Theme cards grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: AppThemeMode.values.length,
                  itemBuilder: (ctx, i) {
                    final mode = AppThemeMode.values[i];
                    final isSelected = currentTheme == mode;
                    final themeData = getThemeData(mode);

                    return GestureDetector(
                      onTap: () => ref.read(themeProvider.notifier).setTheme(mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: themeData.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? themeData.colorScheme.primary
                                : theme.colorScheme.outline,
                            width: isSelected ? 2 : 0.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(
                                  color: themeData.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 16, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Color preview circles
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _colorDot(themeData.scaffoldBackgroundColor, 18),
                                const SizedBox(width: 6),
                                _colorDot(themeData.colorScheme.primary, 18),
                                const SizedBox(width: 6),
                                _colorDot(themeData.colorScheme.secondary, 18),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Mini preview bar
                            Container(
                              width: 80, height: 6,
                              decoration: BoxDecoration(
                                color: themeData.colorScheme.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Icon(mode.icon,
                              color: isSelected
                                  ? themeData.colorScheme.primary
                                  : theme.textTheme.bodySmall?.color,
                              size: 22),
                            const SizedBox(height: 6),
                            Text(mode.displayName,
                              style: TextStyle(
                                color: isSelected
                                    ? themeData.colorScheme.primary
                                    : theme.textTheme.bodyMedium?.color,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              )),
                            Text(mode.description,
                              style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color),
                              textAlign: TextAlign.center),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Icon(Icons.check_circle, color: themeData.colorScheme.primary, size: 18),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // Font size section
            Text('Display', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildToggleRow(theme, Icons.text_fields, 'Font Size', 'Medium'),
            const SizedBox(height: 12),
            _buildToggleRow(theme, Icons.animation, 'Animations', 'Enabled'),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
    );
  }

  Widget _buildToggleRow(ThemeData theme, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: theme.textTheme.bodySmall?.color, size: 20),
        ],
      ),
    );
  }
}
