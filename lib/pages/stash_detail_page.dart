import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/repos/stash_repo.dart';

class StashDetailPage extends ConsumerStatefulWidget {
  final StashItem stashItem;
  const StashDetailPage({super.key, required this.stashItem});

  @override
  ConsumerState<StashDetailPage> createState() => _StashDetailPageState();
}

class _StashDetailPageState extends ConsumerState<StashDetailPage> {
  late final TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.stashItem.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stashItem.type),
        actions: [
          IconButton(
            onPressed: () {
              if (_isEditing) {
                final updatedContent = widget.stashItem.copyWith(
                  content: _contentController.text.trim(),
                );
                ref.read(stashRepoProvider).updateStashItem(updatedContent);
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline_outlined),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text(
                    'Are you sure you want to permanently delete this item?',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        ref
                            .read(stashRepoProvider)
                            .deleteStashItem(widget.stashItem.id!);
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing
            ? TextField(
                controller: _contentController,
                autofocus: true,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(fontSize: 16),
              )
            : SelectableText(
                widget.stashItem.content,
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
