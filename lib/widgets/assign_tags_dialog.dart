import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/tag.dart';
import 'package:stash/data/repos/tag_repo.dart';

class AssignTagsDialog extends ConsumerStatefulWidget {
  const AssignTagsDialog({super.key, required this.initialSelectedTags});
  final List<String> initialSelectedTags;

  @override
  ConsumerState<AssignTagsDialog> createState() => _AssignTagsDialogState();
}

class _AssignTagsDialogState extends ConsumerState<AssignTagsDialog> {
  late Set<String> _selectedTags;
  final TextEditingController _newTagController = TextEditingController();
  bool _isCreatingTag = false;

  @override
  void initState() {
    super.initState();
    _selectedTags = Set.from(widget.initialSelectedTags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
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
          content: Text('Tag "$tagName" created and added'),
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
  Widget build(BuildContext context) {
    final tagsStream = ref.watch(tagStreamProvider);

    return AlertDialog(
      title: const Text('Assign Tags'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    ),
                    onSubmitted: (_) => _createAndSelectTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isCreatingTag ? null : _createAndSelectTag,
                  icon: _isCreatingTag
                      ? const SizedBox(child: CircularProgressIndicator())
                      : const Icon(Icons.add),
                  tooltip: 'Create tag',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            tagsStream.when(
              data: (allTags) {
                if (allTags.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No tags yet.\nCreate one above!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allTags.map((Tag tag) {
                        return FilterChip(
                          label: Text(tag.name),
                          selected: _selectedTags.contains(tag.name),
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                _selectedTags.add(tag.name);
                              } else {
                                _selectedTags.remove(tag.name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stackTrace) =>
                  Center(child: Text('Could not load tags: $err')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedTags.toList());
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
