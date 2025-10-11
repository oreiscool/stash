import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_providers.g.dart';

@riverpod
class CurrentPage extends _$CurrentPage {
  @override
  String build() {
    return 'home';
  }

  void setPage(String page) {
    state = page;
  }
}
