import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_routes.dart';
import '../../../design_system/indo_pay_colors.dart';
import '../../../design_system/indo_pay_tokens.dart';
import '../../../design_system/widgets/fintech_tap_scale.dart';
import '../../../design_system/widgets/glass_card.dart';
import '../data/update_repository.dart';
import '../domain/app_update_info.dart';

class UpdateDialog extends ConsumerWidget {
  const UpdateDialog({
    required this.info,
    super.key,
  });

  final AppUpdateInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: !info.forceUpdate,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            radius: IndoPayRadii.lg,
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.security_update_good_rounded,
                    size: 64,
                    color: IndoPayColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Update Available',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    info.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  FintechTapScale(
                    onTap: () async {
                      final url = Uri.parse(info.apkUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: IndoPayColors.primary,
                        borderRadius: BorderRadius.circular(IndoPayRadii.md),
                      ),
                      child: Text(
                        'Update Now',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  if (!info.forceUpdate) ...[
                    const SizedBox(height: 12),
                    FintechTapScale(
                      onTap: () async {
                        await ref.read(updateRepositoryProvider).dismissUpdate(info.latestVersion);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          AppRoute.home.go(context);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Later',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: IndoPayColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
