import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/pages/stash_detail_page.dart';
import 'package:stash/utils/date_formatter.dart';
import 'package:stash/providers/ui_providers.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/utils/show_snackbar.dart';

class StashItemCard extends ConsumerWidget {
  const StashItemCard({super.key, required this.stashItem});
  final StashItem stashItem;

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Move item to Trash?'),
        content: Text(
          'This item will be moved to trash.\nYou can restore it within 7 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Move to Trash'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await ref.read(stashRepoProvider).moveToTrash(stashItem.id!);
      if (!context.mounted) return;
      showSnackBar(context, 'Item moved to trash');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockStreamProvider);
    final selectionState = ref.watch(selectionModeProvider);
    final isSelected = selectionState.isSelected(stashItem.id!);
    final isSelectionMode = selectionState.isActive;

    // Disable swipe actions in selection mode
    if (isSelectionMode) {
      return _buildCard(context, ref, isSelected, isSelectionMode);
    }

    return Dismissible(
      key: ValueKey(stashItem.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - Delete
          await _handleDelete(context, ref);
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right - Pin/Unpin
          HapticFeedback.lightImpact();
          await ref.read(stashRepoProvider).togglePin(stashItem);
          if (!context.mounted) return false;
          showSnackBar(
            context,
            stashItem.isPinned ? 'Unpinned' : 'Pinned to top',
          );
          return false;
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          stashItem.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: _buildCard(context, ref, isSelected, isSelectionMode),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    bool isSelected,
    bool isSelectionMode,
  ) {
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
        onTap: () {
          if (isSelectionMode) {
            HapticFeedback.selectionClick();
            ref
                .read(selectionModeProvider.notifier)
                .toggleSelection(stashItem.id!);
          } else {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StashDetailPage(stashItem: stashItem),
              ),
            );
          }
        },
        onLongPress: () {
          if (!isSelectionMode) {
            HapticFeedback.heavyImpact();
            ref
                .read(selectionModeProvider.notifier)
                .enterSelectionMode(stashItem.id!);
          }
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) {
                            HapticFeedback.selectionClick();
                            ref
                                .read(selectionModeProvider.notifier)
                                .toggleSelection(stashItem.id!);
                          },
                        )
                      : null,
                  title: Text(
                    stashItem.content,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Text('Type: ${stashItem.type}'),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: Theme.of(context).dividerColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatItemTimestamp(
                          stashItem.createdAt.toDate(),
                          stashItem.updatedAt?.toDate(),
                        ),
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
                if (stashItem.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: stashItem.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(fontSize: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
            if (stashItem.isPinned && !isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.push_pin,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
