import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/tag_repo.dart';
import 'package:stash/data/models/tag.dart';
import 'package:stash/utils/show_snackbar.dart';

class AddTagDialog extends ConsumerStatefulWidget {
  const AddTagDialog({super.key, this.tagToEdit});
  final Tag? tagToEdit;

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
  void initState() {
    super.initState();
    if (widget.tagToEdit != null) {
      _contentController.text = widget.tagToEdit!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tagToEdit != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Tag' : 'Add a New Tag'),
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
              if (isEditing) {
                ref
                    .read(tagRepoProvider)
                    .updateTag(widget.tagToEdit!.id, tagName);
                Navigator.of(context).pop();
                showSnackBar(context, 'Tag updated to "$tagName"');
              } else {
                ref.read(tagRepoProvider).addTag(tagName);
                Navigator.of(context).pop();
                showSnackBar(context, 'Tag "$tagName" added');
              }
            }
          },
          child: Text(isEditing ? 'Save' : 'Add Tag'),
        ),
      ],
    );
  }
}
