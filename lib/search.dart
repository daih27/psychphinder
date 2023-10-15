import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/full_episode.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/widgets/bottomsheet.dart';
import 'package:psychphinder/widgets/itemlist.dart';
import 'package:diacritic/diacritic.dart';
import 'global/globals.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'dart:math';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  @override
  bool get wantKeepAlive => true;
  List searched = <Phrase>[];
  Map map = {};
  bool isLoading = false;
  bool isSearching = false;
  String input = "";
  late int randomIndex;
  Random rng = Random();
  ValueNotifier<String> selectedSeason = ValueNotifier<String>('All');
  ValueNotifier<String> selectedEpisode = ValueNotifier<String>('All');
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    randomIndex = rng.nextInt(1955);
  }

  Widget randomReference(List data, List referenceData) {
    List<String> splittedLine = referenceData[randomIndex].idLine.split(',');
    int randomIndexSplitted = rng.nextInt(splittedLine.length);
    int randomSplittedLine = int.parse(splittedLine[randomIndexSplitted]);
    String line = data[randomSplittedLine].line;

    Widget randomReference = Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              referenceData[randomIndex].name,
              style: const TextStyle(
                fontFamily: 'PsychFont',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "Season ${referenceData[randomIndex].season}, Episode ${referenceData[randomIndex].episode}",
              style: const TextStyle(
                fontFamily: 'PsychFont',
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer),
              onPressed: () {
                EpisodeUtil.fullEpisode(data, data[randomSplittedLine]);
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
              child: Text(line, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  child: Text(
                    "${data[randomSplittedLine].time[0] == '0' ? data[randomSplittedLine].time.substring(2) : data[randomSplittedLine].time}",
                    style: const TextStyle(
                      fontFamily: 'PsychFont',
                    ),
                  ),
                ),
                const Expanded(
                    flex: 2, child: Center(child: Text("Random quote"))),
                Flexible(
                  flex: 1,
                  child: IconButton(
                      onPressed: () {
                        setState(
                          () {
                            randomIndex = rng.nextInt(1955);
                          },
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return randomReference;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var csvData = Provider.of<CSVData>(context);
    final List data = csvData.data;
    final Map<String, List<String>> episodesMap = csvData.episodesMap;
    final List<String> seasons = csvData.seasons;
    final List referenceData = csvData.referenceData;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
            child: TextField(
              controller: textEditingController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (text) async {
                map = {
                  "data": data,
                  "text": text,
                  "selectedSeason": selectedSeason.value,
                  "selectedEpisode": selectedEpisode.value
                };
                input = text;
                setState(() {
                  isLoading = true;
                  isSearching = true;
                });
                searched = await compute(_search, map);
                setState(() {
                  isLoading = false;
                });
              },
              cursorColor: Colors.white,
              decoration: InputDecoration(
                fillColor: Colors.green,
                filled: true,
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    map = {
                      "data": data,
                      "text": textEditingController.text,
                      "selectedSeason": selectedSeason.value,
                      "selectedEpisode": selectedEpisode.value
                    };
                    setState(() {
                      isLoading = true;
                      isSearching = true;
                    });
                    searched = await compute(_search, map);
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                suffixIconColor: Colors.white,
                labelStyle: const TextStyle(color: Colors.white),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
            ),
          ),
          ExpansionTile(
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Search options"),
            ),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text("Season"),
                          ValueListenableBuilder<String>(
                            valueListenable: selectedSeason,
                            builder: (context, value, _) {
                              return DropdownButtonFormField(
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded),
                                iconSize: 30,
                                iconEnabledColor: Colors.white,
                                dropdownColor: Colors.green,
                                decoration: InputDecoration(
                                  fillColor: Colors.green,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 12),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        const BorderSide(color: Colors.green),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        const BorderSide(color: Colors.green),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        const BorderSide(color: Colors.green),
                                  ),
                                ),
                                value: value,
                                items: seasons.map((season) {
                                  return DropdownMenuItem<String>(
                                    value: season,
                                    child: Text(season,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (season) {
                                  setState(() {
                                    selectedSeason.value = season!;
                                    selectedEpisode.value = "All";
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          selectedSeason.value == "Movies"
                              ? const Text("Movie")
                              : const Text("Episode"),
                          ValueListenableBuilder<String>(
                            valueListenable: selectedEpisode,
                            builder: (context, value, _) {
                              final selectedSeasonValue = selectedSeason.value;
                              final episodes = episodesMap[selectedSeasonValue];
                              return DropdownButtonFormField(
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded),
                                iconSize: 30,
                                iconEnabledColor: Colors.white,
                                dropdownColor: Colors.green,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  fillColor: Colors.green,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 12),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        const BorderSide(color: Colors.green),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        const BorderSide(color: Colors.green),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        const BorderSide(color: Colors.green),
                                  ),
                                ),
                                value: value,
                                items: episodes!.map((episode) {
                                  return DropdownMenuItem<String>(
                                    value: episode,
                                    child: Text(episode,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (episode) {
                                  setState(() {
                                    selectedEpisode.value = episode!;
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : searched.isNotEmpty
                  ? Expanded(
                      child: ItemList(
                          lines: searched, data: data, input: map["text"]))
                  : isSearching
                      ? const Expanded(
                          child: Center(
                            child: Text(
                              "No results found.",
                              style: TextStyle(
                                fontFamily: "PsychFont",
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(flex: 2),
                                const Text(
                                  "Welcome to psychphinder!",
                                  style: TextStyle(
                                    fontFamily: "PsychFont",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textScaleFactor: 1.0,
                                  textAlign: TextAlign.center,
                                ),
                                const Spacer(),
                                randomReference(data, referenceData),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
        ],
      ),
    );
  }
}

String replaceNumbersForWords(String input) {
  RegExp regExp = RegExp(r'\d+');
  Iterable<Match> matches = regExp.allMatches(input);
  for (Match match in matches) {
    input = input.replaceAll(match.group(0)!,
        NumberToWordsEnglish.convert(int.parse(match.group(0)!)));
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

Future<List<Phrase>> _search(map) async {
  List data = map["data"];
  String input = map["text"];
  String season = map["selectedSeason"];
  String episode = map["selectedEpisode"];
  List<Phrase> searched = <Phrase>[];
  String searchedClean = "";
  String inputClean =
      replaceContractions(replaceNumbersForWords(removeDiacritics(input)))
          .toLowerCase()
          .replaceAll("'", '')
          .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
          .replaceAll(RegExp(r"\s+"), ' ')
          .trim();
  for (var i = 0; i < data.length; i++) {
    searchedClean = replaceContractions(
            replaceNumbersForWords(removeDiacritics(data[i].line)))
        .toLowerCase()
        .replaceAll("'", '')
        .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
        .replaceAll(RegExp(r"\s+"), ' ')
        .trim();
    if (partialRatio(inputClean, searchedClean) > 90 &&
        searchedClean.length >= inputClean.length - 2) {
      if (season == "All") {
        searched.add(Phrase(
            id: data[i].id,
            season: data[i].season,
            episode: data[i].episode,
            name: data[i].name,
            time: data[i].time,
            line: data[i].line,
            reference: data[i].reference));
      } else {
        if (episode != "All" && season != "Movies") {
          if (data[i].season == int.parse(season) &&
              data[i].episode ==
                  int.parse(episode.replaceAll(RegExp(r'[^0-9]'), ''))) {
            searched.add(Phrase(
                id: data[i].id,
                season: data[i].season,
                episode: data[i].episode,
                name: data[i].name,
                time: data[i].time,
                line: data[i].line,
                reference: data[i].reference));
          }
        } else {
          if (season != "Movies") {
            if (data[i].season == int.parse(season)) {
              searched.add(Phrase(
                  id: data[i].id,
                  season: data[i].season,
                  episode: data[i].episode,
                  name: data[i].name,
                  time: data[i].time,
                  line: data[i].line,
                  reference: data[i].reference));
            }
          } else {
            if (data[i].season == 0 && season == "Movies" && episode == "All") {
              searched.add(Phrase(
                  id: data[i].id,
                  season: data[i].season,
                  episode: data[i].episode,
                  name: data[i].name,
                  time: data[i].time,
                  line: data[i].line,
                  reference: data[i].reference));
            } else {
              if (data[i].season == 0 &&
                  season == "Movies" &&
                  episode[0] == "1") {
                if (data[i].name == "Psych: The Movie") {
                  searched.add(Phrase(
                      id: data[i].id,
                      season: data[i].season,
                      episode: data[i].episode,
                      name: data[i].name,
                      time: data[i].time,
                      line: data[i].line,
                      reference: data[i].reference));
                }
              } else {
                if (data[i].season == 0 &&
                    season == "Movies" &&
                    episode[0] == "2") {
                  if (data[i].name == "Psych 2: Lassie Come Home") {
                    searched.add(Phrase(
                        id: data[i].id,
                        season: data[i].season,
                        episode: data[i].episode,
                        name: data[i].name,
                        time: data[i].time,
                        line: data[i].line,
                        reference: data[i].reference));
                  }
                } else {
                  if (data[i].season == 0 &&
                      season == "Movies" &&
                      episode[0] == "3") {
                    if (data[i].name == "Psych 3: This Is Gus") {
                      searched.add(Phrase(
                          id: data[i].id,
                          season: data[i].season,
                          episode: data[i].episode,
                          name: data[i].name,
                          time: data[i].time,
                          line: data[i].line,
                          reference: data[i].reference));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return searched;
}
