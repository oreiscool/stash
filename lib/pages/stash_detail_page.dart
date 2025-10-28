import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/repos/stash_repo.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stash/widgets/assign_tags_dialog.dart';
import 'package:stash/utils/show_snackbar.dart';

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

  // Define consistent text style for both modes
  static const TextStyle _contentTextStyle = TextStyle(
    fontSize: 16,
    height: 1.5, // Line height multiplier - makes text spacing consistent
  );

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
            onPressed: () async {
              HapticFeedback.lightImpact();
              await ref.read(stashRepoProvider).togglePin(_currentItem);
              setState(() {
                _currentItem = _currentItem.copyWith(
                  isPinned: !_currentItem.isPinned,
                );
              });
              if (!context.mounted) return;
              showSnackBar(
                context,
                _currentItem.isPinned ? 'Pinned to top' : 'Unpinned',
              );
            },
            icon: Icon(
              _currentItem.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            tooltip: _currentItem.isPinned ? 'Unpin' : 'Pin to top',
          ),
          IconButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              await Clipboard.setData(
                ClipboardData(text: _currentItem.content),
              );
              if (!context.mounted) return;
              showSnackBar(context, '${_currentItem.type} copied!');
            },
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy to clipboard',
          ),
          IconButton(
            onPressed: () {
              if (_isEditing) {
                final updatedContent = _contentController.text.trim();

                if (updatedContent == _currentItem.content) {
                  setState(() {
                    _isEditing = false;
                  });
                  showSnackBar(context, 'No changes made');
                  return;
                }

                final updatedType = _parseContentType(_contentController.text);
                final updatedItem = _currentItem.copyWith(
                  content: updatedContent,
                  type: updatedType,
                );
                ref.read(stashRepoProvider).updateStashItem(updatedItem);
                setState(() {
                  _currentItem = updatedItem;
                });
                showSnackBar(context, 'Item updated');
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
                  title: const Text('Move to Trash?'),
                  content: const Text(
                    'This item will be moved to trash.\nYou can restore it within 7 days.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Move to Trash'),
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        HapticFeedback.mediumImpact();
                        await ref
                            .read(stashRepoProvider)
                            .moveToTrash(widget.stashItem.id!);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        showSnackBar(context, 'Moved to trash');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _contentController,
                      autofocus: true,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: _contentTextStyle, // Use consistent style
                    )
                  : SingleChildScrollView(
                      child: Linkify(
                        onOpen: (link) async {
                          final messenger = ScaffoldMessenger.of(context);
                          final uri = Uri.parse(link.url);
                          if (!await launchUrl(uri)) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Could not open ${link.url}'),
                              ),
                            );
                          }
                        },
                        text: _currentItem.content,
                        style: _contentTextStyle, // Use consistent style
                        options: const LinkifyOptions(looseUrl: true),
                        linkStyle: _contentTextStyle.copyWith(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () async {
                final List<String>? updatedTags =
                    await showDialog<List<String>>(
                      context: context,
                      builder: (context) => AssignTagsDialog(
                        initialSelectedTags: _currentItem.tags,
                      ),
                    );
                if (updatedTags != null) {
                  final updatedItem = _currentItem.copyWith(tags: updatedTags);
                  ref.read(stashRepoProvider).updateStashItem(updatedItem);
                  setState(() {
                    _currentItem = updatedItem;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 20,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _currentItem.tags.isEmpty
                          ? Text(
                              'Add tags',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _currentItem.tags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(tag),
                                      labelStyle: const TextStyle(fontSize: 12),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
