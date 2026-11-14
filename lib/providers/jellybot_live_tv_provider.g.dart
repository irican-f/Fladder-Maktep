// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot_live_tv_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching and caching Live TV channels from Jellybot API.
/// Returns empty list if API fails - this will hide Live TV from navigation.

@ProviderFor(JellybotLiveTvChannels)
final jellybotLiveTvChannelsProvider = JellybotLiveTvChannelsProvider._();

/// Provider for fetching and caching Live TV channels from Jellybot API.
/// Returns empty list if API fails - this will hide Live TV from navigation.
final class JellybotLiveTvChannelsProvider
    extends
        $AsyncNotifierProvider<JellybotLiveTvChannels, List<LiveTvChannelDto>> {
  /// Provider for fetching and caching Live TV channels from Jellybot API.
  /// Returns empty list if API fails - this will hide Live TV from navigation.
  JellybotLiveTvChannelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotLiveTvChannelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotLiveTvChannelsHash();

  @$internal
  @override
  JellybotLiveTvChannels create() => JellybotLiveTvChannels();
}

String _$jellybotLiveTvChannelsHash() =>
    r'7b2b089eab5a40d5f65f7b121f21b3ea8a5dd146';

/// Provider for fetching and caching Live TV channels from Jellybot API.
/// Returns empty list if API fails - this will hide Live TV from navigation.

abstract class _$JellybotLiveTvChannels
    extends $AsyncNotifier<List<LiveTvChannelDto>> {
  FutureOr<List<LiveTvChannelDto>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<LiveTvChannelDto>>, List<LiveTvChannelDto>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<LiveTvChannelDto>>,
                List<LiveTvChannelDto>
              >,
              AsyncValue<List<LiveTvChannelDto>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider to check if Live TV channels are available.
/// Used to conditionally show/hide Live TV in navigation.

@ProviderFor(hasJellybotLiveTvChannels)
final hasJellybotLiveTvChannelsProvider = HasJellybotLiveTvChannelsProvider._();

/// Provider to check if Live TV channels are available.
/// Used to conditionally show/hide Live TV in navigation.

final class HasJellybotLiveTvChannelsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if Live TV channels are available.
  /// Used to conditionally show/hide Live TV in navigation.
  HasJellybotLiveTvChannelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasJellybotLiveTvChannelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasJellybotLiveTvChannelsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasJellybotLiveTvChannels(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasJellybotLiveTvChannelsHash() =>
    r'1ee36b7e4161b9e1bf58a33bdaaeaa9c424b50bc';
