import 'package:flutter/material.dart';

/// Reusable Confirmation Dialog for ALL data push operations
/// Shows data preview before confirming any create/update/delete action
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ConfirmField> fields;
  final List<String> warnings;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    this.icon = Icons.check_circle_outline,
    required this.fields,
    this.warnings = const [],
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    required this.onConfirm,
  });

  /// Show the confirmation dialog — returns true if confirmed
  static Future<bool> show(
    BuildContext context, {
    required String title,
    IconData icon = Icons.check_circle_outline,
    required List<ConfirmField> fields,
    List<String> warnings = const [],
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    required VoidCallback onConfirm,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConfirmationDialog(
        title: title,
        icon: icon,
        fields: fields,
        warnings: warnings,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
    return result ?? false;
  }

  /// Show a delete confirmation dialog with red styling
  static Future<bool> showDelete(
    BuildContext context, {
    required String itemName,
    String? details,
    required VoidCallback onConfirm,
  }) {
    return show(
      context,
      title: 'Delete $itemName?',
      icon: Icons.delete_outline_rounded,
      fields: [
        if (details != null) ConfirmField(label: 'Item', value: details),
      ],
      warnings: ['This action cannot be undone'],
      confirmLabel: 'Delete',
      confirmColor: const Color(0xFFFF5252),
      onConfirm: onConfirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = confirmColor ?? theme.colorScheme.primary;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: theme.colorScheme.outline, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Data fields
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline, width: 0.5),
                    ),
                    child: Column(
                      children: fields.asMap().entries.map((entry) {
                        final field = entry.value;
                        final isLast = entry.key == fields.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      field.label,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      field.value,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: field.isBold ? FontWeight.w700 : FontWeight.w500,
                                        color: field.valueColor,
                                      ),
                                    ),
                                  ),
                                  if (field.isEncrypted)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(Icons.lock, size: 14, color: theme.colorScheme.primary),
                                    ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                height: 1,
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  // Warnings
                  if (warnings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...warnings.map((w) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9100).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9100), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              w,
                              style: const TextStyle(color: Color(0xFFFF9100), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(cancelLabel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            onConfirm();
                            Navigator.of(context).pop(true);
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(confirmLabel),
                          style: confirmColor != null
                              ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Field displayed in the confirmation dialog
class ConfirmField {
  final String label;
  final String value;
  final bool isBold;
  final bool isEncrypted;
  final Color? valueColor;

  const ConfirmField({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isEncrypted = false,
    this.valueColor,
  });
}
