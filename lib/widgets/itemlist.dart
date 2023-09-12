import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:psychphinder/classes/full_episode.dart';
import 'package:psychphinder/widgets/bottomsheet.dart';
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("favorites").listenable(),
      builder: (BuildContext context, dynamic box, Widget? child) {
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: lines.length,
          itemBuilder: (context, index) {
            final isFavorite = box.get(lines[index].id) != null;
            final hasReference = lines[index].reference.contains("s");
            Map<String, HighlightedWord> words = {};
            if (input != null) {
              HighlightedWord highlightedWord = HighlightedWord(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              );
              final inputClean = removeDiacritics(input!)
                  .toLowerCase()
                  .replaceAll("'", '')
                  .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
                  .replaceAll(RegExp(r"\s+"), ' ')
                  .trim();
              final linesClean = removeDiacritics(lines[index].line)
                  .toLowerCase()
                  .replaceAll("'", '')
                  .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
                  .replaceAll(RegExp(r"\s+"), ' ')
                  .trim();
              final List inputSplit = inputClean.split(" ");
              final List inputSplitNotClean = input!.split(" ");
              final List linesSplitNotClean = lines[index].line.split(" ");
              final List inputSplitWithoutNumbers =
                  replaceNumbersForWords(inputClean).split(" ");
              final bool inputHasContractions =
                  input! != replaceContractions(input!);
              final bool lineHasContractions =
                  lines[index].line != replaceContractions(lines[index].line);
              final bool inputHasNumbers = inputClean.contains(RegExp(r'\d+'));
              final bool lineHasNumbers = linesClean.contains(RegExp(r'\d+'));
              if (inputHasNumbers && lineHasNumbers) {
                for (var i = 0; i < inputSplit.length; i++) {
                  for (var j = 0; j < linesSplitNotClean.length; j++) {
                    words[input!] = highlightedWord;
                    if (weightedRatio(linesSplitNotClean[j], inputSplit[i]) >=
                        20) {
                      words[linesSplitNotClean[j]] = highlightedWord;
                    }
                  }
                }
              }
              if (inputHasNumbers && !lineHasNumbers) {
                for (var i = 0; i < inputSplitWithoutNumbers.length; i++) {
                  for (var j = 0; j < linesSplitNotClean.length; j++) {
                    words[inputSplitWithoutNumbers[i]] = highlightedWord;
                    if (weightedRatio(linesSplitNotClean[j],
                            inputSplitWithoutNumbers[i]) >=
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
                    if (weightedRatio(
                                inputSplitNotClean[i], linesSplitNotClean[j]) >=
                            86 &&
                        linesSplitNotClean[j].length >=
                            inputSplitNotClean[i].length) {
                      words[linesSplitNotClean[j]] = highlightedWord;
                    }
                  }
                }
              }
              if (inputHasContractions && lineHasContractions) {
                for (var i = 0; i < inputSplitNotClean.length; i++) {
                  words[inputSplitNotClean[i]] = highlightedWord;
                  words[replaceContractions(inputSplitNotClean[i])] =
                      highlightedWord;
                }
              }
              if (inputHasContractions && !lineHasContractions) {
                for (var i = 0; i < inputSplitNotClean.length; i++) {
                  words[replaceContractions(inputSplitNotClean[i])] =
                      highlightedWord;
                }
              }
              if (!inputHasContractions && lineHasContractions) {
                for (var i = 0; i < inputSplit.length; i++) {
                  words[inputSplit[i]] = highlightedWord;
                  for (var j = 0; j < linesSplitNotClean.length; j++) {
                    if (weightedRatio(
                                replaceContractions(linesSplitNotClean[j]),
                                inputSplit[i]) >=
                            86 &&
                        linesSplitNotClean[j].length >=
                            inputSplitNotClean[i].length) {
                      words[linesSplitNotClean[j]] = highlightedWord;
                    }
                  }
                }
              }
            }
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Material(
                child: ListTile(
                  title: TextHighlight(
                    text: lines[index].line,
                    words: words,
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
                        const Icon(
                          Icons.question_mark_rounded,
                          color: Colors.green,
                        ),
                    ],
                  ),
                  onTap: () {
                    EpisodeUtil.fullEpisode(data, lines[index]);
                    showModalBottomSheet(
                      context: context,
                      enableDrag: false,
                      builder: (BuildContext context) {
                        return BottomSheetEpisode(
                          indexLine: EpisodeUtil.index,
                          fullEpisode: EpisodeUtil.full,
                          referencesList: const [],
                        );
                      },
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
