import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/utils/show_snackbar.dart';
import 'package:stash/utils/trash_utils.dart';

class TrashItemCard extends ConsumerWidget {
  const TrashItemCard({super.key, required this.stashItem});
  final StashItem stashItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysText = getDaysRemainingText(stashItem);
    final isExpiring = isExpiringOn(stashItem);
    final selectionState = ref.watch(selectionModeProvider);
    final isSelected = selectionState.isSelected(stashItem.id!);
    final isSelectionMode = selectionState.isActive;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: isSelectionMode
            ? () {
                HapticFeedback.selectionClick();
                ref
                    .read(selectionModeProvider.notifier)
                    .toggleSelection(stashItem.id!);
              }
            : null,
        onLongPress: !isSelectionMode
            ? () {
                HapticFeedback.heavyImpact();
                ref
                    .read(selectionModeProvider.notifier)
                    .enterSelectionMode(stashItem.id!);
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: isSelectionMode
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) {
                        HapticFeedback.selectionClick();
                        ref
                            .watch(selectionModeProvider.notifier)
                            .toggleSelection(stashItem.id!);
                      },
                    )
                  : null,
              title: Text(
                stashItem.content,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Type: ${stashItem.type}'),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: Theme.of(context).dividerColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        daysText,
                        style: TextStyle(
                          color: isExpiring
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: isExpiring
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await ref
                            .read(stashRepoProvider)
                            .restoreFromTrash(stashItem.id!);
                        if (!context.mounted) return;
                        showSnackBar(context, 'Item restored');
                      },
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Restore'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete Permanently?'),
                            content: const Text(
                              'This item will be permanently deleted.\nThis action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  HapticFeedback.mediumImpact();
                                  await ref
                                      .read(stashRepoProvider)
                                      .permanentlyDelete(stashItem.id!);
                                  if (!context.mounted) return;
                                  showSnackBar(context, 'Permanently deleted');
                                },
                                child: const Text('Delete'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
