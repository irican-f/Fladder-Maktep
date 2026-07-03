import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_add_flow_state.dart';
import 'package:fladder/providers/jellybot_add_flow_provider.dart';

void main() {
  test('initial state is null (no active flow)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(jellybotAddFlowProvider), isNull);
  });

  test('cancel resets state to null', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(jellybotAddFlowProvider.notifier);
    notifier.debugSetState(
      const JellybotAddFlowState(
        item: ProviderSearchItemDto(title: 'X', url: 'https://a/x'),
        category: MediaCategory.movie,
        step: AddFlowStep.confirming,
      ),
    );
    expect(container.read(jellybotAddFlowProvider), isNotNull);
    notifier.cancel();
    expect(container.read(jellybotAddFlowProvider), isNull);
  });

  test('confirm without an addToken is a no-op (no HTTP fired)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(jellybotAddFlowProvider.notifier);
    notifier.debugSetState(
      const JellybotAddFlowState(
        item: ProviderSearchItemDto(title: 'X', url: 'https://a/x'),
        category: MediaCategory.movie,
        step: AddFlowStep.confirming,
      ),
    );
    await notifier.confirm('X');
    // Without a token nothing must change — still confirming, no failure.
    final state = container.read(jellybotAddFlowProvider);
    expect(state?.step, AddFlowStep.confirming);
    expect(state?.failure, isNull);
  });

  test('flow state survives the listener gap between start() and the sheet mounting', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // showAddFlowSheet() seeds state via ref.read (no listener), and the sheet
    // only starts watching one frame later — the state must not be disposed
    // in between (the provider is keepAlive, reset manually via cancel()).
    container.read(jellybotAddFlowProvider.notifier).debugSetState(
          const JellybotAddFlowState(
            item: ProviderSearchItemDto(title: 'X', url: 'https://a/x'),
            category: MediaCategory.movie,
          ),
        );
    await container.pump();
    expect(container.read(jellybotAddFlowProvider), isNotNull);
  });

  test('continueAfterDuplicate moves duplicateCheck to confirming', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(jellybotAddFlowProvider.notifier);
    notifier.debugSetState(
      const JellybotAddFlowState(
        item: ProviderSearchItemDto(title: 'X', url: 'https://a/x'),
        category: MediaCategory.movie,
        step: AddFlowStep.duplicateCheck,
        addToken: 'tok',
      ),
    );
    notifier.continueAfterDuplicate();
    expect(container.read(jellybotAddFlowProvider)?.step, AddFlowStep.confirming);
  });
}
