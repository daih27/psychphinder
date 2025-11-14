import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_md/flutter_md.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static Future<bool> shouldShowUpdate() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    if (pref.getInt("latestAppVersion") == null) {
      pref.setInt("latestAppVersion", 16);
    }
    int latestAppVersion = pref.getInt("latestAppVersion") ?? buildNumber;
    return buildNumber > latestAppVersion;
  }

  static Future<void> showWhatsNewDialog(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    String dialogContent = await rootBundle.loadString('assets/CHANGELOG.md');
    pref.setInt("latestAppVersion", buildNumber);
    if (!context.mounted) return;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('What\'s new?'),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: Center(
              child: SingleChildScrollView(
                child: MarkdownTheme(
                  data: MarkdownThemeData(
                    textStyle: TextStyle(
                        fontSize: 16.0,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                    h1Style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    h2Style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    quoteStyle: TextStyle(
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    onLinkTap: (url, title) {
                      launchUrl(Uri.parse(title));
                    },
                    spanFilter: (span) =>
                        !span.style.contains(MD$Style.spoiler),
                  ),
                  child: MarkdownWidget(
                    markdown: Markdown.fromString(dialogContent),
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
