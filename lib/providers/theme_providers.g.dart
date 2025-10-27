// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeSettingsNotifier)
const themeSettingsProvider = ThemeSettingsNotifierProvider._();

final class ThemeSettingsNotifierProvider
    extends $AsyncNotifierProvider<ThemeSettingsNotifier, ThemeSettings> {
  const ThemeSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeSettingsNotifierHash();

  @$internal
  @override
  ThemeSettingsNotifier create() => ThemeSettingsNotifier();
}

String _$themeSettingsNotifierHash() =>
    r'c2b9ddae6e18e91a1367d94d88e6024ff842c96d';

abstract class _$ThemeSettingsNotifier extends $AsyncNotifier<ThemeSettings> {
  FutureOr<ThemeSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ThemeSettings>, ThemeSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeSettings>, ThemeSettings>,
              AsyncValue<ThemeSettings>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
