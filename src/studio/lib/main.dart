import 'package:flutter/material.dart';
import 'screens/portal_screen.dart';
import 'theme.dart';

void main() {
  runApp(const QtCloudApp());
}

class QtCloudApp extends StatelessWidget {
  const QtCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '量潮云',
      theme: AppTheme.lightTheme,
      home: const PortalScreen(),
    );
  }
}
