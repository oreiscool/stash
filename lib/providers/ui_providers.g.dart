// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentPage)
const currentPageProvider = CurrentPageProvider._();

final class CurrentPageProvider extends $NotifierProvider<CurrentPage, String> {
  const CurrentPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPageHash();

  @$internal
  @override
  CurrentPage create() => CurrentPage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentPageHash() => r'635b4bc176ddbcc588276f84f2f90d5eca81168d';

abstract class _$CurrentPage extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedTags)
const selectedTagsProvider = SelectedTagsProvider._();

final class SelectedTagsProvider
    extends $NotifierProvider<SelectedTags, Set<String>> {
  const SelectedTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTagsHash();

  @$internal
  @override
  SelectedTags create() => SelectedTags();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$selectedTagsHash() => r'99e7acae2c792ca4c703ca927049a7fc6bb3b2b3';

abstract class _$SelectedTags extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
