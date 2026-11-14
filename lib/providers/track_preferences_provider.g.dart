// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trackPreferences)
final trackPreferencesProvider = TrackPreferencesProvider._();

final class TrackPreferencesProvider
    extends
        $FunctionalProvider<
          TrackPreferences,
          TrackPreferences,
          TrackPreferences
        >
    with $Provider<TrackPreferences> {
  TrackPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackPreferencesHash();

  @$internal
  @override
  $ProviderElement<TrackPreferences> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrackPreferences create(Ref ref) {
    return trackPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackPreferences>(value),
    );
  }
}

String _$trackPreferencesHash() => r'3582515b5a4ef436fd02d3f461ebeb4d66db3ba8';

/// True once the user manually picked a subtitle track for the currently
/// playing item; smart re-evaluation must not override a manual choice.
/// Reset when a different item starts playing.

@ProviderFor(ManualSubtitleOverride)
final manualSubtitleOverrideProvider = ManualSubtitleOverrideProvider._();

/// True once the user manually picked a subtitle track for the currently
/// playing item; smart re-evaluation must not override a manual choice.
/// Reset when a different item starts playing.
final class ManualSubtitleOverrideProvider
    extends $NotifierProvider<ManualSubtitleOverride, bool> {
  /// True once the user manually picked a subtitle track for the currently
  /// playing item; smart re-evaluation must not override a manual choice.
  /// Reset when a different item starts playing.
  ManualSubtitleOverrideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manualSubtitleOverrideProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manualSubtitleOverrideHash();

  @$internal
  @override
  ManualSubtitleOverride create() => ManualSubtitleOverride();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$manualSubtitleOverrideHash() =>
    r'debf1ea8b80b2e8377d9b903d0c540d4ac62a527';

/// True once the user manually picked a subtitle track for the currently
/// playing item; smart re-evaluation must not override a manual choice.
/// Reset when a different item starts playing.

abstract class _$ManualSubtitleOverride extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
