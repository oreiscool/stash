import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/tag_repo.dart';
import 'package:stash/providers/ui_providers.dart';

class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTags = ref.watch(tagStreamProvider);
    final selectedTags = ref.watch(selectedTagsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Tags',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  if (selectedTags.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref.read(selectedTagsProvider.notifier).clearTags();
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              allTags.when(
                data: (tags) {
                  if (tags.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Center(
                        child: Text(
                          'No tags created yet.\nCreate tags from the drawer menu.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      final isSelected = selectedTags.contains(tag.name);
                      return FilterChip(
                        label: Text(tag.name),
                        selected: isSelected,
                        onSelected: (_) {
                          ref
                              .read(selectedTagsProvider.notifier)
                              .toggleTag(tag.name);
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stackTrace) =>
                    const Center(child: Text('Error loading tags')),
              ),
              const SizedBox(height: 32),
              const Text(
                'Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Coming soon: Light, Dark, System, and Material You themes',
                style: TextStyle(color: Colors.grey),
              ),

              // Add more sections here later:
              // - Sort options
              // - Date format preferences
              // - etc.
            ],
          ),
        );
      },
    );
  }
}
