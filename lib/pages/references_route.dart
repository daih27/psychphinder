import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psychphinder/utils/reference_type_detector.dart';

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
                  final referenceTypeInfo =
                      ReferenceTypeDetector.getReferenceTypeInfo(subtitleText);

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
