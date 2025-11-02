import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/utils/show_snackbar.dart';
import 'package:stash/utils/trash_utils.dart';

class TrashItemCard extends ConsumerStatefulWidget {
  const TrashItemCard({super.key, required this.stashItem});
  final StashItem stashItem;

  @override
  ConsumerState<TrashItemCard> createState() => _TrashItemCardState();
}

class _TrashItemCardState extends ConsumerState<TrashItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    await ref.read(stashRepoProvider).restoreFromTrash(widget.stashItem.id!);
    if (!context.mounted) return;
    showSnackBar(context, 'Item restored from trash');
  }

  Future<void> _handlePermanentDelete(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete permanently?'),
        content: Text(
          'This item will be permanently deleted.\nThis action cannot be undone.',
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
      await ref.read(stashRepoProvider).permanentlyDelete(widget.stashItem.id!);
      if (!context.mounted) return;
      showSnackBar(context, 'Item permanently deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysText = getDaysRemainingText(widget.stashItem);
    final isExpiring = isExpiringOn(widget.stashItem);
    final selectionState = ref.watch(selectionModeProvider);
    final isSelected = selectionState.isSelected(widget.stashItem.id!);
    final isSelectionMode = selectionState.isActive;

    if (isSelectionMode) {
      return _buildCard(
        context,
        ref,
        isSelected,
        isSelectionMode,
        daysText,
        isExpiring,
      );
    }

    return Dismissible(
      key: ValueKey(widget.stashItem.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - Permanently Delete
          await _handlePermanentDelete(context, ref);
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right - Restore
          await _handleRestore(context, ref);
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
          Icons.restore,
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
          Icons.delete_forever,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: _buildCard(
        context,
        ref,
        isSelected,
        isSelectionMode,
        daysText,
        isExpiring,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    bool isSelected,
    bool isSelectionMode,
    String daysText,
    bool isExpiring,
  ) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedScale(
        scale: isSelectionMode && isSelected ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          child: InkWell(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _scaleController.reverse(),
            onTapCancel: () => _scaleController.reverse(),
            onTap: isSelectionMode
                ? () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(selectionModeProvider.notifier)
                        .toggleSelection(widget.stashItem.id!);
                  }
                : null,
            onLongPress: !isSelectionMode
                ? () {
                    HapticFeedback.heavyImpact();
                    ref
                        .read(selectionModeProvider.notifier)
                        .enterSelectionMode(widget.stashItem.id!);
                  }
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: isSelectionMode
                      ? AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isSelectionMode ? 1 : 0,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(selectionModeProvider.notifier)
                                  .toggleSelection(widget.stashItem.id!);
                            },
                          ),
                        )
                      : null,
                  title: Text(
                    widget.stashItem.content,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Type: ${widget.stashItem.type}'),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            daysText,
                            style: TextStyle(
                              color: isExpiring
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
