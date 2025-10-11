import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/tag_repo.dart';
import 'package:stash/widgets/add_tag_dialog.dart';

class TagManagementPage extends ConsumerWidget {
  const TagManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagStream = ref.watch(tagStreamProvider);

    return Scaffold(
      body: tagStream.when(
        data: (tags) {
          if (tags.isEmpty) {
            return const Center(
              child: Text('No tags created yet. Tap the + button to add one!'),
            );
          }
          return ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return ListTile(
                title: Text(tag.name),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AddTagDialog(tagToEdit: tag),
                ),
                leading: Icon(Icons.label_outlined),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
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
                                ref.read(tagRepoProvider).deleteTag(tag.id);
                                Navigator.of(dialogContext).pop();
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
              );
            },
          );
        },
        error: (err, stackTrace) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
