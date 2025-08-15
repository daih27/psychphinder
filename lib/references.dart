import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReferencesPage extends StatelessWidget {
  const ReferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService>(context);

    return FutureBuilder<List<int>>(
      future: databaseService.getSeasons(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final seasons = snapshot.data ?? [];

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
                  itemCount: seasons.length,
                  itemBuilder: (context, index) {
                    final seasonNum = seasons[index];

                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: Material(
                        child: ListTile(
                          title: Center(
                            child: Text(
                              seasonNum == 999 ? 'Movies' : "Season $seasonNum",
                              style: const TextStyle(
                                fontFamily: 'PsychFont',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
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
                            context.go('/references/season$seasonNum');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EpisodesRoute extends StatelessWidget {
  final Map<String, List<String>> data;
  final String season;
  const EpisodesRoute(this.data, this.season, {super.key});

  String extractNumberBeforeHyphen(String input) {
    final pattern = RegExp(r'^\d{1,2}\s-\s');
    final match = pattern.firstMatch(input);
    if (match != null) {
      return match.group(0)!.replaceAll(' - ', '');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService>(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: databaseService.getEpisodesForSeason(int.parse(season)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final episodes = snapshot.data ?? [];

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
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              final episodesKey = "${episode['episode']} - ${episode['name']}";

              return FutureBuilder<int>(
                future: databaseService.getReferences().then((refs) {
                  // Get unique reference IDs for this episode
                  Set<String> uniqueRefIds = refs
                      .where((ref) =>
                          ref.season == int.parse(season) &&
                          ref.episode == episode['episode'])
                      .map((ref) => ref.id)
                      .toSet();
                  return uniqueRefIds.length;
                }),
                builder: (context, refCountSnapshot) {
                  final referencesCount = refCountSnapshot.data ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Material(
                      child: ListTile(
                        title: Text(episodesKey,
                            style: const TextStyle(
                              fontFamily: '',
                            )),
                        subtitle: Text(
                          "References: $referencesCount",
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                        onTap: () {
                          context.go(
                            '/references/season$season/episode${episode['episode']}',
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ReferencesRoute extends StatefulWidget {
  final String season;
  final String episodeNumber;
  const ReferencesRoute(this.season, this.episodeNumber, {super.key});

  @override
  State<ReferencesRoute> createState() => _ReferencesRouteState();
}

class _ReferencesRouteState extends State<ReferencesRoute>
    with AutomaticKeepAliveClientMixin<ReferencesRoute> {
  @override
  bool get wantKeepAlive => true;

  late final Future sortByInit;
  late bool sortByAlphabetical;
  late bool firstLoad;
  Future<Map<String, dynamic>>? _referencesDataFuture;

  @override
  void initState() {
    sortByInit = loadSort();
    firstLoad = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> loadSort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("sortRef") ?? true;
  }

  Future<void> saveSort(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("sortRef", value);
  }

  Future<Map<String, dynamic>> _loadReferencesData(
      DatabaseService databaseService) async {
    final sortInit = await loadSort();
    final allReferences = await databaseService.getReferences();

    // Use a Map to deduplicate references by ID
    Map<String, dynamic> uniqueReferences = {};
    for (var ref in allReferences) {
      if (ref.season == int.parse(widget.season) &&
          ref.episode == int.parse(widget.episodeNumber)) {
        uniqueReferences[ref.id] = ref;
      }
    }

    List references = uniqueReferences.values.toList();

    return {
      'sortInit': sortInit,
      'references': references,
    };
  }

  List referenceList(List referenceData) {
    List references = [];
    for (var i = 0; i < referenceData.length; i++) {
      if (referenceData[i].season == int.parse(widget.season) &&
          referenceData[i].episode == int.parse(widget.episodeNumber)) {
        references.add(referenceData[i]);
      }
    }
    return references;
  }

  Future<int> getFirstChronologicalOccurrence(
      String referenceId, DatabaseService databaseService) async {
    // Get all phrases for this episode
    final episodePhrases = await databaseService.getEpisodePhrases(
        int.parse(widget.season), int.parse(widget.episodeNumber));

    // Find phrases that contain this reference ID
    final phrasesWithReference = episodePhrases
        .where((phrase) => phrase.reference?.split(',').contains(referenceId) ?? false)
        .toList();

    if (phrasesWithReference.isEmpty) return 0;

    // Sort by sequence in episode and return the first one's phrase ID
    phrasesWithReference
        .sort((a, b) => a.sequenceInEpisode.compareTo(b.sequenceInEpisode));
    return phrasesWithReference.first.id;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var databaseService = Provider.of<DatabaseService>(context);
    _referencesDataFuture ??= _loadReferencesData(databaseService);

    return FutureBuilder<Map<String, dynamic>>(
      future: _referencesDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;
          final bool sortInit = data['sortInit'];
          final List references = data['references'];

          if (firstLoad) {
            sortByAlphabetical = sortInit;
            firstLoad = false;
          }
          sortByAlphabetical == true
              ? references.sort((a, b) => a.reference.compareTo(b.reference))
              : references.sort((a, b) => int.parse(a.idLine.split(',')[0])
                  .compareTo(int.parse(b.idLine.split(',')[0])));
          return PopScope(
            onPopInvokedWithResult: (bool didPop, Object? result) {
              saveSort(sortByAlphabetical);
              if (didPop) {
                return;
              }
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
                      widget.season == "999" 
                          ? "Movie"
                          : "Season ${widget.season}, Episode ${widget.episodeNumber}",
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
                            setState(
                              () {
                                sortByAlphabetical == true
                                    ? sortByAlphabetical = false
                                    : sortByAlphabetical = true;
                              },
                            );
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
                            const Icon(Icons.question_mark_rounded,
                                color: Colors.green),
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
                        onTap: () async {
                          final firstPhraseId =
                              await getFirstChronologicalOccurrence(
                                  references[index].id, databaseService);
                          if (!context.mounted) return;

                          final episodePhrases =
                              await databaseService.getEpisodePhrases(
                                  int.parse(widget.season),
                                  int.parse(widget.episodeNumber));
                          if (!context.mounted) return;

                          final targetPhrase = episodePhrases.firstWhere(
                              (phrase) => phrase.id == firstPhraseId);

                          final route =
                              '/s${targetPhrase.season}/e${targetPhrase.episode}/p${targetPhrase.sequenceInEpisode}/r${references[index].id}';
                          context.push(route);
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
