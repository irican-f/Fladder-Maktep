import 'package:material_ui/material_ui.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/providers/jellybot_notifications_provider.dart';
import 'package:fladder/routes/auto_router.gr.dart';
import 'package:fladder/screens/shared/nested_scaffold.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/humanize_duration.dart';
import 'package:fladder/util/jellybot_ready_notifications.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/widgets/shared/fladder_scrollbar.dart';
import 'package:fladder/widgets/shared/pull_to_refresh.dart';

/// JellyBot "ready to watch" events, newest first. Opening it marks them read.
@RoutePage()
class JellybotNotificationsPage extends ConsumerStatefulWidget {
  const JellybotNotificationsPage({super.key});

  @override
  ConsumerState<JellybotNotificationsPage> createState() => _JellybotNotificationsPageState();
}

class _JellybotNotificationsPageState extends ConsumerState<JellybotNotificationsPage> {
  final _scrollController = ScrollController();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 400) {
        ref.read(jellybotNotificationHistoryProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(jellybotNotificationHistoryProvider);
    final single = AdaptiveLayout.layoutModeOf(context) == LayoutMode.single;

    return NestedScaffold(
      body: Padding(
        padding: EdgeInsets.only(left: AdaptiveLayout.of(context).sideBarWidth),
        child: Scaffold(
          backgroundColor: null,
          body: FladderScrollbar(
            controller: _scrollController,
            child: PullToRefresh(
              refreshKey: _refreshKey,
              // The provider loads on first watch; a start refresh would rebuild it and mark read twice.
              refreshOnStart: false,
              onRefresh: () async {
                ref.invalidate(jellybotNotificationHistoryProvider);
                await ref
                    .read(jellybotNotificationHistoryProvider.future)
                    .catchError((_) => const JellybotHistoryState(items: []));
              },
              child: (context) => CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: single,
                    pinned: !single,
                    automaticallyImplyLeading: false,
                    leading: single
                        ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.router.maybePop())
                        : null,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    title: Text(context.localized.notifications),
                  ),
                  ...switch (history) {
                    AsyncData(:final value) when value.items.isEmpty => [const _EmptyState()],
                    AsyncData(:final value) => [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList.builder(
                          itemCount: value.items.length,
                          itemBuilder: (context, index) => _NotificationRow(
                            event: value.items[index],
                            unread: isJellybotUnread(value.items[index], value.lastReadId),
                          ),
                        ),
                      ),
                      if (value.loadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                    AsyncError(:final error) => [
                      SliverFillRemaining(
                        child: _ErrorState(
                          message: error.toString(),
                          onRetry: () => ref.invalidate(jellybotNotificationHistoryProvider),
                        ),
                      ),
                    ],
                    _ => [const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
                  },
                  SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 80)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.event, required this.unread});

  final ReadyNotificationDto event;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final itemId = event.jellyfinItemId;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: unread ? colors.primaryContainer : null,
      child: ListTile(
        leading: Icon(
          event.kind == ReadyNotificationKind.movie ? IconsaxPlusLinear.video_play : IconsaxPlusLinear.video_vertical,
          color: unread ? colors.onPrimaryContainer : null,
        ),
        title: Text(
          event.title?.isNotEmpty == true ? event.title! : context.localized.unknown,
          style: TextStyle(fontWeight: unread ? FontWeight.bold : null),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(jellybotKindLine(event, context.localized)),
        trailing: Text(event.createdAt?.timeAgo(context) ?? '', style: Theme.of(context).textTheme.labelSmall),
        // Same target as the system notification's deep link.
        onTap: itemId == null || itemId.isEmpty
            ? null
            : () => context.router.push(DetailsRoute(id: itemId.replaceAll('-', ''))),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconsaxPlusLinear.notification, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(context.localized.jellybotNoNotifications, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(context.localized.jellybotNoNotificationsDesc, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(IconsaxPlusLinear.warning_2, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(context.localized.jellybotNotificationsFailed, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText.rich(
              TextSpan(
                text: message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.error),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(IconsaxPlusLinear.refresh),
              label: Text(context.localized.retry),
            ),
          ],
        ),
      ),
    );
  }
}
