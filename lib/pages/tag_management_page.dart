import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/tag_repo.dart';
import 'package:stash/widgets/add_tag_dialog.dart';
import 'package:stash/utils/show_snackbar.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/widgets/tag_selection_action_bar.dart';

class TagManagementPage extends ConsumerWidget {
  const TagManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagStream = ref.watch(tagStreamProvider);
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
          tagStream.when(
            data: (tags) {
              if (tags.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        24,
                    child: const Center(
                      child: Text(
                        'No tags created yet.\nTap the + button to add one!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  selectionState.isActive ? 80 : 0,
                ),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = selectionState.isSelected(tag.id);

                  return AnimatedScale(
                    scale: isSelected ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ListTile(
                      key: ValueKey(tag.id),
                      leading: selectionState.isActive
                          ? AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  ref
                                      .read(selectionModeProvider.notifier)
                                      .toggleSelection(tag.id);
                                },
                              ),
                            )
                          : Icon(
                              isSelected ? Icons.label : Icons.label_outlined,
                            ),
                      title: Text(tag.name),
                      selected: isSelected,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      onTap: () {
                        if (selectionState.isActive) {
                          ref
                              .read(selectionModeProvider.notifier)
                              .toggleSelection(tag.id);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AddTagDialog(tagToEdit: tag),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!selectionState.isActive) {
                          ref
                              .read(selectionModeProvider.notifier)
                              .enterSelectionMode(tag.id);
                        }
                      },
                      trailing: selectionState.isActive
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete tag',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: Text(
                                        'Are you sure you want to delete the tag "${tag.name}"?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(tagRepoProvider)
                                                .deleteTag(tag.id);
                                            Navigator.of(dialogContext).pop();
                                            showSnackBar(
                                              context,
                                              'Tag "${tag.name}" deleted',
                                            );
                                          },
                                          child: const Text('Delete'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  );
                },
              );
            },
            error: (err, stackTrace) => Center(child: Text('Error: $err')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          if (selectionState.isActive)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: tagStream.maybeWhen(
                data: (tags) => TagSelectionActionBar(tags: tags),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}
