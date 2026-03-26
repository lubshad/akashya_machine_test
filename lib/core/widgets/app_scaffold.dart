import 'package:flutter/material.dart';
import 'animated_background.dart';
import '../theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool useAnimatedBackground;

  const AppScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.useAnimatedBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: useAnimatedBackground
          ? AnimatedBackground(child: body)
          : Container(decoration: AppTheme.mainGradient, child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
