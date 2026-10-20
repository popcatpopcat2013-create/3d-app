import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/features/permission/permission_controller.dart';
import 'package:photo_swipe/features/permission/permission_screen.dart';

/// Shows [child] only once the user has allowed gallery access.
/// Until then it shows a waiting view or the permission screen.
class PermissionGate extends ConsumerWidget {
  const PermissionGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(permissionProvider);

    return permission.when(
      loading: () => const Scaffold(
        body: SafeArea(child: _CheckingView()),
      ),
      error: (_, __) => const Scaffold(
        body: SafeArea(child: PermissionScreen()),
      ),
      data: (granted) => granted
          ? child
          : const Scaffold(
              body: SafeArea(child: PermissionScreen()),
            ),
    );
  }
}

class _CheckingView extends StatelessWidget {
  const _CheckingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(AppStrings.checkingPermission),
        ],
      ),
    );
  }
}
