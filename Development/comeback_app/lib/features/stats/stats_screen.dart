import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('Stats Coming Soon', style: AppTextStyles.body),
      ),
    );
  }
}
