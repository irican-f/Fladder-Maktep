import 'package:material_ui/material_ui.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/providers/jellybot_notifications_provider.dart';
import 'package:fladder/providers/update_notifications_provider.dart';
import 'package:fladder/screens/settings/settings_list_tile.dart';
import 'package:fladder/screens/settings/widgets/settings_label_divider.dart';
import 'package:fladder/screens/settings/widgets/settings_list_group.dart';
import 'package:fladder/screens/shared/fladder_notification_overlay.dart';
import 'package:fladder/services/notification_service.dart';
import 'package:fladder/util/localization_helper.dart';

/// JellyBot "ready to watch" preferences. They live on JellyBot so they follow the user across devices; hidden when
/// JellyBot is not set up or doesn't know this account. Shown on web too: the in-app list and tab dot work there.
class JellybotNotificationSettings extends ConsumerWidget {
  const JellybotNotificationSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(jellybotNotificationPreferencesProvider).value;
    if (prefs == null) {
      return const SizedBox.shrink();
    }
    final enabled = prefs.enabled ?? true;
    final onlyMine = prefs.onlyMine ?? true;

    Future<void> save({required bool enabled, required bool onlyMine}) async {
      final saved = await ref
          .read(jellybotNotificationPreferencesProvider.notifier)
          .save(enabled: enabled, onlyMine: onlyMine);
      if (!saved && context.mounted) {
        FladderSnack.show(context.localized.somethingWentWrong, context: context);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        ...settingsListGroup(context, SettingsLabelDivider(label: context.localized.jellybot), [
          SettingsListTileCheckbox(
            label: Text(context.localized.jellybotReadyNotifications),
            subLabel: Text(context.localized.jellybotReadyNotificationsDesc),
            value: enabled,
            onChanged: (val) async {
              if (val == null) {
                return;
              }
              if (val && ref.read(supportsNotificationsProvider)) {
                await NotificationService.requestPermission();
              }
              await save(enabled: val, onlyMine: onlyMine);
            },
          ),
          SettingsListTileCheckbox(
            label: Text(context.localized.jellybotOnlyMine),
            subLabel: Text(context.localized.jellybotOnlyMineDesc),
            value: onlyMine,
            onChanged: enabled
                ? (val) async {
                    if (val == null) {
                      return;
                    }
                    await save(enabled: enabled, onlyMine: val);
                  }
                : null,
          ),
        ]),
      ],
    );
  }
}
