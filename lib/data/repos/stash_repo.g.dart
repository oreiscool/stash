// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stash_repo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stashStream)
const stashStreamProvider = StashStreamProvider._();

final class StashStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StashItem>>,
          List<StashItem>,
          Stream<List<StashItem>>
        >
    with $FutureModifier<List<StashItem>>, $StreamProvider<List<StashItem>> {
  const StashStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stashStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stashStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<StashItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StashItem>> create(Ref ref) {
    return stashStream(ref);
  }
}

String _$stashStreamHash() => r'518c7e91ab2500bacae36b1e1c22b79f56fab502';

@ProviderFor(stashService)
const stashServiceProvider = StashServiceProvider._();

final class StashServiceProvider
    extends $FunctionalProvider<StashService, StashService, StashService>
    with $Provider<StashService> {
  const StashServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stashServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stashServiceHash();

  @$internal
  @override
  $ProviderElement<StashService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StashService create(Ref ref) {
    return stashService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StashService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StashService>(value),
    );
  }
}

String _$stashServiceHash() => r'd9bcbc79fcdf1a3ca53bd614c972b1713ef7d94b';

@ProviderFor(stashRepo)
const stashRepoProvider = StashRepoProvider._();

final class StashRepoProvider
    extends $FunctionalProvider<StashRepo, StashRepo, StashRepo>
    with $Provider<StashRepo> {
  const StashRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stashRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stashRepoHash();

  @$internal
  @override
  $ProviderElement<StashRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StashRepo create(Ref ref) {
    return stashRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StashRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StashRepo>(value),
    );
  }
}

String _$stashRepoHash() => r'c0c913f12dade8170031cdf7ec83d436b7186d3d';
