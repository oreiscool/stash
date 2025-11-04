import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/widgets/trash_item_card.dart';
import 'package:stash/utils/show_snackbar.dart';
import 'package:stash/widgets/trash_selection_action_bar.dart';
import 'package:stash/providers/selection_providers.dart';

class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedItems = ref.watch(trashStreamProvider);
    final selectionState = ref.watch(selectionModeProvider);

    return PopScope(
      canPop: !selectionState.isActive,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectionState.isActive) {
          ref.read(selectionModeProvider.notifier).exitSelectionMode();
        }
      },
      child: Stack(
        children: [
          deletedItems.when(
            data: (items) {
              if (items.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        24,
                    child: const Center(
                      child: Text(
                        'Trash is empty.\nDeleted items will appear here for 7 days.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${items.length} item${items.length == 1 ? '' : 's'} in Trash',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(stashRepoProvider)
                                    .cleanupOldDeletedItems();
                                if (!context.mounted) return;
                                showSnackBar(
                                  context,
                                  'Expired items cleaned up',
                                  null,
                                );
                              },
                              icon: const Icon(
                                Icons.cleaning_services,
                                size: 18,
                              ),
                              label: const Text('Clean Up'),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Empty Trash?'),
                                    content: const Text(
                                      'Are you sure you want to permanently delete all items in the trash?\nThis action cannot be undone.',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(dialogContext).pop();
                                          HapticFeedback.mediumImpact();

                                          // Delete all items
                                          for (var item in items) {
                                            await ref
                                                .read(stashRepoProvider)
                                                .permanentlyDelete(item.id!);
                                          }

                                          if (!context.mounted) return;
                                          showSnackBar(
                                            context,
                                            'Trash has been emptied',
                                            null,
                                          );
                                        },
                                        child: const Text('Empty Trash'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_forever, size: 18),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                              label: const Text('Empty Trash'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return TrashItemCard(
                          key: ValueKey(item.id),
                          stashItem: item,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            error: (err, stackTrace) {
              return Center(child: Text('An error occurred: $err'));
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
          if (selectionState.isActive)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: deletedItems.maybeWhen(
                data: (items) => TrashSelectionActionBar(items: items),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}
