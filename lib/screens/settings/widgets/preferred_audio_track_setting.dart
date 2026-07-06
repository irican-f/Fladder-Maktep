import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/providers/cultures_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/screens/settings/settings_list_tile.dart';
import 'package:fladder/util/jellyfin_extension.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/widgets/shared/item_actions.dart';

/// Maktep-only: "Preferred audio track" selector (Any / Original version / language).
/// A concrete language is stored server-side (userConfiguration.audioLanguagePreference);
/// "Original version" lives in Fladder's server-synced custom config.
class PreferredAudioTrackSetting extends ConsumerWidget {
  const PreferredAudioTrackSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final cultures = ref.watch(culturesProvider);

    final preferOriginal = user?.userSettings?.preferOriginalAudio ?? false;
    final audioLanguagePreference = user?.userConfiguration?.audioLanguagePreference?.trim().toLowerCase();
    final hasLanguagePreference = !preferOriginal && (audioLanguagePreference?.isNotEmpty == true);

    final currentCulture = cultures.firstWhereOrNull(
      (e) => e.matchesLanguageCode(audioLanguagePreference),
    );

    final currentLabel = preferOriginal
        ? context.localized.originalVersionAudio
        : hasLanguagePreference
            ? currentCulture?.displayName ?? context.localized.unknown
            : context.localized.anyLanguage;

    return SettingsListTileEnum(
      label: Text(context.localized.preferredAudioLanguage),
      subLabel: preferOriginal ? Text(context.localized.originalVersionAudioDesc) : null,
      current: currentLabel,
      itemBuilder: (context) => [
        ItemActionButton(
          selected: !preferOriginal && !hasLanguagePreference,
          label: Text(context.localized.anyLanguage),
          action: () {
            ref.read(userProvider.notifier).setPreferOriginalAudio(false);
            ref.read(userProvider.notifier).updateAudioLanguagePreference(null);
          },
        ),
        ItemActionButton(
          selected: preferOriginal,
          label: Text(context.localized.originalVersionAudio),
          action: () {
            ref.read(userProvider.notifier).updateAudioLanguagePreference(null);
            ref.read(userProvider.notifier).setPreferOriginalAudio(true);
          },
        ),
        ...cultures.map(
          (e) => ItemActionButton(
            selected: !preferOriginal && e.matchesLanguageCode(audioLanguagePreference),
            label: Text(e.displayName ?? e.name ?? context.localized.unknown),
            action: () {
              ref.read(userProvider.notifier).setPreferOriginalAudio(false);
              ref.read(userProvider.notifier).updateAudioLanguagePreference(
                  e.threeLetterISOLanguageName?.toLowerCase() ?? e.twoLetterISOLanguageName?.toLowerCase());
            },
          ),
        ),
      ],
    );
  }
}
