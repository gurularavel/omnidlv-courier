import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/providers.dart';
import 'theme.dart';

/// Shown when this build is older than the server's min_version.
class UpdateScreen extends ConsumerWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final urls = ref.watch(appSettingsProvider).value?.storeUrls ?? const {};
    final url = urls[Platform.isIOS ? 'ios' : 'android'];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Spacer(),
            Text(t.updateTitle, style: Typo.display),
            const SizedBox(height: 12),
            Text(t.updateBody, style: Typo.body),
            const Spacer(),
            FilledButton(
              onPressed: url == null ? null : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              child: Text(t.update.toUpperCase()),
            ),
          ]),
        ),
      ),
    );
  }
}
