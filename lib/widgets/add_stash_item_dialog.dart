import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/utils/show_snackbar.dart';

class AddStashItemDialog extends ConsumerStatefulWidget {
  const AddStashItemDialog({super.key});

  @override
  ConsumerState<AddStashItemDialog> createState() => _AddStashItemDialogState();
}

class _AddStashItemDialogState extends ConsumerState<AddStashItemDialog> {
  final _contentController = TextEditingController();
  String _detectedType = 'Note';
  bool isLink = false;

  void _parseContent(String content) {
    final trimmedContent = content.trim();
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
      caseSensitive: false,
    );
    isLink = urlRegex.hasMatch(trimmedContent);
    final isSnippet =
        trimmedContent.contains(';') ||
        trimmedContent.contains('{') ||
        trimmedContent.contains('}') ||
        trimmedContent.contains('(') ||
        trimmedContent.contains(')') ||
        trimmedContent.contains('=') ||
        trimmedContent.contains('[') ||
        trimmedContent.contains(']');

    setState(() {
      if (isLink) {
        _detectedType = 'Link';
      } else if (isSnippet) {
        _detectedType = 'Snippet';
      } else {
        _detectedType = 'Note';
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Stash'),
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
                onChanged: _parseContent,
                decoration: const InputDecoration(
                  hintText: 'Paste your link, snippet, or note...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Detected Type: $_detectedType'),
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
            final content = _contentController.text.trim();
            if (content.isEmpty) return;
            ref
                .read(stashRepoProvider)
                .addStashItem(content: content, type: _detectedType);
            Navigator.of(context).pop();
            showSnackBar(context, 'Item stashed!');
          },
          child: const Text('Stash It'),
        ),
      ],
    );
  }
}
