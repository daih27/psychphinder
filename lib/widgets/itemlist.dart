import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:diacritic/diacritic.dart';

class ItemList extends StatelessWidget {
  const ItemList({super.key, required this.lines, this.input});

  final List lines;
  final String? input;

  Map<String, HighlightedWord> highlightedWords(String input) {
    Map<String, HighlightedWord> words = {};
    HighlightedWord highlightedWord = HighlightedWord(
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );

    String normalizedInput = removeDiacritics(input.toLowerCase());
    List<String> searchTerms = normalizedInput
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty && term.length > 1)
        .toList();

    for (String term in searchTerms) {
      words[term] = highlightedWord;

      words[term.toLowerCase()] = highlightedWord;
      words[term.toUpperCase()] = highlightedWord;
      words[_capitalize(term)] = highlightedWord;
    }

    if (input.contains("and")) {
      words["&"] = highlightedWord;
    }
    if (input.contains("&")) {
      words["and"] = highlightedWord;
    }

    return words;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  List<bool> checkVideo(List referenceData, List lines) {
    List<bool> videos = [];
    int seasonReference;
    int episodeReference;
    int season;
    int episode;
    for (var i = 0; i < lines.length; i++) {
      season = lines[i].season;
      episode = lines[i].episode;
      bool splittedIsTrue = false;
      for (var j = 0; j < referenceData.length; j++) {
        seasonReference = referenceData[j].season;
        episodeReference = referenceData[j].episode;
        if (seasonReference == season && episodeReference == episode) {
          final idPhrase = lines[i].reference?.replaceAll('\r', '').trim() ?? '';
          final splitted = idPhrase.split(',');
          for (var k = 0; k < splitted.length; k++) {
            if (splitted[k] == referenceData[j].id &&
                referenceData[j].link.contains("youtu.be")) {
              splittedIsTrue = true;
            }
          }
        }
      }
      if (splittedIsTrue) {
        videos.add(true);
      } else {
        videos.add(false);
      }
    }
    return videos;
  }

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService>(context);
    return FutureBuilder<List>(
      future: databaseService.getReferences(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final referenceData = snapshot.data ?? [];
        
        return ValueListenableBuilder(
          valueListenable: Hive.box("favorites").listenable(),
          builder: (BuildContext context, dynamic box, Widget? child) {
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final isFavorite = box.get(lines[index].id) != null;
                final hasReference = lines[index].reference?.contains("s") ?? false;
                final hasVideo = checkVideo(referenceData, lines);
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Material(
                child: ListTile(
                  title: TextHighlight(
                    text: lines[index].line,
                    words: input != null ? highlightedWords(input!) : {},
                  ),
                  subtitle: Text(
                    lines[index].season == 999
                        ? lines[index].name
                        : "Season ${lines[index].season}, Episode ${lines[index].episode}: ${lines[index].name}",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFavorite)
                        const Icon(
                          Icons.favorite,
                          color: Colors.green,
                        ),
                      if (hasReference)
                        Stack(
                          children: [
                            if (hasReference)
                              const Icon(Icons.question_mark_rounded,
                                  color: Colors.green)
                            else
                              const SizedBox(),
                            if (hasVideo.isNotEmpty && hasVideo[index])
                              const Positioned(
                                right: 0,
                                bottom: 0,
                                child: Icon(FontAwesomeIcons.youtube,
                                    color: Colors.green, size: 9),
                              )
                            else
                              const SizedBox(),
                          ],
                        ),
                    ],
                  ),
                  onTap: () {
                    context.go(
                      '/s${lines[index].season}/e${lines[index].episode}/p${lines[index].sequenceInEpisode}',
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
      },
    );
  }
}
