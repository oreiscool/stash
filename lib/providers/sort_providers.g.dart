// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SortPreference)
const sortPreferenceProvider = SortPreferenceProvider._();

final class SortPreferenceProvider
    extends $AsyncNotifierProvider<SortPreference, SortMode> {
  const SortPreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortPreferenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortPreferenceHash();

  @$internal
  @override
  SortPreference create() => SortPreference();
}

String _$sortPreferenceHash() => r'47a10be75dadb1af3d26d534e4c30f36c33948f5';

abstract class _$SortPreference extends $AsyncNotifier<SortMode> {
  FutureOr<SortMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SortMode>, SortMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SortMode>, SortMode>,
              AsyncValue<SortMode>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
