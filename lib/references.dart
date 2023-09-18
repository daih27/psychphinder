import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/full_episode.dart';
import 'package:psychphinder/global/globals.dart';
import 'package:psychphinder/widgets/bottomsheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReferencesPage extends StatelessWidget {
  const ReferencesPage({Key? key}) : super(key: key);

  List countProgress(List referenceData) {
    List totalRefs = [0, 0, 0, 0, 0, 0, 0];
    List total = [0, 0, 0, 0, 0, 0, 0];
    List totalPercent = [0, 0, 0, 0, 0, 0, 0];
    for (var i = 0; i < referenceData.length; i++) {
      totalRefs[referenceData[i].season - 1] += 1;
      if (referenceData[i].idLine != "") {
        total[referenceData[i].season - 1] += 1;
      }
    }
    for (var i = 0; i < totalRefs.length; i++) {
      totalPercent[i] = total[i] / totalRefs[i];
    }
    return totalPercent;
  }

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final Map<String, Map<String, List<String>>> data = csvData.mapData;
    final total = countProgress(csvData.referenceData);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                mainAxisExtent: 120,
              ),
              itemCount: data.keys.length,
              itemBuilder: (context, index) {
                Map<String, List<String>>? episodesData =
                    data[data.keys.elementAt(index)];
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Material(
                    child: ListTile(
                      title: Stack(
                        children: [
                          Center(
                            child: Text(
                              "Season ${data.keys.elementAt(index)}",
                              style: const TextStyle(
                                fontFamily: 'PsychFont',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Text(
                              "${double.parse((total[index] * 100).toStringAsFixed(1))}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          width: 2,
                          color: Colors.green,
                        ),
                      ),
                      tileColor: Colors.green,
                      contentPadding: const EdgeInsets.all(10),
                      onTap: () {
                        if (episodesData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EpisodesRoute(
                                episodesData,
                                data.keys.elementAt(index),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const Center(
            child: Text(
              "This section is still a work in progress.\nI'm updating it in every new version!",
              style: TextStyle(
                fontFamily: "PsychFont",
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class EpisodesRoute extends StatelessWidget {
  final Map<String, List<String>> data;
  final String season;
  const EpisodesRoute(this.data, this.season, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Episodes',
              style: TextStyle(
                fontSize: 25,
                color: Colors.green,
                fontFamily: 'PsychFont',
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "Season $season",
              style: const TextStyle(
                fontFamily: 'PsychFont',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: data.keys.length,
        itemBuilder: (context, index) {
          String episodesKey = data.keys.elementAt(index);
          List<String> referencesData = data[episodesKey]!;
          return Padding(
            padding: const EdgeInsets.all(5),
            child: Material(
              child: ListTile(
                title: Text(episodesKey,
                    style: const TextStyle(
                      fontFamily: '',
                    )),
                subtitle: Text(
                  "References: ${referencesData.length}",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                contentPadding: const EdgeInsets.all(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReferencesRoute(
                        season,
                        data.keys.elementAt(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReferencesRoute extends StatefulWidget {
  final String season;
  final String episode;
  const ReferencesRoute(this.season, this.episode, {Key? key})
      : super(key: key);

  @override
  State<ReferencesRoute> createState() => _ReferencesRouteState();
}

class _ReferencesRouteState extends State<ReferencesRoute> {
  late final Future sortByInit;
  late bool sortByAlphabetical;
  late bool firstLoad;
  late final String episodeNumber;

  @override
  void initState() {
    episodeNumber = extractNumberBeforeHyphen(widget.episode);
    sortByInit = loadSort();
    firstLoad = true;
    super.initState();
  }

  String extractNumberBeforeHyphen(String input) {
    final pattern = RegExp(r'^\d{1,2}\s-\s');
    final match = pattern.firstMatch(input);
    if (match != null) {
      return match.group(0)!.replaceAll(' - ', '');
    }
    return '';
  }

  Future<bool> loadSort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("sortRef") ?? true;
  }

  Future<void> saveSort(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("sortRef", value);
  }

  List referenceList(List referenceData) {
    List references = [];
    for (var i = 0; i < referenceData.length; i++) {
      if (referenceData[i].season == int.parse(widget.season) &&
          referenceData[i].episode == int.parse(episodeNumber)) {
        references.add(referenceData[i]);
      }
    }
    return references;
  }

  List currentReference(int index, List references) {
    final splitted =
        references[index].idLine.replaceAll('\r', '').trim().split(',');
    List<String> referenceSelected = [];
    for (var j = 0; j < splitted.length; j++) {
      if (splitted.first != "") {
        referenceSelected.add(splitted[j]);
      }
    }
    return referenceSelected;
  }

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final List referenceData = csvData.referenceData;
    final List dataList = csvData.data;
    final references = referenceList(referenceData);
    return FutureBuilder<dynamic>(
      future: sortByInit,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (firstLoad) {
            sortByAlphabetical = snapshot.data;
            firstLoad = false;
          }
          sortByAlphabetical == true
              ? references.sort((a, b) => a.reference.compareTo(b.reference))
              : references.sort((a, b) => a.idLine.compareTo(b.idLine));
          return WillPopScope(
            onWillPop: () async {
              saveSort(sortByAlphabetical);
              Navigator.pop(context);
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    const Text(
                      'References',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.green,
                        fontFamily: 'PsychFont',
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Season ${widget.season}, Episode $episodeNumber",
                      style: const TextStyle(
                        fontFamily: 'PsychFont',
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(Icons.sort_rounded),
                          onPressed: () {
                            setState(() {
                              sortByAlphabetical == true
                                  ? sortByAlphabetical = false
                                  : sortByAlphabetical = true;
                            });
                            // saveSort(sortBy);
                          },
                        ),
                        Positioned(
                          right: 6,
                          bottom: 2,
                          child: sortByAlphabetical == true
                              ? const Icon(Icons.sort_by_alpha_rounded,
                                  size: 14)
                              : const Icon(Icons.schedule_rounded, size: 14),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              body: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: references.length,
                itemBuilder: (context, index) {
                  final referenceSelected = currentReference(index, references);
                  final hasReference = referenceSelected.isNotEmpty;
                  final String titleText =
                      references[index].reference.split("(").first.trim();
                  final String subtitleText = references[index]
                      .reference
                      .split("(")
                      .last
                      .replaceAll(')', '')
                      .trim();
                  final hasVideo = references[index].link != "";
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Material(
                      child: ListTile(
                        title: Text(titleText),
                        subtitle: Text(subtitleText),
                        trailing: Stack(
                          children: [
                            if (hasReference)
                              const Icon(Icons.question_mark_rounded,
                                  color: Colors.green)
                            else
                              const SizedBox(),
                            if (hasVideo)
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
                        onTap: () {
                          if (hasReference) {
                            EpisodeUtil.fullEpisode(
                              dataList,
                              dataList[int.parse(referenceSelected.first)],
                            );
                            showModalBottomSheet(
                              context: context,
                              enableDrag: false,
                              builder: (BuildContext context) {
                                return BottomSheetEpisode(
                                  indexLine: EpisodeUtil.index,
                                  fullEpisode: EpisodeUtil.full,
                                  referencesList: referenceSelected,
                                );
                              },
                            );
                          }
                        },
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
