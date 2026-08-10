// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot_add_flow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jellybotAddFlowHash() => r'be47a2e369677a9ffac962789b6281d6bce43958';

/// Drives the add-link flow: extract → (season) → (duplicate) → confirm →
/// commit. State is null when no flow is active. The sheet
/// (`AddFlowSheet`) is a thin consumer of this notifier.
///
/// keepAlive because the flow is started via `ref.read` before the sheet
/// mounts — with autoDispose the provider would be disposed in that
/// listener gap. Lifecycle is managed manually: `showAddFlowSheet` calls
/// `cancel()` when the sheet closes.
///
/// Copied from [JellybotAddFlow].
@ProviderFor(JellybotAddFlow)
final jellybotAddFlowProvider = NotifierProvider<JellybotAddFlow, JellybotAddFlowState?>.internal(
  JellybotAddFlow.new,
  name: r'jellybotAddFlowProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$jellybotAddFlowHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JellybotAddFlow = Notifier<JellybotAddFlowState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
