import 'package:intl/intl.dart';

String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '${minutes}m ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '${hours}h ago';
  } else if (difference.inDays < 7) {
    final days = difference.inDays;
    return '${days}d ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '${months}mo ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '${years}y ago';
  }
}

// Using intl for absolute dates
String formatAbsoluteDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays < 7) {
    return formatRelativeTime(dateTime);
  } else if (difference.inDays < 365) {
    // "Jan 15" for this year
    return DateFormat('MMM d').format(dateTime);
  } else {
    // "Jan 15, 2024" for older items
    return DateFormat('MMM d, y').format(dateTime);
  }
}

// For settings later: different format options
enum DateFormatStyle {
  relative, // "2h ago"
  absolute, // "Jan 15"
  full, // "January 15, 2025"
  datetime, // "Jan 15, 2:30 PM"
}

String formatDate(DateTime dateTime, DateFormatStyle style) {
  switch (style) {
    case DateFormatStyle.relative:
      return formatRelativeTime(dateTime);
    case DateFormatStyle.absolute:
      return formatAbsoluteDate(dateTime);
    case DateFormatStyle.full:
      return DateFormat('MMMM d, y').format(dateTime);
    case DateFormatStyle.datetime:
      return DateFormat('MMM d, h:mm a').format(dateTime);
  }
}

String formatItemTimestamp(DateTime createdAt, DateTime? updatedAt) {
  if (updatedAt != null &&
      updatedAt.difference(createdAt).inSeconds.abs() > 1) {
    return 'Updated ${formatRelativeTime(updatedAt)}';
  } else {
    return formatRelativeTime(createdAt);
  }
}
