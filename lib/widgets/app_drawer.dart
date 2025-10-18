import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/auth_repo.dart';
import 'package:stash/providers/ui_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 100,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'Stash',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                currentPage == 'home' ? Icons.home : Icons.home_outlined,
              ),
              title: const Text('Home'),
              selected: currentPage == 'home',
              selectedTileColor: Theme.of(
                context,
              ).colorScheme.secondaryContainer,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(currentPageProvider.notifier).setPage('home');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                currentPage == 'tags' ? Icons.label : Icons.label_outline,
              ),
              title: const Text('Manage Tags'),
              selected: currentPage == 'tags',
              selectedTileColor: Theme.of(
                context,
              ).colorScheme.secondaryContainer,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(currentPageProvider.notifier).setPage('tags');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () {
                          ref.read(authRepoProvider.notifier).signOut();
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
