// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot_add_flow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the add-link flow: extract → (season) → (duplicate) → confirm →
/// commit. State is null when no flow is active. The sheet
/// (`AddFlowSheet`) is a thin consumer of this notifier.
///
/// keepAlive because the flow is started via `ref.read` before the sheet
/// mounts — with autoDispose the provider would be disposed in that
/// listener gap. Lifecycle is managed manually: `showAddFlowSheet` calls
/// `cancel()` when the sheet closes.

@ProviderFor(JellybotAddFlow)
final jellybotAddFlowProvider = JellybotAddFlowProvider._();

/// Drives the add-link flow: extract → (season) → (duplicate) → confirm →
/// commit. State is null when no flow is active. The sheet
/// (`AddFlowSheet`) is a thin consumer of this notifier.
///
/// keepAlive because the flow is started via `ref.read` before the sheet
/// mounts — with autoDispose the provider would be disposed in that
/// listener gap. Lifecycle is managed manually: `showAddFlowSheet` calls
/// `cancel()` when the sheet closes.
final class JellybotAddFlowProvider
    extends $NotifierProvider<JellybotAddFlow, JellybotAddFlowState?> {
  /// Drives the add-link flow: extract → (season) → (duplicate) → confirm →
  /// commit. State is null when no flow is active. The sheet
  /// (`AddFlowSheet`) is a thin consumer of this notifier.
  ///
  /// keepAlive because the flow is started via `ref.read` before the sheet
  /// mounts — with autoDispose the provider would be disposed in that
  /// listener gap. Lifecycle is managed manually: `showAddFlowSheet` calls
  /// `cancel()` when the sheet closes.
  JellybotAddFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotAddFlowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotAddFlowHash();

  @$internal
  @override
  JellybotAddFlow create() => JellybotAddFlow();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JellybotAddFlowState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JellybotAddFlowState?>(value),
    );
  }
}

String _$jellybotAddFlowHash() => r'981589c244ed570eb96aeea3eb2737c6a62e1938';

/// Drives the add-link flow: extract → (season) → (duplicate) → confirm →
/// commit. State is null when no flow is active. The sheet
/// (`AddFlowSheet`) is a thin consumer of this notifier.
///
/// keepAlive because the flow is started via `ref.read` before the sheet
/// mounts — with autoDispose the provider would be disposed in that
/// listener gap. Lifecycle is managed manually: `showAddFlowSheet` calls
/// `cancel()` when the sheet closes.

abstract class _$JellybotAddFlow extends $Notifier<JellybotAddFlowState?> {
  JellybotAddFlowState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<JellybotAddFlowState?, JellybotAddFlowState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<JellybotAddFlowState?, JellybotAddFlowState?>,
              JellybotAddFlowState?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
