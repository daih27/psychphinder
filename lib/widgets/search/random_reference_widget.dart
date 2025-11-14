import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/database/database_service.dart';

class RandomReferenceWidget extends StatefulWidget {
  const RandomReferenceWidget({super.key});

  @override
  State<RandomReferenceWidget> createState() => _RandomReferenceWidgetState();
}

class _RandomReferenceWidgetState extends State<RandomReferenceWidget> {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, dynamic>? _currentData;

  @override
  void initState() {
    super.initState();
    _loadRandomReference();
  }

  Future<void> _loadRandomReference() async {
    try {
      final quotesWithReferences =
          await _databaseService.getRandomQuotesWithReferences(limit: 100);
      if (quotesWithReferences.isNotEmpty) {
        final randomQuote =
            quotesWithReferences[Random().nextInt(quotesWithReferences.length)];

        setState(() {
          _currentData = {
            'referenceName': randomQuote.reference ?? 'Unknown Reference',
            'line': randomQuote.line,
            'phrase': randomQuote,
            'referenceId': randomQuote.reference ?? '',
          };
        });
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentData == null) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _currentData!;
    final String line = data['line'];
    final Phrase phrase = data['phrase'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Random Reference",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                        Text(
                          phrase.season == 999
                              ? phrase.time[0] == '0'
                                  ? phrase.time.substring(2)
                                  : phrase.time
                              : "S${phrase.season}E${phrase.episode} • ${phrase.time[0] == '0' ? phrase.time.substring(2) : phrase.time}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadRandomReference,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                phrase.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PsychFont',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context.go(
                      '/s${phrase.season}/e${phrase.episode}/p${phrase.sequenceInEpisode}',
                    );
                  },
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
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
