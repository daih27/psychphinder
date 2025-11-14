import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:psychphinder/widgets/bottomsheet/episode_header.dart';
import 'package:psychphinder/widgets/bottomsheet/episode_list_item.dart';
import 'package:psychphinder/widgets/bottomsheet/highlighted_episode_item.dart';
import 'package:psychphinder/widgets/bottomsheet/action_buttons.dart';
import 'package:psychphinder/widgets/bottomsheet/share_dialog.dart';
import 'package:psychphinder/widgets/bottomsheet/reference_dialog.dart';

class BottomSheetEpisode extends StatefulWidget {
  const BottomSheetEpisode({
    super.key,
    required this.indexLine,
    required this.fullEpisode,
    this.referenceId = "",
  });

  final int indexLine;
  final List fullEpisode;
  final String referenceId;

  @override
  State<BottomSheetEpisode> createState() => _BottomSheetEpisodeState();
}

class _BottomSheetEpisodeState extends State<BottomSheetEpisode> {
  int currentRef = 0;
  late int newId = widget.indexLine;
  Future<Map<String, dynamic>>? _calculationFuture;
  List<Reference> referenceSelected = [];
  List<int> episodeReferenceId = [];
  List<bool> episodeReferenceHasVideo = [];
  late FlutterListViewController _controller;

  List<Phrase> referencePhrases = [];
  int currentRefIndex = 0;

