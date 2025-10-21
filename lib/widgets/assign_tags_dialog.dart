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

  @override
  void initState() {
    super.initState();
    _selectedTags = Set.from(widget.initialSelectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final tagsStream = ref.watch(tagStreamProvider);
    return AlertDialog(
      title: const Text('Assign Tags'),
      content: SizedBox(
        width: double.maxFinite,
        child: tagsStream.when(
          data: (allTags) {
            if (allTags.isEmpty) {
              return const Center(child: Text('No tags created yet'));
            }
            return Wrap(
              spacing: 8,
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
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stackTrace) =>
              const Center(child: Text('Could not load tags')),
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
