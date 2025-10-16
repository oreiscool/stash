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

@riverpod
class SelectedTags extends _$SelectedTags {
  @override
  Set<String> build() {
    return {};
  }

  void toggleTag(String tagName) {
    if (state.contains(tagName)) {
      state = {...state}..remove(tagName);
    } else {
      state = {...state, tagName};
    }
  }

  void clearTags() {
    state = {};
  }
}
