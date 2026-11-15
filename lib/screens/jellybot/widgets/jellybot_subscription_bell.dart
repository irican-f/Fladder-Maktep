import 'package:material_ui/material_ui.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/providers/jellybot_notifications_provider.dart';
import 'package:fladder/screens/shared/fladder_notification_overlay.dart';
import 'package:fladder/util/jellybot_ready_notifications.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/widgets/shared/selectable_icon_button.dart';

/// Follows or unfollows [seriesId] on JellyBot and tells the user how it went.
Future<void> toggleJellybotSubscription(BuildContext context, WidgetRef ref, String seriesId) async {
  final subscribed = await ref.read(jellybotSeriesSubscriptionProvider(jellybotSeriesKey(seriesId)).notifier).toggle();
  if (!context.mounted) {
    return;
  }
  FladderSnack.show(switch (subscribed) {
    true => context.localized.jellybotShowFollowed,
    false => context.localized.jellybotShowUnfollowed,
    null => context.localized.somethingWentWrong,
  }, context: context);
}

/// Bell that follows a series' new episodes. Renders nothing unless JellyBot tracks the series.
class JellybotSubscriptionBell extends ConsumerWidget {
  const JellybotSubscriptionBell({required this.seriesId, super.key});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(jellybotSeriesSubscriptionProvider(jellybotSeriesKey(seriesId))).value;
    if (status?.tracked != true) {
      return const SizedBox.shrink();
    }
    final subscribed = status!.subscribed ?? false;
    return Tooltip(
      message: subscribed ? context.localized.jellybotUnfollowShow : context.localized.jellybotFollowShow,
      child: SelectableIconButton(
        onPressed: () => toggleJellybotSubscription(context, ref, seriesId),
        selected: subscribed,
        refreshOnEnd: false,
        selectedIcon: IconsaxPlusBold.notification,
        icon: IconsaxPlusLinear.notification,
      ),
    );
  }
}
