import 'package:flutter/material.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/pages/stash_detail_page.dart';

class StashItemCard extends StatelessWidget {
  const StashItemCard({super.key, required this.stashItem});
  final StashItem stashItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StashDetailPage(stashItem: stashItem),
          ),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                stashItem.content,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Type: ${stashItem.type}'),
            ),
            if (stashItem.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: stashItem.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      backgroundColor: Colors.grey.shade200,
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
