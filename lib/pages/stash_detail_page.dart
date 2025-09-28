import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/repos/stash_repo.dart';

class StashDetailPage extends ConsumerWidget {
  final StashItem stashItem;
  const StashDetailPage({super.key, required this.stashItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stashItem.type),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_outlined),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text(
                    'Are you sure you want to permanently delete this item?',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        ref
                            .read(stashRepoProvider)
                            .deleteStashItem(stashItem.id!);
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          stashItem.content,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
