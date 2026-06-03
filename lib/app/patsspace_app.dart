import 'package:flutter/material.dart';
import 'package:pats_space/app/navigation/app_shell.dart';
import 'package:pats_space/core/theme/app_theme.dart';

class PatsspaceApp extends StatelessWidget {
  const PatsspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patsspace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
