import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/utils/show_snackbar.dart';

class TrashSelectionActionBar extends ConsumerWidget {
  const TrashSelectionActionBar({super.key, required this.items});

  final List<StashItem> items;

  Future<void> _handleBulkRestore(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedIds,
  ) async {
    HapticFeedback.lightImpact();
    final repo = ref.read(stashRepoProvider);

    if (!context.mounted) return;
    // Exit selection mode immediately for better UX
    ref.read(selectionModeProvider.notifier).exitSelectionMode();
    showSnackBar(context, '${selectedIds.length} item(s) restored', null);

    // Restore all items in parallel to avoid errors when exiting selection mode while widget is mounted
    Future.wait(selectedIds.map((id) => repo.restoreFromTrash(id)));
  }

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
          'These items will be permanently deleted.\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete permanently'),
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
      showSnackBar(
        context,
        '${selectedIds.length} item(s) permanently deleted',
        null,
      );

      // Delete all items in parallel to avoid errors when exiting selection mode while widget is mounted
      Future.wait(selectedIds.map((id) => repo.permanentlyDelete(id)));
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
                onPressed: () => _handleBulkRestore(
                  context,
                  ref,
                  selectionState.selectedIds,
                ),
                icon: const Icon(Icons.restore),
                tooltip: 'Restore',
              ),
              IconButton(
                onPressed: () =>
                    _handleBulkDelete(context, ref, selectionState.selectedIds),
                icon: Icon(Icons.delete_outline),
                tooltip: 'Delete permanently',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
