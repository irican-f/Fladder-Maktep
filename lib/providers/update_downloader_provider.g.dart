// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_downloader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(alistDownloadClient)
final alistDownloadClientProvider = AlistDownloadClientProvider._();

final class AlistDownloadClientProvider
    extends
        $FunctionalProvider<
          AlistDownloadClient,
          AlistDownloadClient,
          AlistDownloadClient
        >
    with $Provider<AlistDownloadClient> {
  AlistDownloadClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alistDownloadClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alistDownloadClientHash();

  @$internal
  @override
  $ProviderElement<AlistDownloadClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AlistDownloadClient create(Ref ref) {
    return alistDownloadClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlistDownloadClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlistDownloadClient>(value),
    );
  }
}

String _$alistDownloadClientHash() =>
    r'd6afdeedda62f4f1f03a0f893ef79935482fc0d3';

@ProviderFor(alistInstaller)
final alistInstallerProvider = AlistInstallerProvider._();

final class AlistInstallerProvider
    extends $FunctionalProvider<AlistInstaller, AlistInstaller, AlistInstaller>
    with $Provider<AlistInstaller> {
  AlistInstallerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alistInstallerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alistInstallerHash();

  @$internal
  @override
  $ProviderElement<AlistInstaller> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AlistInstaller create(Ref ref) {
    return alistInstaller(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlistInstaller value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlistInstaller>(value),
    );
  }
}

String _$alistInstallerHash() => r'b091ed793c497578ba241a64617fd54f7e472202';

@ProviderFor(UpdateDownloader)
final updateDownloaderProvider = UpdateDownloaderProvider._();

final class UpdateDownloaderProvider
    extends $NotifierProvider<UpdateDownloader, UpdateDownloadState> {
  UpdateDownloaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDownloaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDownloaderHash();

  @$internal
  @override
  UpdateDownloader create() => UpdateDownloader();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateDownloadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateDownloadState>(value),
    );
  }
}

String _$updateDownloaderHash() => r'87e80af804b08398756f7ed285c8f1b4b998d815';

abstract class _$UpdateDownloader extends $Notifier<UpdateDownloadState> {
  UpdateDownloadState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UpdateDownloadState, UpdateDownloadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdateDownloadState, UpdateDownloadState>,
              UpdateDownloadState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
