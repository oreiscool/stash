import 'package:flutter/material.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/widgets/highlighted_text.dart';
import 'package:stash/pages/stash_detail_page.dart';
import 'package:stash/utils/date_formatter.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.stashItem,
    required this.query,
  });

  final StashItem stashItem;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StashDetailPage(stashItem: stashItem),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: HighlightedText(
                text: stashItem.content,
                query: query,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  HighlightedText(
                    text: 'Type: ${stashItem.type}',
                    query: query,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('•', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(width: 8),
                  Text(
                    formatRelativeTime(stashItem.createdAt.toDate()),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (stashItem.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: stashItem.tags.map((tag) {
                    final isMatchingTag = tag.toLowerCase().contains(
                      query.toLowerCase().trim(),
                    );
                    return Chip(
                      label: isMatchingTag
                          ? HighlightedText(
                              text: tag,
                              query: query,
                              style: const TextStyle(fontSize: 12),
                            )
                          : Text(tag, style: const TextStyle(fontSize: 12)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      backgroundColor: isMatchingTag
                          ? Colors.yellow.shade100
                          : Colors.grey.shade200,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
