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

String _$stashStreamHash() => r'4e6770051e3e8ceadb2c3a0e95de35d693ab26c9';

@ProviderFor(trashStream)
const trashStreamProvider = TrashStreamProvider._();

final class TrashStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StashItem>>,
          List<StashItem>,
          Stream<List<StashItem>>
        >
    with $FutureModifier<List<StashItem>>, $StreamProvider<List<StashItem>> {
  const TrashStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trashStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trashStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<StashItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StashItem>> create(Ref ref) {
    return trashStream(ref);
  }
}

String _$trashStreamHash() => r'8b5766c7d9884972450f3f328e4fee23609000bd';

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

@ProviderFor(stashSearch)
const stashSearchProvider = StashSearchFamily._();

final class StashSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StashItem>>,
          List<StashItem>,
          Stream<List<StashItem>>
        >
    with $FutureModifier<List<StashItem>>, $StreamProvider<List<StashItem>> {
  const StashSearchProvider._({
    required StashSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stashSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stashSearchHash();

  @override
  String toString() {
    return r'stashSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<StashItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StashItem>> create(Ref ref) {
    final argument = this.argument as String;
    return stashSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StashSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stashSearchHash() => r'69aad3f46f552975ca99c45e5f10120ffe2cd795';

final class StashSearchFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<StashItem>>, String> {
  const StashSearchFamily._()
    : super(
        retry: null,
        name: r'stashSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StashSearchProvider call(String query) =>
      StashSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'stashSearchProvider';
}
