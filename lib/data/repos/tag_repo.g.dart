// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_repo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tagRepo)
const tagRepoProvider = TagRepoProvider._();

final class TagRepoProvider
    extends $FunctionalProvider<TagRepo, TagRepo, TagRepo>
    with $Provider<TagRepo> {
  const TagRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagRepoHash();

  @$internal
  @override
  $ProviderElement<TagRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagRepo create(Ref ref) {
    return tagRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagRepo>(value),
    );
  }
}

String _$tagRepoHash() => r'e58fb3e8b05c4a1f4333b634504ff6fca904a851';

@ProviderFor(tagStream)
const tagStreamProvider = TagStreamProvider._();

final class TagStreamProvider
    extends
        $FunctionalProvider<AsyncValue<List<Tag>>, List<Tag>, Stream<List<Tag>>>
    with $FutureModifier<List<Tag>>, $StreamProvider<List<Tag>> {
  const TagStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Tag>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Tag>> create(Ref ref) {
    return tagStream(ref);
  }
}

String _$tagStreamHash() => r'6cfd210bb10fed1faacc1362fedc3c7b882dc45c';
