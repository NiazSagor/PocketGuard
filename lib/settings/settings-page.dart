import 'package:flutter/material.dart';
import 'package:pocket_guard/helpers/alert-dialog-builder.dart';
import 'package:pocket_guard/premium/splash-screen.dart';
import 'package:pocket_guard/premium/util-widgets.dart';
import 'package:pocket_guard/recurrent_record_patterns/patterns-page-view.dart';
import 'package:pocket_guard/services/database/database-interface.dart';
import 'package:pocket_guard/services/service-config.dart';
import 'package:pocket_guard/settings/backup-restore-dialogs.dart';
import 'package:pocket_guard/settings/feedback-page.dart';
import 'package:pocket_guard/settings/settings-item.dart';
import 'package:pocket_guard/tags/tags-page-view.dart';
import 'package:pocket_guard/template/templates-list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n.dart';
import 'backup-page.dart';
import 'customization-page.dart';

// look here for how to store settings
//https://flutter.dev/docs/cookbook/persistence/key-value
//https://pub.dev/packages/shared_preferences

class TabSettings extends StatelessWidget {
  static const double kSettingsItemsExtent = 75.0;
  static const double kSettingsItemsIconPadding = 8.0;
  static const double kSettingsItemsIconElevation = 2.0;
  final DatabaseInterface database = ServiceConfig.database;

  deleteAllData(BuildContext context) async {
    AlertDialogBuilder premiumDialog =
        AlertDialogBuilder("Critical action".i18n)
            .addSubtitle("Do you really want to delete all the data?".i18n)
            .addTrueButtonName("Yes".i18n)
            .addFalseButtonName("No".i18n);
    var ok = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return premiumDialog.build(context);
      },
    );
    if (ok) {
      await database.deleteDatabase();
      AlertDialogBuilder resultDialog =
          AlertDialogBuilder("Data is deleted".i18n)
              .addSubtitle("All the data has been deleted".i18n)
              .addTrueButtonName("OK");
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return resultDialog.build(context);
        },
      );
    }
  }

  goToPremiumSplashScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PremiumSplashScreen()),
    );
  }

  goToRecurrentRecordPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PatternsPageView()),
    );
  }

  goToTagsPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TagsPageView()),
    );
  }

  goToTemplatesPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TemplatesList()),
    );
  }

  goToCustomizationPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomizationPage()),
    );
  }

  goToBackupPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BackupPage()),
    );
  }

  goToFeedbackPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedbackPage()),
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'.i18n)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: <Widget>[
          _buildSectionHeader(context, 'Appearance'.i18n),
          SettingsItem(
            icon: const Icon(Icons.wallpaper, color: Colors.white),
            iconBackgroundColor: Colors.blue.shade600,
            title: 'Customization'.i18n,
            subtitle: "Visual settings and more".i18n,
            onPressed: () => goToCustomizationPage(context),
          ),

          const Divider(),

          _buildSectionHeader(context, 'Management'.i18n),
          SettingsItem(
            icon: const Icon(Icons.repeat, color: Colors.white),
            iconBackgroundColor: Colors.pink.shade600,
            title: 'Recurrent Records'.i18n,
            subtitle: "View or delete recurrent records".i18n,
            onPressed: () => goToRecurrentRecordPage(context),
          ),
          SettingsItem(
            icon: const Icon(Icons.tag, color: Colors.white),
            iconBackgroundColor: Colors.amber.shade600,
            title: 'Tags'.i18n,
            subtitle: "Manage your existing tags".i18n,
            onPressed: () => goToTagsPage(context),
          ),
          SettingsItem(
            icon: const Icon(Icons.layers, color: Colors.white),
            iconBackgroundColor: Colors.amber.shade600,
            title: 'Templates'.i18n,
            subtitle: "Manage your existing templates".i18n,
            onPressed: () => goToTemplatesPage(context),
          ),

          const Divider(),

          _buildSectionHeader(context, 'Data'.i18n),
          SettingsItem(
            icon: const Icon(Icons.backup, color: Colors.white),
            iconBackgroundColor: Colors.orange.shade600,
            title: 'Backup'.i18n,
            subtitle: "Create backup and change settings".i18n,
            onPressed: () => goToBackupPage(context),
          ),

          _buildRestoreBackupItem(context),

          SettingsItem(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            iconBackgroundColor: Colors.red.shade400,
            title: 'Delete'.i18n,
            subtitle: 'Delete all the data'.i18n,
            onPressed: () => deleteAllData(context),
          ),

          const Divider(),

          _buildSectionHeader(context, 'Support'.i18n),
          SettingsItem(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            iconBackgroundColor: Colors.tealAccent.shade700,
            title: 'Info'.i18n,
            subtitle: 'Privacy policy and credits'.i18n,
            onPressed: () => _launchURL(""),
          ),
          SettingsItem(
            icon: const Icon(Icons.mail_outline, color: Colors.white),
            iconBackgroundColor: Colors.red.shade700,
            title: 'Feedback'.i18n,
            subtitle: "Send us a feedback".i18n,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FeedbackPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreBackupItem(BuildContext context) {
    final bool isPremium = ServiceConfig.isPremium;

    return SettingsItem(
      icon: const Icon(Icons.restore_page, color: Colors.white),
      iconBackgroundColor: Colors.teal,
      titleWidget: Row(
        children: [
          Text('Restore Backup'.i18n),
          if (!isPremium) ...[
            const SizedBox(width: 8),
            getProLabel(labelFontSize: 10.0),
          ],
        ],
      ),
      title: 'Restore Backup'.i18n,
      subtitle: "Restore data from a backup file".i18n,
      onPressed: isPremium
          ? () => BackupRestoreDialog.importFromBackupFile(context)
          : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PremiumSplashScreen()),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
