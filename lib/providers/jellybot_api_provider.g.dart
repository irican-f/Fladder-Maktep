// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot_api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JellybotApi)
final jellybotApiProvider = JellybotApiProvider._();

final class JellybotApiProvider
    extends $NotifierProvider<JellybotApi, Jellybot> {
  JellybotApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jellybotApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jellybotApiHash();

  @$internal
  @override
  JellybotApi create() => JellybotApi();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Jellybot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Jellybot>(value),
    );
  }
}

String _$jellybotApiHash() => r'81f85a749ee957ab45a4d8bacff5c8512f85a2c7';

abstract class _$JellybotApi extends $Notifier<Jellybot> {
  Jellybot build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Jellybot, Jellybot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Jellybot, Jellybot>,
              Jellybot,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
