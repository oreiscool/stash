import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sort_providers.g.dart';

enum SortMode {
  recent('Recent'),
  oldest('Oldest');

  final String label;
  const SortMode(this.label);
}

@riverpod
class SortPreference extends _$SortPreference {
  static const String _sortKey = 'sort_mode';

  @override
  Future<SortMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final sortString = prefs.getString(_sortKey) ?? 'recent';

    return SortMode.values.firstWhere(
      (mode) => mode.name == sortString,
      orElse: () => SortMode.recent,
    );
  }

  Future<void> setSortMode(SortMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortKey, mode.name);
    state = AsyncValue.data(mode);
  }
}
