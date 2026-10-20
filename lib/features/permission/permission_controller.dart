import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/data/providers.dart';

/// Whether the app may read the gallery. The state is `true` when allowed.
/// Asks for access as soon as the app opens.
class PermissionController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.read(photoRepositoryProvider).requestAccess();

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(photoRepositoryProvider).requestAccess(),
    );
  }

  Future<void> openSettings() => ref.read(photoRepositoryProvider).openSettings();
}

final permissionProvider =
    AsyncNotifierProvider<PermissionController, bool>(PermissionController.new);
