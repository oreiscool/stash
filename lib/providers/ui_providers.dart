import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash/providers/selection_providers.dart';

part 'ui_providers.g.dart';

@riverpod
class CurrentPage extends _$CurrentPage {
  @override
  String build() {
    return 'home';
  }

  void setPage(String page) {
    // Exit selection mode when changing pages
    ref.read(selectionModeProvider.notifier).exitSelectionMode();
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

@riverpod
Stream<DateTime> clockStream(Ref ref) {
  return Stream.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now(),
  ).asBroadcastStream();
}
