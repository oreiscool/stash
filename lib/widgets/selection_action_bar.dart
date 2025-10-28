import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/utils/show_snackbar.dart';
import 'package:stash/widgets/assign_tags_dialog.dart';

class SelectionActionBar extends ConsumerWidget {
  const SelectionActionBar({
    super.key,
    required this.items,
    this.showTagAction = true,
    this.showPinActions = true,
  });

  final List<StashItem> items;
  final bool showTagAction;
  final bool showPinActions;

  Future<void> _handleBulkDelete(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedIds,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Move ${selectedIds.length} item(s) to Trash?'),
        content: Text(
          'These items will be moved to trash.\nYou can restore them within 7 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Move to Trash'),
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
      final repo = ref.read(stashRepoProvider);

      if (!context.mounted) return;
      // Exit selection mode immediately for better UX
      ref.read(selectionModeProvider.notifier).exitSelectionMode();
      showSnackBar(context, '${selectedIds.length} item(s) moved to trash');

      // Delete all items in parallel to avoid errors when exiting selection mode while widget is mounted
      Future.wait(selectedIds.map((id) => repo.moveToTrash(id)));
    }
  }

  Future<void> _handleBulkPin(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedIds,
  ) async {
    // Check if any selected item is unpinned
    final hasUnpinned = selectedIds.any((id) {
      final item = items.firstWhere((item) => item.id == id);
      return !item.isPinned;
    });

    // If any item is unpinned, pin everything
    // Otherwise unpin everything
    final shouldPin = hasUnpinned;

    HapticFeedback.lightImpact();
    final repo = ref.read(stashRepoProvider);

    if (!context.mounted) return;
    // Exit selection mode immediately for better UX
    ref.read(selectionModeProvider.notifier).exitSelectionMode();
    showSnackBar(
      context,
      shouldPin
          ? '${selectedIds.length} item(s) pinned'
          : '${selectedIds.length} item(s) unpinned',
    );

    // Pin/unpin all items in parallel for errors that also occur with the deletion
    Future.wait(
      selectedIds.map((id) {
        final item = items.firstWhere((item) => item.id == id);
        if (item.isPinned != shouldPin) {
          return repo.togglePin(item);
        }
        return Future.value(); // Return completed future for items that don't need updating
      }),
    );
  }

  Future<void> _handleBulkTagging(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedIds,
  ) async {
    final selectedTags = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) =>
          const AssignTagsDialog(initialSelectedTags: []),
    );

    if (selectedTags != null && context.mounted) {
      HapticFeedback.lightImpact();
      final repo = ref.read(stashRepoProvider);

      for (final id in selectedIds) {
        final item = items.firstWhere((item) => item.id == id);
        final mergedTags = {...item.tags, ...selectedTags}.toList();
        final updatedItem = item.copyWith(tags: mergedTags);
        await repo.updateStashItem(updatedItem, updateTimeStamp: false);
      }

      ref.read(selectionModeProvider.notifier).exitSelectionMode();
      if (!context.mounted) return;
      showSnackBar(context, 'Tags added to ${selectedIds.length} item(s)');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionModeProvider);

    // Determine if we should show pin or unpin button
    final hasUnpinned = selectionState.selectedIds.any((id) {
      try {
        final item = items.firstWhere((item) => item.id == id);
        return !item.isPinned;
      } catch (e) {
        return false;
      }
    });

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
              if (showPinActions)
                IconButton(
                  onPressed: () =>
                      _handleBulkPin(context, ref, selectionState.selectedIds),
                  icon: Icon(
                    hasUnpinned ? Icons.push_pin_outlined : Icons.push_pin,
                  ),
                  tooltip: hasUnpinned ? 'Pin' : 'Unpin',
                ),
              if (showTagAction)
                IconButton(
                  onPressed: () => _handleBulkTagging(
                    context,
                    ref,
                    selectionState.selectedIds,
                  ),
                  icon: const Icon(Icons.label_outline),
                  tooltip: 'Add tags',
                ),
              IconButton(
                onPressed: () =>
                    _handleBulkDelete(context, ref, selectionState.selectedIds),
                icon: Icon(Icons.delete_outline),
                tooltip: 'Move to trash',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
