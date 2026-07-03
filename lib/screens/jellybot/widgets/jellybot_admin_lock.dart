import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/util/localization_helper.dart';

/// Shown in place of an admin-only jellybot page when the current user is
/// not a Jellyfin administrator.
class JellybotAdminLock extends StatelessWidget {
  const JellybotAdminLock({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(IconsaxPlusLinear.lock, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(context.localized.adminOnly, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
