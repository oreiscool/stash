import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/tag_repo.dart';

class AddTagDialog extends ConsumerStatefulWidget {
  const AddTagDialog({super.key});

  @override
  ConsumerState<AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends ConsumerState<AddTagDialog> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a New Tag'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextField(
                controller: _contentController,
                autofocus: true,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter tag name...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final tagName = _contentController.text.trim();
            if (tagName.isNotEmpty) {
              ref.read(tagRepoProvider).addTag(tagName);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Tag'),
        ),
      ],
    );
  }
}
