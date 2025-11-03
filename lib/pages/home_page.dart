import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/widgets/stash_item_card.dart';
import 'package:stash/providers/selection_providers.dart';
import 'package:stash/widgets/selection_action_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stashStream = ref.watch(stashStreamProvider);
    final selectionState = ref.watch(selectionModeProvider);

    return PopScope(
      canPop: !selectionState.isActive,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && selectionState.isActive) {
          ref.read(selectionModeProvider.notifier).exitSelectionMode();
        }
      },
      child: Stack(
        children: [
          stashStream.when(
            data: (items) {
              if (items.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        24,
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
                padding: EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  selectionState.isActive ? 80 : 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return StashItemCard(key: ValueKey(item.id), stashItem: item);
                },
              );
            },
            error: (err, stackTrace) =>
                Center(child: Text('An error occured: $err')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          if (selectionState.isActive)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: stashStream.maybeWhen(
                data: (items) => SelectionActionBar(items: items),
                orElse: () => SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}
