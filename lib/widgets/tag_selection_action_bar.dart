import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/tag.dart';
import 'package:stash/data/repos/tag_repo.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/utils/show_snackbar.dart';

class TagSelectionActionBar extends ConsumerWidget {
  const TagSelectionActionBar({super.key, required this.tags});
  final List<Tag> tags;

  Future<void> _handleBulkDelete(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedIds,
  ) async {
    final tagNames = selectedIds
        .map((id) => tags.firstWhere((tag) => tag.id == id).name)
        .join(', ');

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${selectedIds.length} tag(s)?'),
        content: Text(
          'Are you sure you want to delete:\n$tagNames\n\nThis will remove these tags from all items.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      HapticFeedback.mediumImpact();
      final repo = ref.read(tagRepoProvider);

      if (!context.mounted) return;
      // Exit selection mode immediately for better UX
      ref.read(selectionModeProvider.notifier).exitSelectionMode();
      showSnackBar(context, '${selectedIds.length} tag(s) deleted', null);

      // Delete all tags in parallel to avoid errors when exiting selection mode while widget is mounted
      await Future.wait(selectedIds.map((id) => repo.deleteTag(id)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionModeProvider);

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  ref.read(selectionModeProvider.notifier).exitSelectionMode();
                },
                label: Text('${selectionState.selectedCount} selected'),
                icon: const Icon(Icons.close, size: 20),
              ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    _handleBulkDelete(context, ref, selectionState.selectedIds),
                icon: Icon(Icons.delete_outline),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
