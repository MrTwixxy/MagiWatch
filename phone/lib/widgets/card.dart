import 'package:flutter/material.dart';

class MagiCard extends StatelessWidget {
  const MagiCard(
      {super.key,
      required this.child,
      this.title,
      this.leading,
      this.trailing,
      this.isFilled = false,
      this.elevation = 1});

  final Widget child;
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;
  final double elevation;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: isFilled ? 0 : elevation,
        shadowColor: elevation == 1 ? Colors.transparent : null,
        color: isFilled ? Theme.of(context).colorScheme.surfaceVariant : null,
        margin: EdgeInsets.zero,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                ListTile(
                  title: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleMedium!,
                    child: title!,
                  ),
                  leading: leading,
                  trailing: trailing,
                  contentPadding:
                      trailing != null ? const EdgeInsets.only(left: 16) : null,
                  dense: true,
                ),
              child
            ]));
  }
}
