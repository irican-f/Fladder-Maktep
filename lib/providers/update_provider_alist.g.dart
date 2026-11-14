// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_provider_alist.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpdateAlist)
final updateAlistProvider = UpdateAlistProvider._();

final class UpdateAlistProvider
    extends $NotifierProvider<UpdateAlist, UpdatesModelAlist> {
  UpdateAlistProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateAlistProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateAlistHash();

  @$internal
  @override
  UpdateAlist create() => UpdateAlist();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdatesModelAlist value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdatesModelAlist>(value),
    );
  }
}

String _$updateAlistHash() => r'5d9f49b913eb5c3d00e41a9223a76c82c44c5f52';

abstract class _$UpdateAlist extends $Notifier<UpdatesModelAlist> {
  UpdatesModelAlist build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UpdatesModelAlist, UpdatesModelAlist>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdatesModelAlist, UpdatesModelAlist>,
              UpdatesModelAlist,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
