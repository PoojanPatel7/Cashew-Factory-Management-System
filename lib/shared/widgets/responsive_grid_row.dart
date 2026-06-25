import 'package:flutter/material.dart';

class ResponsiveGridRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double crossAxisSpacing;

  const ResponsiveGridRow({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          // Desktop / Tablet: Use a Row with Expanded children
          final rowChildren = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            rowChildren.add(Expanded(child: children[i]));
            if (i < children.length - 1) {
              rowChildren.add(SizedBox(width: spacing));
            }
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          );
        } else {
          // Mobile: Use a Column
          final colChildren = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            colChildren.add(children[i]);
            if (i < children.length - 1) {
              colChildren.add(SizedBox(height: runSpacing));
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: colChildren,
          );
        }
      },
    );
  }
}
