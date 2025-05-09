import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppBarGradient extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final double? elevation;
  final Gradient? gradient;
  final Brightness? brightness;
  final bool centerTitle;

  const AppBarGradient({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.elevation = 0.0,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF062D8A), Color(0xFF8800FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.brightness,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: elevation,
      centerTitle: centerTitle,
      title: title,
      leading: leading,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? const LinearGradient(
            colors: [Color(0xFF062D8A), Color(0xFF8800FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      systemOverlayStyle: brightness != null
          ? SystemUiOverlayStyle(
        statusBarIconBrightness: brightness,
        statusBarBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      )
          : null,
    );
  }
}