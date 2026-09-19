// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellyfin_websocket_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jellyfinWebSocketControllerHash() => r'd78eb59948bb7cb509b3e0c88386d87119f66076';

/// Owns a single [JellyfinWebSocket], connects when a user is authenticated, and re-broadcasts its
/// streams through long-lived controllers so consumers survive account switches / socket rebuilds.
///
/// Copied from [JellyfinWebSocketController].
@ProviderFor(JellyfinWebSocketController)
final jellyfinWebSocketControllerProvider =
    NotifierProvider<JellyfinWebSocketController, WebSocketConnectionState>.internal(
  JellyfinWebSocketController.new,
  name: r'jellyfinWebSocketControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$jellyfinWebSocketControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JellyfinWebSocketController = Notifier<WebSocketConnectionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
