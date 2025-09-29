import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class StashDetailPage extends ConsumerStatefulWidget {
  final StashItem stashItem;
  const StashDetailPage({super.key, required this.stashItem});

  @override
  ConsumerState<StashDetailPage> createState() => _StashDetailPageState();
}

class _StashDetailPageState extends ConsumerState<StashDetailPage> {
  late final TextEditingController _contentController;
  late StashItem _currentItem;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.stashItem;
    _contentController = TextEditingController(text: widget.stashItem.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String _parseContentType(String content) {
    final trimmedContent = content.trim();
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
      caseSensitive: false,
    );

    final isSnippet =
        trimmedContent.contains(';') ||
        trimmedContent.contains('{') ||
        trimmedContent.contains('}') ||
        trimmedContent.contains('(') ||
        trimmedContent.contains(')') ||
        trimmedContent.contains('=') ||
        trimmedContent.contains('[');

    if (urlRegex.hasMatch(trimmedContent)) {
      return 'Link';
    } else if (isSnippet) {
      return 'Snippet';
    } else {
      return 'Note';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentItem.type),
        actions: [
          IconButton(
            onPressed: () {
              if (_isEditing) {
                final updatedType = _parseContentType(_contentController.text);
                final updatedContent = _contentController.text.trim();
                final updatedItem = _currentItem.copyWith(
                  content: updatedContent,
                  type: updatedType,
                );
                ref.read(stashRepoProvider).updateStashItem(updatedItem);
                setState(() {
                  _currentItem = updatedItem;
                });
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
            : Linkify(
                onOpen: (link) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final uri = Uri.parse(link.url);
                  if (!await launchUrl(uri)) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Could not open ${link.url}')),
                    );
                  }
                },
                text: _currentItem.content,
                style: const TextStyle(fontSize: 16),
                options: LinkifyOptions(looseUrl: true),
                linkStyle: const TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
      ),
    );
  }
}
