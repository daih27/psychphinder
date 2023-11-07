import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/global/globals.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:diacritic/diacritic.dart';
import 'package:number_to_words_english/number_to_words_english.dart';

class ItemList extends StatelessWidget {
  const ItemList(
      {super.key, required this.lines, required this.data, this.input});

  final List lines;
  final List data;
  final String? input;

  String replaceNumbersForWords(String input) {
    RegExp regExp = RegExp(r'\d+');
    Iterable<Match> matches = regExp.allMatches(input);
    for (Match match in matches) {
      input = input.replaceAll(match.group(0)!,
          NumberToWordsEnglish.convert(int.parse(match.group(0)!)));
      input = "$input ${match.group(0)!}";
    }

    return input;
  }

  String replaceContractions(String input) {
    input = input.replaceAll('\'s', ' is');
    input = input.replaceAll('\'m', ' am');
    input = input.replaceAll('\'re', ' are');
    input = input.replaceAll('\'ll', ' will');
    input = input.replaceAll('n\'t', ' not');
    input = input.replaceAll('\'d', ' would');
    input = input.replaceAll('\'ve', ' have');
    return input;
  }

  Map<String, HighlightedWord> highlightedWords(String input, int index) {
    Map<String, HighlightedWord> words = {};
    HighlightedWord highlightedWord = HighlightedWord(
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
    final inputClean = input;
    final linesClean = removeDiacritics(lines[index].line)
        .toLowerCase()
        .replaceAll("'", '')
        .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
        .replaceAll(RegExp(r"\s+"), ' ')
        .trim();
    final List inputSplit = inputClean.split(" ");
    final List inputSplitNotClean = input.split(" ");
    final List linesSplitNotClean = lines[index].line.split(" ");
    final List inputSplitWithoutNumbers =
        replaceNumbersForWords(inputClean).split(" ");
    final bool inputHasContractions = input != replaceContractions(input);
    final bool lineHasContractions =
        lines[index].line != replaceContractions(lines[index].line);
    final bool inputHasNumbers = inputClean.contains(RegExp(r'\d+'));
    final bool lineHasNumbers = linesClean.contains(RegExp(r'\d+'));
    if (inputHasNumbers && lineHasNumbers) {
      for (var i = 0; i < inputSplit.length; i++) {
        for (var j = 0; j < linesSplitNotClean.length; j++) {
          words[input] = highlightedWord;
          if (weightedRatio(linesSplitNotClean[j], inputSplit[i]) >= 20) {
            words[linesSplitNotClean[j]] = highlightedWord;
          }
        }
      }
    }
    if (inputHasNumbers && !lineHasNumbers) {
      for (var i = 0; i < inputSplitWithoutNumbers.length; i++) {
        for (var j = 0; j < linesSplitNotClean.length; j++) {
          words[inputSplitWithoutNumbers[i]] = highlightedWord;
          if (weightedRatio(
                  linesSplitNotClean[j], inputSplitWithoutNumbers[i]) >=
              90) {
            words[linesSplitNotClean[j]] = highlightedWord;
          }
        }
      }
    }
    if (!inputHasNumbers && lineHasNumbers) {
      for (var i = 0; i < inputSplit.length; i++) {
        for (var j = 0; j < linesSplitNotClean.length; j++) {
          words[inputSplit[i]] = highlightedWord;
          if (weightedRatio(inputSplit[i],
                  replaceNumbersForWords(linesSplitNotClean[j])) >=
              90) {
            words[linesSplitNotClean[j]] = highlightedWord;
          }
        }
      }
    }
    if (!inputHasNumbers &&
        !lineHasNumbers &&
        !inputHasContractions &&
        !lineHasContractions) {
      for (var i = 0; i < inputSplitNotClean.length; i++) {
        words[inputSplitNotClean[i]] = highlightedWord;
        for (var j = 0; j < linesSplitNotClean.length; j++) {
          if (weightedRatio(inputSplitNotClean[i], linesSplitNotClean[j]) >=
                  86 &&
              linesSplitNotClean[j].length >= inputSplitNotClean[i].length) {
            words[linesSplitNotClean[j]] = highlightedWord;
          }
        }
      }
    }
    if (inputHasContractions && lineHasContractions) {
      for (var i = 0; i < inputSplitNotClean.length; i++) {
        words[inputSplitNotClean[i]] = highlightedWord;
        words[replaceContractions(inputSplitNotClean[i])] = highlightedWord;
      }
    }
    if (inputHasContractions && !lineHasContractions) {
      for (var i = 0; i < inputSplitNotClean.length; i++) {
        words[replaceContractions(inputSplitNotClean[i])] = highlightedWord;
      }
    }
    if (!inputHasContractions && lineHasContractions) {
      for (var i = 0; i < inputSplit.length; i++) {
        words[inputSplit[i]] = highlightedWord;
        for (var j = 0; j < linesSplitNotClean.length; j++) {
          if (weightedRatio(replaceContractions(linesSplitNotClean[j]),
                      inputSplit[i]) >=
                  86 &&
              linesSplitNotClean[j].length >= inputSplitNotClean[i].length) {
            words[linesSplitNotClean[j]] = highlightedWord;
          }
        }
      }
    }
    return words;
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
          final idPhrase = lines[i].reference.replaceAll('\r', '').trim();
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
    var csvData = Provider.of<CSVData>(context);
    final List referenceData = csvData.referenceData;
    return ValueListenableBuilder(
      valueListenable: Hive.box("favorites").listenable(),
      builder: (BuildContext context, dynamic box, Widget? child) {
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: lines.length,
          itemBuilder: (context, index) {
            final isFavorite = box.get(lines[index].id) != null;
            final hasReference = lines[index].reference.contains("s");
            final hasVideo = checkVideo(referenceData, lines);
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Material(
                child: ListTile(
                  title: TextHighlight(
                    text: lines[index].line,
                    words: input != null ? highlightedWords(input!, index) : {},
                  ),
                  subtitle: Text(
                    lines[index].season != 0
                        ? "Season ${lines[index].season}, Episode ${lines[index].episode}: ${lines[index].name}"
                        : lines[index].name,
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
                      '/${lines[index].id}',
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
