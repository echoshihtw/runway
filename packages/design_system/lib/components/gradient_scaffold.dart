import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

/// Dark navy fading down from the top, the ground every screen sits on.
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final bool safeArea;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const GradientScaffold({
    super.key,
    required this.body,
    this.safeArea = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
        child: safeArea ? SafeArea(child: body) : body,
      ),
    );
  }
}
