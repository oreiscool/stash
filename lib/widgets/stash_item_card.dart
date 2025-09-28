import 'package:flutter/material.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/pages/stash_detail_page.dart';

class StashItemCard extends StatelessWidget {
  const StashItemCard({super.key, required this.stashItem});
  final StashItem stashItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StashDetailPage(stashItem: stashItem),
          ),
        ),
        child: ListTile(
          title: Text(
            stashItem.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('Type: ${stashItem.type}'),
          // TODO: We will add clickable links and tag chips here later.
        ),
      ),
    );
  }
}
