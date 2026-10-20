import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/core/format.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/features/library/library_controller.dart';
import 'package:photo_swipe/features/swipe/swipe_screen.dart';
import 'package:photo_swipe/features/trash/trash_screen.dart';

/// The frame around the main screens: a bottom bar to switch between
/// swiping and the trash. New top-level screens get a tab here.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _swipeTab = 0;
  static const _trashTab = 1;

  int _tab = _swipeTab;

  @override
  Widget build(BuildContext context) {
    final trashCount = ref.watch(
      libraryProvider.select((library) => library.valueOrNull?.trashed.length ?? 0),
    );

    Widget trashIcon(IconData icon) => Badge(
          isLabelVisible: trashCount > 0,
          label: Text(formatCount(trashCount)),
          child: Icon(icon),
        );

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          SwipeScreen(onOpenTrash: () => setState(() => _tab = _trashTab)),
          const TrashScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: AppStrings.tabSwipe,
          ),
          NavigationDestination(
            icon: trashIcon(Icons.delete_outline),
            selectedIcon: trashIcon(Icons.delete),
            label: AppStrings.tabTrash,
          ),
        ],
      ),
    );
  }
}
