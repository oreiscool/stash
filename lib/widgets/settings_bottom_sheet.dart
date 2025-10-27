import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/tag_repo.dart';
import 'package:stash/providers/ui_providers.dart';
import 'package:stash/providers/theme_providers.dart';

class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTags = ref.watch(tagStreamProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final themeSettingsAsync = ref.watch(themeSettingsProvider);

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
              const Text(
                'Appearance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              themeSettingsAsync.when(
                data: (themeSettings) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Mode
                    const Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'system',
                          label: Text('System'),
                          icon: Icon(Icons.brightness_auto, size: 18),
                        ),
                        ButtonSegment(
                          value: 'light',
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode, size: 18),
                        ),
                        ButtonSegment(
                          value: 'dark',
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode, size: 18),
                        ),
                      ],
                      selected: {themeSettings.themeMode},
                      onSelectionChanged: (Set<String> selected) {
                        ref
                            .read(themeSettingsProvider.notifier)
                            .setThemeMode(selected.first);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Color Scheme
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'system',
                          label: Text('System'),
                          icon: Icon(Icons.palette, size: 18),
                        ),
                        ButtonSegment(
                          value: 'stash',
                          label: Text('Stash'),
                          icon: Icon(Icons.color_lens, size: 18),
                        ),
                      ],
                      selected: {themeSettings.colorScheme},
                      onSelectionChanged: (Set<String> selected) {
                        ref
                            .read(themeSettingsProvider.notifier)
                            .setColorScheme(selected.first);
                      },
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, stackTrace) =>
                    Text('Error loading theme settings: $err'),
              ),
              const SizedBox(height: 32),

              // Tag Filtering Section
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
            ],
          ),
        );
      },
    );
  }
}
