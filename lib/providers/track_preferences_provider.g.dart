// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trackPreferencesHash() => r'3582515b5a4ef436fd02d3f461ebeb4d66db3ba8';

/// See also [trackPreferences].
@ProviderFor(trackPreferences)
final trackPreferencesProvider = AutoDisposeProvider<TrackPreferences>.internal(
  trackPreferences,
  name: r'trackPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$trackPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrackPreferencesRef = AutoDisposeProviderRef<TrackPreferences>;
String _$manualSubtitleOverrideHash() => r'debf1ea8b80b2e8377d9b903d0c540d4ac62a527';

/// True once the user manually picked a subtitle track for the currently
/// playing item; smart re-evaluation must not override a manual choice.
/// Reset when a different item starts playing.
///
/// Copied from [ManualSubtitleOverride].
@ProviderFor(ManualSubtitleOverride)
final manualSubtitleOverrideProvider = NotifierProvider<ManualSubtitleOverride, bool>.internal(
  ManualSubtitleOverride.new,
  name: r'manualSubtitleOverrideProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$manualSubtitleOverrideHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ManualSubtitleOverride = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
