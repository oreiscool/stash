import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/repos/auth_repo.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:stash/widgets/add_stash_item_dialog.dart';
import 'package:stash/widgets/stash_item_card.dart';
import 'package:stash/pages/tag_management_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stashStream = ref.watch(stashStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 100,
              child: const DrawerHeader(
                child: Center(
                  child: Text(
                    'Stash',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('Manage Tags'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TagManagementPage(),
                ),
              ),
            ),
            // TODO: Add a ListTile for the Settings page later
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
                          ref.read(authRepoProvider).signOut();
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddStashItemDialog(),
          );
        },
      ),
      body: stashStream.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Your stash is empty.\nTap the + button to add something.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
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
        error: (err, stackTrace) =>
            Center(child: Text('An error occured: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
