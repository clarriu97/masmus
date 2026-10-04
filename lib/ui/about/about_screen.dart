import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/links.dart';
import '../theme/app_theme.dart';
import '../widgets/felt.dart';

/// The version shown in the app. It must match `version:` in pubspec.yaml
/// (a test checks it): bump both in the release PR.
const appVersion = '1.0.0';
const appBuild = 1;

final website = Uri.https('masmus.larri.dev', '/');
final privacy = Uri.https('masmus.larri.dev', '/privacy/');
final terms = Uri.https('masmus.larri.dev', '/terms/');
const contact = 'info.masmus@larri.dev';

/// The version, that nothing leaves the phone, and the links the stores
/// ask for: web, privacy, terms, contact and licenses.
class AboutScreen extends StatelessWidget {
  const AboutScreen({required this.links, super.key});

  final Links links;

  Future<void> _open(BuildContext context, Uri url, String shown) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).aboutCouldNotOpen(shown);
    if (!await links.open(url)) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final version = l10n.aboutVersion(appVersion, appBuild);
    Widget link(
      IconData icon,
      String title,
      VoidCallback onTap, {
      String? detail,
      bool external = true,
    }) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.ink),
      title: Text(title, style: text.titleMedium),
      subtitle: detail == null ? null : Text(detail, style: text.bodyMedium),
      trailing: external
          ? const Icon(Icons.open_in_new, color: AppColors.inkSecondary)
          : null,
      onTap: onTap,
    );
    return Scaffold(
      body: Felt(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.back),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.sm,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(l10n.appTitle, style: text.displayMedium),
                      ),
                      Text(version, style: text.titleMedium),
                      Text(l10n.aboutTagline, style: text.bodyLarge),
                      const SizedBox(height: AppSpacing.md),
                      link(
                        Icons.public,
                        l10n.aboutWebsite,
                        () => _open(context, website, website.host),
                        detail: website.host,
                      ),
                      link(
                        Icons.privacy_tip_outlined,
                        l10n.aboutPrivacy,
                        () => _open(context, privacy, l10n.aboutPrivacy),
                      ),
                      link(
                        Icons.description_outlined,
                        l10n.aboutTerms,
                        () => _open(context, terms, l10n.aboutTerms),
                      ),
                      link(
                        Icons.mail_outline,
                        l10n.aboutContact,
                        () => _open(
                          context,
                          Uri(scheme: 'mailto', path: contact),
                          contact,
                        ),
                        detail: contact,
                      ),
                      link(
                        Icons.article_outlined,
                        l10n.aboutLicenses,
                        () => showLicensePage(
                          context: context,
                          applicationName: l10n.appTitle,
                          applicationVersion: version,
                        ),
                        external: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
