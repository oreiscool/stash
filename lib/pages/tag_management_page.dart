import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagManagementPage extends ConsumerWidget {
  const TagManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tags'), centerTitle: true),
      body: const Center(
        child: Text('Tag management functionality coming soon!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show a dialog to create a new tag
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
