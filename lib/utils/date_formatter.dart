import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

// Add this to the top of date_formatter.dart if you want custom messages

class ShortMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'Just now';
  @override
  String aboutAMinute(int minutes) => '1m ago';
  @override
  String minutes(int minutes) => '${minutes}m ago';
  @override
  String aboutAnHour(int minutes) => '1h ago';
  @override
  String hours(int hours) => '${hours}h ago';
  @override
  String aDay(int hours) => '1d ago';
  @override
  String days(int days) => '${days}d ago';
  @override
  String aboutAMonth(int days) => '1mo ago';
  @override
  String months(int months) => '${months}mo ago';
  @override
  String aboutAYear(int year) => '1y ago';
  @override
  String years(int years) => '${years}y ago';
  @override
  String wordSeparator() => ' ';
}

String formatRelativeTime(DateTime dateTime) {
  timeago.setLocaleMessages('en_short', ShortMessages());
  return timeago.format(dateTime, locale: 'en_short');
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
  relative('Relative'), // "2h ago"
  absolute('Absolute'), // "Jan 15"
  full('Full Date'), // "January 15, 2025"
  datetime('Date & Time'); // "Jan 15, 2:30 PM"

  final String label;
  const DateFormatStyle(this.label);
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

// Format timestamp based on user preference
String formatTimestampByPreference(DateTime dateTime, DateFormatStyle style) {
  return formatDate(dateTime, style);
}
