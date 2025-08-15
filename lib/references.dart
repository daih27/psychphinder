import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferencesPage extends StatelessWidget {
  const ReferencesPage({super.key});

  Future<List<int>> _getSeasonsWithReferences(
      DatabaseService databaseService) async {
    final allSeasons = await databaseService.getSeasons();
    final allReferences = await databaseService.getReferences();

    final hasMovieReferences = allReferences.any((ref) => ref.season == 999);

    return allSeasons.where((season) {
      if (season == 999) {
        return hasMovieReferences;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService>(context);

    return FutureBuilder<List<int>>(
      future: _getSeasonsWithReferences(databaseService),
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
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.green.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                context.go('/references/season$seasonNum');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      seasonNum == 999
                                          ? 'Movies'
                                          : "Season $seasonNum",
                                      style: const TextStyle(
                                        fontFamily: 'PsychFont',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        letterSpacing: -0.5,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
              final episodesKey = episode['name'];

              return FutureBuilder<int>(
                future: databaseService.getReferences().then((refs) {
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
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            context.go(
                              '/references/season$season/episode${episode['episode']}',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    episode['episode'].toString(),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        episodesKey,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    referencesCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Map<String, dynamic> _getReferenceTypeInfo(String referenceText) {
    final lowerText = referenceText.toLowerCase();

    if (lowerText.contains('movie') || lowerText.contains('film')) {
      return {'type': 'Movie', 'color': Colors.red, 'icon': Icons.movie};
    } else if (lowerText.contains('actor') || lowerText.contains('actress')) {
      return {'type': 'Actor', 'color': Colors.purple, 'icon': Icons.person};
    } else if (lowerText.contains('musician') ||
        lowerText.contains('singer') ||
        lowerText.contains('band')) {
      return {
        'type': 'Music',
        'color': Colors.orange,
        'icon': Icons.music_note
      };
    } else if (lowerText.contains('tv show') ||
        lowerText.contains('television')) {
      return {'type': 'TV Show', 'color': Colors.blue, 'icon': Icons.tv};
    } else if (lowerText.contains('book') ||
        lowerText.contains('novel') ||
        lowerText.contains('writer') ||
        lowerText.contains('author')) {
      return {'type': 'Literature', 'color': Colors.brown, 'icon': Icons.book};
    } else if (lowerText.contains('game') || lowerText.contains('sport')) {
      return {
        'type': 'Game/Sport',
        'color': Colors.green,
        'icon': Icons.sports
      };
    } else if (lowerText.contains('company') ||
        lowerText.contains('brand') ||
        lowerText.contains('store')) {
      return {'type': 'Brand', 'color': Colors.indigo, 'icon': Icons.business};
    } else if (lowerText.contains('song') || lowerText.contains('album')) {
      return {'type': 'Song', 'color': Colors.pink, 'icon': Icons.queue_music};
    } else if (lowerText.contains('character') ||
        lowerText.contains('fictional')) {
      return {'type': 'Character', 'color': Colors.teal, 'icon': Icons.face};
    } else {
      return {
        'type': 'Other',
        'color': Colors.grey,
        'icon': Icons.help_outline
      };
    }
  }

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
    final episodePhrases = await databaseService.getEpisodePhrases(
        int.parse(widget.season), int.parse(widget.episodeNumber));

    final phrasesWithReference = episodePhrases
        .where((phrase) =>
            phrase.reference?.split(',').contains(referenceId) ?? false)
        .toList();

    if (phrasesWithReference.isEmpty) return 0;

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
                  final referenceTypeInfo = _getReferenceTypeInfo(subtitleText);

                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: referenceTypeInfo['color']
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    referenceTypeInfo['icon'],
                                    color: referenceTypeInfo['color'],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              titleText,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: referenceTypeInfo['color'],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              referenceTypeInfo['type'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subtitleText,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (hasVideo)
                                            Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
