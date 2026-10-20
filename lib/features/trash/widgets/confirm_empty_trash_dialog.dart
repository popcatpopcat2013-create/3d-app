import 'package:flutter/material.dart';
import 'package:photo_swipe/core/format.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/core/theme.dart';

/// Asks "really delete these photos for good?". Resolves to true on confirm.
/// (Android shows its own confirmation after this one.)
Future<bool?> showConfirmEmptyTrashDialog(BuildContext context, int count) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(AppStrings.emptyTrashConfirmTitle),
      content: Text(AppStrings.emptyTrashConfirmMessage(formatCount(count))),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.trash),
          child: const Text(AppStrings.confirmDelete),
        ),
      ],
    ),
  );
}
