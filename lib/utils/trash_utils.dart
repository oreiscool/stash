import 'package:stash/data/models/stash_item.dart';

int getDaysRemaining(StashItem item) {
  if (item.deletedAt == null) return 7;

  final deletedDate = item.deletedAt!.toDate();
  final daysRemaining = 7 - DateTime.now().difference(deletedDate).inDays;

  return daysRemaining > 0 ? daysRemaining : 0;
}

String getDaysRemainingText(StashItem item) {
  final days = getDaysRemaining(item);

  if (days == 0) return 'Expires today';
  if (days == 1) return '1 day left';
  return '$days days left';
}

bool isExpiringOn(StashItem item) {
  return getDaysRemaining(item) <= 2;
}
