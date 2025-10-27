// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectionMode)
const selectionModeProvider = SelectionModeProvider._();

final class SelectionModeProvider
    extends $NotifierProvider<SelectionMode, SelectionState> {
  const SelectionModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectionModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectionModeHash();

  @$internal
  @override
  SelectionMode create() => SelectionMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectionState>(value),
    );
  }
}

String _$selectionModeHash() => r'7dd9c6d896714029549ab07f758fb0e42b1113bb';

abstract class _$SelectionMode extends $Notifier<SelectionState> {
  SelectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SelectionState, SelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SelectionState, SelectionState>,
              SelectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
