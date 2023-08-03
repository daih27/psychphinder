import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/full_episode.dart';
import 'package:psychphinder/global/globals.dart';
import 'package:psychphinder/widgets/bottomsheet.dart';

class ReferencesPage extends StatelessWidget {
  const ReferencesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final Map<String, Map<String, List<String>>> data = csvData.mapData;
    return Scaffold(
      body: GridView.builder(
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
                title: Center(
                    child: Text("Season ${data.keys.elementAt(index)}",
                        style: const TextStyle(
                          fontFamily: 'PsychFont',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ))),
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
        title: const Text(
          'Episodes',
          style: TextStyle(
            fontSize: 25,
            color: Colors.green,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
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
                        referencesData,
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

class ReferencesRoute extends StatelessWidget {
  final List<String> data;
  final String season;
  final String episode;
  const ReferencesRoute(this.data, this.season, this.episode, {Key? key})
      : super(key: key);

  List<String> currentReference(
      List referenceData, String reference, String season, String episode) {
    List<String> referenceSelected = [];

    String extractNumberBeforeHyphen(String input) {
      final pattern = RegExp(r'^\d{1,2}\s-\s');
      final match = pattern.firstMatch(input);
      if (match != null) {
        return match.group(0)!.replaceAll(' - ', '');
      }
      return '';
    }

    for (var i = 0; i < referenceData.length; i++) {
      final data = referenceData[i].reference.replaceAll('\r', '').trim();
      final referenceClean = reference.replaceAll('\r', '').trim();
      final idClean = referenceData[i].idLine.replaceAll('\r', '').trim();
      final splitted = idClean.split(',');
      final episodeNumber = extractNumberBeforeHyphen(episode);

      // final epsiodeClean = referenceData[i].episode.replaceAll('\r', '').trim();
      for (var j = 0; j < splitted.length; j++) {
        if (data == referenceClean &&
            referenceData[i].episode == int.parse(episodeNumber) &&
            referenceData[i].season == int.parse(season) &&
            splitted.first != "") {
          referenceSelected.add(splitted[j]);
        }
      }
    }
    return referenceSelected;
  }

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final List referenceData = csvData.referenceData;
    final List dataList = csvData.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'References',
          style: TextStyle(
            fontSize: 25,
            color: Colors.green,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final referenceSelected =
              currentReference(referenceData, data[index], season, episode);
          final hasReference = referenceSelected.isNotEmpty;
          return Padding(
            padding: const EdgeInsets.all(5),
            child: Material(
              child: ListTile(
                title: Text(data[index]),
                trailing: hasReference
                    ? const Icon(Icons.question_mark_rounded,
                        color: Colors.green)
                    : null,
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
    );
  }
}
