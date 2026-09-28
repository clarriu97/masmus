import 'package:flutter/material.dart';
import 'package:masmus/ui/theme/app_theme.dart';

/// [child] on a screen with the app's theme.
Widget buildTestApp(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.tapete,
  home: Scaffold(body: Center(child: child)),
);
