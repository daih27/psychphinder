import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/widgets/itemlist.dart';
import 'global/globals.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List searched = <Phrase>[];

  List<dynamic> _search(
      List data, String input, String season, String episode) {
    List searched = <Phrase>[];
    String searchedClean = "";
    for (var i = 0; i < data.length; i++) {
      searchedClean = data[i]
          .line
          .toLowerCase()
          .replaceAll(RegExp('[^A-Za-z0-9 ]'), '')
          .replaceAll("  ", " ")
          .replaceAll("   ", " ");
      searchedClean[0].replaceAll('  ', '').replaceAll(' ', '');
      if (partialRatio(
                  input.toLowerCase().replaceAll(RegExp('[^A-Za-z0-9 ]'), ''),
                  searchedClean) >
              90 &&
          searchedClean.length >=
              input.replaceAll(RegExp('[^A-Za-z0-9 ]'), '').length - 2) {
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
              if (data[i].season == 0 &&
                  season == "Movies" &&
                  episode == "All") {
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
    setState(() {
      searched;
    });
    return searched;
  }

  ValueNotifier<String> selectedSeason = ValueNotifier<String>('All');
  ValueNotifier<String> selectedEpisode = ValueNotifier<String>('All');
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final List data = csvData.data;
    final Map<String, List<String>> episodesMap = csvData.episodesMap;
    final List<String> seasons = csvData.seasons;
    final TextEditingController textEditingController = TextEditingController();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 7),
            child: TextField(
              controller: textEditingController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (text) {
                searched = _search(
                  data,
                  text,
                  selectedSeason.value,
                  selectedEpisode.value,
                );
                isSearching = true;
              },
              cursorColor: Colors.white,
              decoration: InputDecoration(
                fillColor: Colors.green,
                filled: true,
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    searched = _search(
                      data,
                      textEditingController.text,
                      selectedSeason.value,
                      selectedEpisode.value,
                    );
                    isSearching = true;
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
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
                                    style:
                                        const TextStyle(color: Colors.white)),
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
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
                                    style:
                                        const TextStyle(color: Colors.white)),
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
          (searched.isNotEmpty)
              ? Expanded(child: ItemList(lines: searched, data: data))
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
                  : const Expanded(
                      child: Center(
                        child: Text(
                          "Welcome to psychphinder!",
                          style: TextStyle(
                            fontFamily: "PsychFont",
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
