import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash/utils/date_formatter.dart';

part 'timestamp_providers.g.dart';

@riverpod
class TimestampPreference extends _$TimestampPreference {
  static const String _timeStampKey = 'timestamp_format';

  @override
  Future<DateFormatStyle> build() async {
    final prefs = await SharedPreferences.getInstance();
    final formatString = prefs.getString(_timeStampKey) ?? 'relative';

    return DateFormatStyle.values.firstWhere(
      (style) => style.name == formatString,
      orElse: () => DateFormatStyle.relative,
    );
  }

  Future<void> setTimestampFormat(DateFormatStyle format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeStampKey, format.name);
    state = AsyncValue.data(format);
  }
}