  void _initializeReferences() {
    if (widget.referenceId.isNotEmpty) {
      referencePhrases = widget.fullEpisode
          .cast<Phrase>()
          .where((phrase) =>
              phrase.reference?.split(',').contains(widget.referenceId) ??
              false)
          .toList();

      currentRefIndex = referencePhrases
          .indexWhere((phrase) => phrase.sequenceInEpisode == widget.indexLine);

      if (currentRefIndex == -1) currentRefIndex = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> calculateReferenceList(
      List referenceData) async {
    final Map<String, dynamic> input = {
      'referenceData': referenceData,
      'fullEpisode': widget.fullEpisode,
    };
    final Map<String, dynamic> result = await compute(referenceList, input);
    return result;
  }

  int findIndex(List fullEpisode, int referenceId) {
    int index = 0;
    for (var i = 0; i < fullEpisode.length; i++) {
      if (fullEpisode[i].id == referenceId) {
        index = i;
        return index;
      }
    }
    return index;
  }

  List<int> findIndex2(int index, List referencesListIndex) {
    List<int> index2 = [];
    for (var i = 0; i < referencesListIndex.length; i++) {
      if (referencesListIndex[i] == index) {
        index2.add(i);
      }
    }
    return index2;
  }

  bool searchHasVideo(List<int> indexes, List episodeReferenceHasVideo) {
    for (var i = 0; i < indexes.length; i++) {
      if (episodeReferenceHasVideo[indexes[i]]) {
        return true;
      }
    }
    return false;
  }

  List<Reference> selectReference(
    int index,
    List<Reference> selectedReference,
    List<int> episodeReferenceId,
  ) {
    Map<String, Reference> uniqueReferences = {};
    for (var i = 0; i < selectedReference.length; i++) {
      if (episodeReferenceId[i] == index) {
        uniqueReferences[selectedReference[i].id] = selectedReference[i];
      }
    }
    return uniqueReferences.values.toList();
  }

  @override
  void initState() {
    super.initState();

    _controller = FlutterListViewController();
    _initializeReferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.indexLine < widget.fullEpisode.length) {
        _controller.sliverController.jumpToIndex(widget.indexLine);
      }
    });
  }

  List findReferences(List referenceData) {
    Reference reference = Reference(
      season: 0,
      episode: 0,
      name: "",
      reference: "",
      id: "",
      idLine: "",
      link: "",
    );
    for (var i = 0; i < referenceData.length; i++) {
      if (referenceData[i].id == widget.referenceId) {
        reference = referenceData[i];
      }
    }
    final splitted = reference.idLine.replaceAll('\r', '').trim().split(',');
    List<String> references = [];
    for (var j = 0; j < splitted.length; j++) {
      if (splitted.first != "") {
        references.add(splitted[j]);
      }
    }
    return references;
  }

  Future<Map<String, dynamic>> _calculateReferenceListFromDatabase(
      DatabaseService databaseService) async {
    final allReferences = await databaseService.getReferences();
    return await calculateReferenceList(allReferences);
  }

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService>(context);
    final searchEngineProvider = Provider.of<SearchEngineProvider>(context);
    _calculationFuture ??= _calculateReferenceListFromDatabase(databaseService);
    return FutureBuilder(
      future: _calculationFuture,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final List referencesList = snapshot.data!['referencesList'] ?? [];
          referenceSelected = snapshot.data!['referenceSelected'];
          episodeReferenceId = snapshot.data!['episodeReferenceId'];
          episodeReferenceHasVideo = snapshot.data!['episodeReferenceHasVideo'];
          return ValueListenableBuilder(
            valueListenable: Hive.box("favorites").listenable(),
            builder: (BuildContext context, dynamic box, Widget? child) {
              final isFavorite = box.get(widget.fullEpisode[newId].id) != null;
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    EpisodeHeader(
                      phrase: widget.fullEpisode[newId],
                      referencePhraseCount: referencePhrases.length,
                      currentRefIndex: currentRefIndex,
                      onPreviousReference: () {
                        currentRefIndex--;
                        var phrase = referencePhrases[currentRefIndex];
                        setState(() {
                          newId = phrase.sequenceInEpisode;
                        });
                        if (mounted) {
                          _controller.sliverController.jumpToIndex(newId);
                        }
                      },
                      onNextReference: () {
                        currentRefIndex++;
                        var phrase = referencePhrases[currentRefIndex];
                        setState(() {
                          newId = phrase.sequenceInEpisode;
                        });
                        if (mounted) {
                          _controller.sliverController.jumpToIndex(newId);
                        }
                      },
                    ),
                    Expanded(
                      child: FlutterListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _controller,
                        delegate: FlutterListViewDelegate(
                          (BuildContext context, int index) {
                            final phrase = widget.fullEpisode[index];
                            final isFavorite = box.get(phrase.id) != null;
                            final hasReference =
                                phrase.reference?.contains("s") ?? false;
                            final hasVideo = searchHasVideo(
                                findIndex2(index, episodeReferenceId),
                                episodeReferenceHasVideo);

                            if (newId == index) {
                              return HighlightedEpisodeItem(
                                phrase: phrase,
                                isFavorite: isFavorite,
                                hasReference: hasReference,
                                hasVideo: hasVideo,
                                onTap: hasReference
                                    ? () {
                                        ReferenceDialog.show(
                                          context,
                                          selectReference(index,
                                              referenceSelected, episodeReferenceId),
                                          searchEngineProvider,
                                        );
                                      }
                                    : null,
                              );
                            } else {
                              return EpisodeListItem(
                                phrase: phrase,
                                isFavorite: isFavorite,
                                hasReference: hasReference,
                                hasVideo: hasVideo,
                                referenceId: widget.referenceId,
                                onTap: () {
                                  setState(() {
                                    newId = index;
                                  });
                                  final targetPhrase = phrase;
                                  if (widget.referenceId.isNotEmpty &&
                                      targetPhrase.reference
                                              ?.contains(widget.referenceId) ==
                                          true) {
                                    context.pushReplacement(
                                      '/s${targetPhrase.season}/e${targetPhrase.episode}/p${targetPhrase.sequenceInEpisode}/r${widget.referenceId}',
                                    );
                                  } else {
                                    context.pushReplacement(
                                      '/s${targetPhrase.season}/e${targetPhrase.episode}/p${targetPhrase.sequenceInEpisode}',
                                    );
                                  }
                                },
                              );
                            }
                          },
                          childCount: widget.fullEpisode.length,
                          initIndex: widget.indexLine - 3,
                        ),
                      ),
                    ),
                    ActionButtonsBar(
                      isFavorite: isFavorite,
                      onWallpaperPressed: () {
                        if (referencesList.isEmpty) {
                          context
                              .go('/${widget.fullEpisode[newId].id}/wallpaper');
                        } else {
                          context.go(
                            '/s${widget.fullEpisode[newId].season}/e${widget.fullEpisode[newId].episode}/p${widget.fullEpisode[newId].sequenceInEpisode}/r${widget.referenceId}/wallpaper',
                          );
                        }
                      },
                      onFavoritePressed: () async {
                        if (!isFavorite) {
                          await box.put(widget.fullEpisode[newId].id,
                              widget.fullEpisode[newId].id);
                        } else {
                          await box.delete(widget.fullEpisode[newId].id);
                        }
                      },
                      onSharePressed: () {
                        ShareDialog.show(
                          context,
                          widget.fullEpisode[newId],
                          widget.referenceId,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

}

Future<Map<String, dynamic>> referenceList(Map<String, dynamic> input) async {
  List<dynamic> referenceData = input['referenceData'];
  List<dynamic> fullEpisode = input['fullEpisode'];
  List<Reference> referenceSelected = [];
  List<int> episodeReferenceId = [];
  List<bool> episodeReferenceHasVideo = [];
  int season = fullEpisode[0].season;
  int episode = fullEpisode[0].episode;
  int seasonReference;
  int episodeReference;

  for (var i = 0; i < fullEpisode.length; i++) {
    final idPhrase =
        fullEpisode[i].reference?.replaceAll('\r', '').trim() ?? '';
    final splitted = idPhrase.split(',');
    for (var k = 0; k < referenceData.length; k++) {
      seasonReference = referenceData[k].season;
      episodeReference = referenceData[k].episode;
      if (season == seasonReference && episode == episodeReference) {
        for (var j = 0; j < splitted.length; j++) {
          if (referenceData[k].id == splitted[j]) {
            referenceSelected.add(referenceData[k]);
            episodeReferenceId.add(i);
            if (referenceData[k].link.contains("youtu.be")) {
              episodeReferenceHasVideo.add(true);
            } else {
              episodeReferenceHasVideo.add(false);
            }
          }
        }
      }
    }
  }
  return {
    'referenceSelected': referenceSelected,
    'episodeReferenceId': episodeReferenceId,
    'episodeReferenceHasVideo': episodeReferenceHasVideo,
  };
}
