import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/data/repos/tag_repo.dart';
import 'package:stash/utils/show_snackbar.dart';

class AddStashItemDialog extends ConsumerStatefulWidget {
  const AddStashItemDialog({super.key});

  @override
  ConsumerState<AddStashItemDialog> createState() => _AddStashItemDialogState();
}

class _AddStashItemDialogState extends ConsumerState<AddStashItemDialog> {
  final _contentController = TextEditingController();
  final _newTagController = TextEditingController();
  String _detectedType = 'Note';
  bool isLink = false;
  final Set<String> _selectedTags = {};
  bool _isCreatingTag = false;

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

  Future<void> _createAndSelectTag() async {
    final tagName = _newTagController.text.trim();
    if (tagName.isEmpty) return;

    setState(() => _isCreatingTag = true);

    try {
      await ref.read(tagRepoProvider).addTag(tagName);

      setState(() {
        _selectedTags.add(tagName);
        _newTagController.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tag "$tagName" created'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create tag: $e')));
    } finally {
      if (mounted) {
        setState(() => _isCreatingTag = false);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagsStream = ref.watch(tagStreamProvider);

    return AlertDialog(
      title: const Text('Add to Stash'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              autofocus: true,
              maxLines: null,
              onChanged: _parseContent,
              decoration: const InputDecoration(
                hintText: 'Paste your link, snippet, or note...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Detected Type: $_detectedType',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tags (optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: const InputDecoration(
                      hintText: 'Create new tag...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _createAndSelectTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isCreatingTag ? null : _createAndSelectTag,
                  icon: _isCreatingTag
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add, size: 20),
                  tooltip: 'Create tag',
                ),
              ],
            ),
            const SizedBox(height: 12),
            tagsStream.when(
              data: (allTags) {
                if (allTags.isEmpty && _selectedTags.isEmpty) {
                  return Text(
                    'No tags yet. Create one above!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  );
                }

                // Combine existing tags and newly created ones
                final allTagNames = allTags.map((t) => t.name).toSet();
                final displayTags = {...allTagNames, ..._selectedTags}.toList();
                displayTags.sort();

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: displayTags.map((tagName) {
                    return FilterChip(
                      label: Text(tagName),
                      selected: _selectedTags.contains(tagName),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            _selectedTags.add(tagName);
                          } else {
                            _selectedTags.remove(tagName);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(child: CircularProgressIndicator()),
              error: (err, stackTrace) => Text('Could not load tags: $err'),
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
            final content = _contentController.text.trim();
            if (content.isEmpty) return;

            ref
                .read(stashRepoProvider)
                .addStashItem(
                  content: content,
                  type: _detectedType,
                  tags: _selectedTags.toList(),
                );

            Navigator.of(context).pop();
            showSnackBar(context, 'Item stashed!', null);
          },
          child: const Text('Stash It'),
        ),
      ],
    );
  }
}
