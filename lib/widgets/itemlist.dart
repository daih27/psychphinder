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
              final List inputSplit = input!.split(" ");
              final List linesSplit = lines[index].line.split(" ");
              for (var i = 0; i < inputSplit.length; i++) {
                var inputClean = replaceNumbersForWords(
                    removeDiacritics(inputSplit[i])
                        .toLowerCase()
                        .replaceAll("'", '')
                        .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
                        .replaceAll(RegExp(r"\s+"), ' ')
                        .trim());
                for (var j = 0; j < linesSplit.length; j++) {
                  var lineCleanWithNumbers = removeDiacritics(linesSplit[j])
                      .toLowerCase()
                      .replaceAll("'", '')
                      .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
                      .replaceAll(RegExp(r"\s+"), ' ')
                      .trim();
                  var lineCleanWithoutNumbers =
                      replaceNumbersForWords(lineCleanWithNumbers);
                  if (weightedRatio(lineCleanWithoutNumbers, inputClean) >=
                          92 &&
                      inputClean.length >= lineCleanWithoutNumbers.length) {
                    words[linesSplit[j]] = highlightedWord;
                  } else {
                    words[inputSplit[i]] = highlightedWord;
                  }
                  if (lineCleanWithNumbers != lineCleanWithoutNumbers &&
                      weightedRatio(lineCleanWithoutNumbers, input!) >= 90) {
                    words[linesSplit[j]] = highlightedWord;
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
