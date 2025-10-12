import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/pages/home_page.dart';
import 'package:stash/pages/tag_management_page.dart';
import 'package:stash/pages/search_page.dart';
import 'package:stash/providers/ui_providers.dart';
import 'package:stash/widgets/add_stash_item_dialog.dart';
import 'package:stash/widgets/app_drawer.dart';
import 'package:stash/widgets/add_tag_dialog.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    return PopScope(
      canPop: currentPage == 'home',
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentPage != 'home') {
          ref.read(currentPageProvider.notifier).setPage('home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: currentPage == 'home'
              ? Hero(
                  tag: 'search-bar',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SearchPage(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Search your stash...',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const Text('Manage Tags'),
          centerTitle: currentPage == 'tags',
          actions: currentPage == 'home'
              ? [IconButton(onPressed: () {}, icon: const Icon(Icons.settings))]
              : [],
        ),
        drawer: const AppDrawer(),
        body: currentPage == 'home'
            ? const HomePage()
            : currentPage == 'tags'
            ? const TagManagementPage()
            : const HomePage(),
        floatingActionButton: currentPage == 'home'
            ? FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddStashItemDialog(),
                  );
                },
              )
            : currentPage == 'tags'
            ? FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTagDialog(),
                  );
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
