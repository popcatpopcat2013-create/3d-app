import 'package:flutter/material.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/core/theme.dart';
import 'package:photo_swipe/features/home/home_screen.dart';
import 'package:photo_swipe/features/permission/permission_gate.dart';

/// The app shell: theme, and "ask for gallery access first, then show Home".
class PhotoSwipeApp extends StatelessWidget {
  const PhotoSwipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const PermissionGate(child: HomeScreen()),
    );
  }
}
