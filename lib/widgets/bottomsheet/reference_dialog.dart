import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferenceDialog {
  static void show(
    BuildContext context,
    List<Reference> references,
    SearchEngineProvider searchEngineProvider,
  ) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.green,
        title: const Text(
          'This is a reference to',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: references.length > 1
            ? _MultipleReferencesContent(
                references: references,
                searchEngineProvider: searchEngineProvider,
              )
            : _SingleReferenceContent(
                reference: references.first,
                searchEngineProvider: searchEngineProvider,
              ),
      ),
    );
  }
}

class _MultipleReferencesContent extends StatelessWidget {
  final List<Reference> references;
  final SearchEngineProvider searchEngineProvider;

  const _MultipleReferencesContent({
    required this.references,
    required this.searchEngineProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < references.length; i++) ...[
          _ReferenceRow(
            reference: references[i],
            searchEngineProvider: searchEngineProvider,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SingleReferenceContent extends StatelessWidget {
  final Reference reference;
  final SearchEngineProvider searchEngineProvider;

  const _SingleReferenceContent({
    required this.reference,
    required this.searchEngineProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _ReferenceRow(
      reference: reference,
      searchEngineProvider: searchEngineProvider,
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  final Reference reference;
  final SearchEngineProvider searchEngineProvider;

  const _ReferenceRow({
    required this.reference,
    required this.searchEngineProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            reference.reference,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final url = Uri.parse(
              '${searchEngineProvider.currentSearchEngine}${reference.reference.replaceAll("&", "%26")}',
            );
            launchUrl(
              url,
              mode: searchEngineProvider.openLinks
                  ? LaunchMode.inAppWebView
                  : LaunchMode.externalApplication,
            );
          },
          icon: const Icon(Icons.search, color: Colors.white),
        ),
        ...reference.link.split(",").map((link) {
          if (link.isEmpty) return const SizedBox();

          if (link.contains("youtu.be")) {
            return IconButton(
              onPressed: () {
                launchUrl(
                  Uri.parse(link),
                  mode: searchEngineProvider.openLinks
                      ? LaunchMode.inAppWebView
                      : LaunchMode.externalApplication,
                );
              },
              icon: const FaIcon(
                FontAwesomeIcons.youtube,
                color: Colors.white,
              ),
            );
          } else if (link.contains("imdb.com")) {
            return IconButton(
              onPressed: () {
                launchUrl(
                  Uri.parse(link),
                  mode: searchEngineProvider.openLinks
                      ? LaunchMode.inAppWebView
                      : LaunchMode.externalApplication,
                );
              },
              icon: const FaIcon(
                FontAwesomeIcons.imdb,
                color: Colors.white,
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }
}
