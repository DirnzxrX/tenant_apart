import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  runApp(const TenantHubApp());
}

class TenantHubApp extends StatelessWidget {
  const TenantHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TenantHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
