import 'package:flutter/material.dart';
import 'theme.dart';

void main() {
  runApp(const QtCloudApp());
}

class QtCloudApp extends StatelessWidget {
  const QtCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '量潮云工作台',
      theme: AppTheme.lightTheme,
      home: const _Entry(),
    );
  }
}

/// 入口占位：功能已移除，仅保留可启动的壳。
class _Entry extends StatelessWidget {
  const _Entry();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('量潮云工作台', style: TextStyle(fontSize: 20))),
    );
  }
}
