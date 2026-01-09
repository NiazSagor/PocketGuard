import 'package:flutter/material.dart';
import 'package:pocket_guard/settings/style.dart';

class SettingsItem extends StatelessWidget {
  final Icon icon;
  final String title;
  final Widget? titleWidget;
  final VoidCallback onPressed;
  final String? subtitle;
  final Color? iconBackgroundColor;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
    this.titleWidget,
    this.subtitle,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: iconBackgroundColor ?? Colors.blue,
          child: icon,
        ),
        title: titleWidget ?? Text(title, style: titleTextStyle),
        subtitle: subtitle != null
            ? Text(subtitle!, style: subtitleTextStyle)
            : null,
      ),
    );
  }
}
