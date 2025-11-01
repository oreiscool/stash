// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timestamp_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimestampPreference)
const timestampPreferenceProvider = TimestampPreferenceProvider._();

final class TimestampPreferenceProvider
    extends $AsyncNotifierProvider<TimestampPreference, DateFormatStyle> {
  const TimestampPreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timestampPreferenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timestampPreferenceHash();

  @$internal
  @override
  TimestampPreference create() => TimestampPreference();
}

String _$timestampPreferenceHash() =>
    r'264ba18509499749e4fc4ab30c4054203da7547f';

abstract class _$TimestampPreference extends $AsyncNotifier<DateFormatStyle> {
  FutureOr<DateFormatStyle> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<DateFormatStyle>, DateFormatStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DateFormatStyle>, DateFormatStyle>,
              AsyncValue<DateFormatStyle>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
