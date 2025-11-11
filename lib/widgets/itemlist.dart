import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:diacritic/diacritic.dart';
import 'package:psychphinder/utils/responsive.dart';

class ItemList extends StatelessWidget {
  const ItemList({super.key, required this.lines, this.input});

  final List lines;
  final String? input;

  Map<String, HighlightedWord> highlightedWords(
      String input, BuildContext context) {
    Map<String, HighlightedWord> words = {};
    HighlightedWord highlightedWord = HighlightedWord(
      textStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: Colors.green,
        letterSpacing: 0.1,
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
          final idPhrase =
              lines[i].reference?.replaceAll('\r', '').trim() ?? '';
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
            final padding = ResponsiveUtils.getScreenPadding(context);
            
            return ListView.builder(
              padding: padding,
              itemCount: lines.length,
              itemBuilder: (context, index) {
                return _buildQuoteCard(context, box, referenceData, index);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQuoteCard(BuildContext context, dynamic box, List referenceData, int index) {
    final isFavorite = box.get(lines[index].id) != null;
    final hasReference = lines[index].reference?.contains("s") ?? false;
    final hasVideo = checkVideo(referenceData, lines);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context) * 0.75,
        vertical: ResponsiveUtils.getVerticalPadding(context) * 0.5,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.go(
              '/s${lines[index].season}/e${lines[index].episode}/p${lines[index].sequenceInEpisode}',
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalPadding(context),
              vertical: ResponsiveUtils.getVerticalPadding(context) + 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextHighlight(
                  text: lines[index].line,
                  words: input != null
                      ? highlightedWords(input!, context)
                      : {},
                  textStyle: TextStyle(
                    fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.1,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getVerticalPadding(context) + 6),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lines[index].season == 999
                                ? lines[index].name
                                : "${lines[index].name} • S${lines[index].season}E${lines[index].episode}",
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getSmallFontSize(context) + 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 0.25),
                          Text(
                            lines[index].time[0] == '0'
                                ? lines[index].time.substring(2)
                                : lines[index].time,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getSmallFontSize(context) - 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.45),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasReference)
                          Padding(
                            padding: EdgeInsets.only(right: ResponsiveUtils.getHorizontalPadding(context) * 0.75),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.7),
                                  size: ResponsiveUtils.getIconSize(context) - 2,
                                ),
                                if (hasVideo.isNotEmpty && hasVideo[index])
                                  Positioned(
                                    right: -6,
                                    top: -4,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (isFavorite)
                          Icon(
                            Icons.favorite,
                            color: Colors.red.shade400,
                            size: ResponsiveUtils.getIconSize(context) - 2,
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
