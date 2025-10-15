import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/widgets/stash_item_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stashStream = ref.watch(stashStreamProvider);
    return stashStream.when(
      data: (items) {
        if (items.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight - 24,
              child: const Center(
                child: Text(
                  'Your stash is empty.\nTap the + button to add something!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return StashItemCard(stashItem: item);
          },
        );
      },
      error: (err, stackTrace) => Center(child: Text('An error occured: $err')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
