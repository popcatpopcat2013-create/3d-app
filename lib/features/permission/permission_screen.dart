import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/features/permission/permission_controller.dart';
import 'package:photo_swipe/shared/widgets/status_message.dart';

/// Explains why the app needs the gallery, and lets the user try again
/// or open the phone's settings.
class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen>
    with WidgetsBindingObserver {
  /// True after the user went to the phone's settings, so that coming back
  /// to the app re-checks the permission automatically.
  bool _waitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForSettings) {
      _waitingForSettings = false;
      ref.read(permissionProvider.notifier).retry();
    }
  }

  Future<void> _openSettings() async {
    _waitingForSettings = true;
    await ref.read(permissionProvider.notifier).openSettings();
  }

  @override
  Widget build(BuildContext context) {
    return StatusMessage(
      icon: Icons.photo_library_outlined,
      title: AppStrings.permissionTitle,
      message: AppStrings.permissionMessage,
      actions: [
        FilledButton(
          onPressed: () => ref.read(permissionProvider.notifier).retry(),
          child: const Text(AppStrings.permissionRetry),
        ),
        OutlinedButton(
          onPressed: _openSettings,
          child: const Text(AppStrings.permissionOpenSettings),
        ),
      ],
    );
  }
}
