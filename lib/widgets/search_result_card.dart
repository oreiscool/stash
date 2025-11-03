import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/widgets/highlighted_text.dart';
import 'package:stash/pages/stash_detail_page.dart';
import 'package:stash/utils/date_formatter.dart';
import 'package:stash/providers/ui_providers.dart';
import 'package:stash/providers/timestamp_providers.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/utils/show_snackbar.dart';

class SearchResultCard extends ConsumerStatefulWidget {
  const SearchResultCard({
    super.key,
    required this.stashItem,
    required this.query,
  });

  final StashItem stashItem;
  final String query;

  @override
  ConsumerState<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends ConsumerState<SearchResultCard>
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
      await ref.read(stashRepoProvider).moveToTrash(widget.stashItem.id!);
      if (!context.mounted) return;
      showSnackBar(context, 'Item moved to trash');
    }
  }

  @override
  Widget build(BuildContext context) {
    final timestampFormat = ref
        .watch(timestampPreferenceProvider)
        .maybeWhen(
          data: (format) => format,
          orElse: () => DateFormatStyle.relative,
        );

    // Only watch clock stream if using relative time format
    if (timestampFormat == DateFormatStyle.relative) {
      ref.watch(clockStreamProvider);
    }

    final selectionState = ref.watch(selectionModeProvider);
    final isSelected = selectionState.isSelected(widget.stashItem.id!);
    final isSelectionMode = selectionState.isActive;

    // Disable swipe actions in selection mode
    if (isSelectionMode) {
      return _buildCard(
        context,
        ref,
        timestampFormat,
        isSelected,
        isSelectionMode,
      );
    }

    return Dismissible(
      key: ValueKey(widget.stashItem.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - Delete
          await _handleDelete(context, ref);
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right - Pin/Unpin
          HapticFeedback.lightImpact();
          await ref.read(stashRepoProvider).togglePin(widget.stashItem);
          if (!context.mounted) return false;
          showSnackBar(
            context,
            widget.stashItem.isPinned ? 'Unpinned' : 'Pinned to top',
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
          widget.stashItem.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
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
      child: _buildCard(
        context,
        ref,
        timestampFormat,
        isSelected,
        isSelectionMode,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    DateFormatStyle timestampFormat,
    bool isSelected,
    bool isSelectionMode,
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
            onTap: () {
              if (isSelectionMode) {
                HapticFeedback.selectionClick();
                ref
                    .read(selectionModeProvider.notifier)
                    .toggleSelection(widget.stashItem.id!);
              } else {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        StashDetailPage(stashItem: widget.stashItem),
                    transitionDuration: const Duration(milliseconds: 300),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 300,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          // Scale animation (grows from 0.8 to 1.0)
                          final scaleAnimation =
                              Tween<double>(begin: 0.8, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                ),
                              );

                          // Fade animation
                          final fadeAnimation =
                              Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                ),
                              );

                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          );
                        },
                  ),
                );
              }
            },
            onLongPress: () {
              if (!isSelectionMode) {
                HapticFeedback.heavyImpact();
                ref
                    .read(selectionModeProvider.notifier)
                    .enterSelectionMode(widget.stashItem.id!);
              }
            },
            child: Stack(
              children: [
                Column(
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
                      title: HighlightedText(
                        text: widget.stashItem.content,
                        query: widget.query,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          HighlightedText(
                            text: 'Type: ${widget.stashItem.type}',
                            query: widget.query,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatTimestampByPreference(
                              widget.stashItem.updatedAt?.toDate() ??
                                  widget.stashItem.createdAt.toDate(),
                              timestampFormat,
                            ),
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.stashItem.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: widget.stashItem.tags.map((tag) {
                            final isMatchingTag = tag.toLowerCase().contains(
                              widget.query.toLowerCase().trim(),
                            );
                            return Chip(
                              label: isMatchingTag
                                  ? HighlightedText(
                                      text: tag,
                                      query: widget.query,
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : Text(
                                      tag,
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                if (widget.stashItem.isPinned && !isSelectionMode)
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
        ),
      ),
    );
  }
}
