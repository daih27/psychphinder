import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/main.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  FToast fToast = FToast();

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
    FToast fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
  }

  void _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Colors.white),
          const SizedBox(
            width: 12.0,
          ),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
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
          final List referenceData = snapshot.data!['referenceData'] ?? [];
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
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.fullEpisode[newId].name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PsychFont',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (widget.fullEpisode[newId].season != 0)
                                      Text(
                                        widget.fullEpisode[newId].season == 999
                                            ? "Movie"
                                            : "Season ${widget.fullEpisode[newId].season}, Episode ${widget.fullEpisode[newId].episode}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (referencePhrases.length > 1)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.chevron_left_rounded,
                                          color: currentRefIndex > 0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.3),
                                        ),
                                        onPressed: currentRefIndex > 0
                                            ? () {
                                                currentRefIndex--;
                                                var phrase = referencePhrases[
                                                    currentRefIndex];
                                                setState(() {
                                                  newId =
                                                      phrase.sequenceInEpisode;
                                                });
                                                if (mounted) {
                                                  _controller.sliverController
                                                      .jumpToIndex(newId);
                                                }
                                              }
                                            : null,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          "${currentRefIndex + 1}/${referencePhrases.length}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.chevron_right_rounded,
                                          color: currentRefIndex <
                                                  referencePhrases.length - 1
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.3),
                                        ),
                                        onPressed: currentRefIndex <
                                                referencePhrases.length - 1
                                            ? () {
                                                currentRefIndex++;
                                                var phrase = referencePhrases[
                                                    currentRefIndex];
                                                setState(() {
                                                  newId =
                                                      phrase.sequenceInEpisode;
                                                });
                                                if (mounted) {
                                                  _controller.sliverController
                                                      .jumpToIndex(newId);
                                                }
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FlutterListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _controller,
                        delegate: FlutterListViewDelegate(
                          (BuildContext context, int index) {
                            bool isFavorite =
                                box.get(widget.fullEpisode[index].id) != null;
                            bool hasReference = widget
                                    .fullEpisode[index].reference
                                    ?.contains("s") ??
                                false;
                            if (newId == index) {
                              bool hasVideo = searchHasVideo(
                                  findIndex2(index, episodeReferenceId),
                                  episodeReferenceHasVideo);
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                      Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: hasReference
                                        ? () {
                                            referenceButton(
                                              referenceData,
                                              context,
                                              true,
                                              searchEngineProvider,
                                              selectReference(
                                                  index,
                                                  referenceSelected,
                                                  episodeReferenceId),
                                            ).onPressed!();
                                          }
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              widget.fullEpisode[index]
                                                          .time[0] ==
                                                      '0'
                                                  ? widget
                                                      .fullEpisode[index].time
                                                      .substring(2)
                                                  : widget
                                                      .fullEpisode[index].time,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              widget.fullEpisode[index].line,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isFavorite)
                                                Icon(
                                                  Icons.favorite,
                                                  color: Colors.red.shade400,
                                                  size: 14,
                                                ),
                                              if (hasReference) ...[
                                                if (isFavorite)
                                                  const SizedBox(width: 6),
                                                Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Icon(
                                                      Icons.help_outline,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      size: 14,
                                                    ),
                                                    if (hasVideo)
                                                      Positioned(
                                                        right: -3,
                                                        top: -2,
                                                        child: Container(
                                                          width: 5,
                                                          height: 5,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              hasReference = widget.fullEpisode[index].reference
                                      ?.contains("s") ??
                                  false;
                              isFavorite =
                                  box.get(widget.fullEpisode[index].id) != null;
                              bool hasVideo = searchHasVideo(
                                  findIndex2(index, episodeReferenceId),
                                  episodeReferenceHasVideo);
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      setState(() {
                                        newId = index;
                                      });
                                      final targetPhrase =
                                          widget.fullEpisode[index];
                                      if (widget.referenceId.isNotEmpty &&
                                          targetPhrase.reference?.contains(
                                                  widget.referenceId) ==
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              widget.fullEpisode[index]
                                                          .time[0] ==
                                                      '0'
                                                  ? widget
                                                      .fullEpisode[index].time
                                                      .substring(2)
                                                  : widget
                                                      .fullEpisode[index].time,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.7),
                                                fontSize: 9,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              widget.fullEpisode[index].line,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.8),
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isFavorite)
                                                Icon(
                                                  Icons.favorite,
                                                  color: Colors.red.shade400,
                                                  size: 12,
                                                ),
                                              if (hasReference) ...[
                                                if (isFavorite)
                                                  const SizedBox(width: 6),
                                                Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Icon(
                                                      Icons.help_outline,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                              alpha: 0.5),
                                                      size: 12,
                                                    ),
                                                    if (hasVideo)
                                                      Positioned(
                                                        right: -2,
                                                        top: -1,
                                                        child: Container(
                                                          width: 4,
                                                          height: 4,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          childCount: widget.fullEpisode.length,
                          initIndex: widget.indexLine - 3,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _ActionButton(
                            icon: Icons.wallpaper_rounded,
                            label: 'Wallpaper',
                            onPressed: () {
                              if (referencesList.isEmpty) {
                                context.go(
                                    '/${widget.fullEpisode[newId].id}/wallpaper');
                              } else {
                                context.go(
                                  '/s${widget.fullEpisode[newId].season}/e${widget.fullEpisode[newId].episode}/p${widget.fullEpisode[newId].sequenceInEpisode}/r${widget.referenceId}/wallpaper',
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isFavorite
                                      ? [
                                          Colors.red.shade400,
                                          Colors.red.shade600
                                        ]
                                      : [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.8)
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isFavorite
                                            ? Colors.red
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    if (!isFavorite) {
                                      await box.put(
                                          widget.fullEpisode[newId].id,
                                          widget.fullEpisode[newId].id);
                                    } else {
                                      await box
                                          .delete(widget.fullEpisode[newId].id);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isFavorite
                                              ? 'Remove'
                                              : 'Add to favorites',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            onPressed: () =>
                                _showModernShareDialog(context, referencesList),
                          ),
                        ],
                      ),
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

  IconButton referenceButton(
      List<dynamic> referenceData,
      BuildContext context,
      bool isSelected,
      SearchEngineProvider searchEngineProvider,
      List<Reference> selectedReference) {
    return IconButton(
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: Colors.green,
            title: const Text(
              'This is a reference to',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PsychFont',
                  fontWeight: FontWeight.bold),
            ),
            content: selectedReference.length > 1
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < selectedReference.length; i++) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedReference[i].reference,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final url = Uri.parse(
                                    '${searchEngineProvider.currentSearchEngine}${selectedReference[i].reference.replaceAll("&", "%26")}');
                                launchUrl(
                                  url,
                                  mode: searchEngineProvider.openLinks
                                      ? LaunchMode.inAppWebView
                                      : LaunchMode.externalApplication,
                                );
                              },
                              icon:
                                  const Icon(Icons.search, color: Colors.white),
                            ),
                            for (var j = 0;
                                j < selectedReference[i].link.split(",").length;
                                j++)
                              selectedReference[i].link != ""
                                  ? IconButton(
                                      onPressed: () {
                                        final url = Uri.parse(
                                            selectedReference[i]
                                                .link
                                                .split(",")[j]);
                                        launchUrl(
                                          url,
                                          mode: searchEngineProvider.openLinks
                                              ? LaunchMode.inAppWebView
                                              : LaunchMode.externalApplication,
                                        );
                                      },
                                      icon: selectedReference[i]
                                              .link
                                              .split(",")[j]
                                              .contains("youtu.be")
                                          ? const FaIcon(
                                              FontAwesomeIcons.youtube,
                                              color: Colors.white)
                                          : selectedReference[i]
                                                  .link
                                                  .split(",")[j]
                                                  .contains("imdb.com")
                                              ? const FaIcon(
                                                  FontAwesomeIcons.imdb,
                                                  color: Colors.white)
                                              : Container())
                                  : const SizedBox()
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedReference.first.reference,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final url = Uri.parse(
                              '${searchEngineProvider.currentSearchEngine}${selectedReference.first.reference.replaceAll("&", "%26")}');
                          launchUrl(
                            url,
                            mode: searchEngineProvider.openLinks
                                ? LaunchMode.inAppWebView
                                : LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),
                      for (var j = 0;
                          j < selectedReference.first.link.split(",").length;
                          j++)
                        selectedReference.first.link != ""
                            ? IconButton(
                                onPressed: () {
                                  final url = Uri.parse(selectedReference
                                      .first.link
                                      .split(",")[j]);
                                  launchUrl(
                                    url,
                                    mode: searchEngineProvider.openLinks
                                        ? LaunchMode.inAppWebView
                                        : LaunchMode.externalApplication,
                                  );
                                },
                                icon: selectedReference.first.link
                                        .split(",")[j]
                                        .contains("youtu.be")
                                    ? const FaIcon(FontAwesomeIcons.youtube,
                                        color: Colors.white)
                                    : selectedReference.first.link
                                            .split(",")[j]
                                            .contains("imdb.com")
                                        ? const FaIcon(FontAwesomeIcons.imdb,
                                            color: Colors.white)
                                        : Container())
                            : const SizedBox()
                    ],
                  ),
          ),
        );
      },
      icon: const Icon(Icons.question_mark_rounded),
      color: isSelected ? Colors.green : null,
    );
  }

  Widget _ActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModernShareDialog(BuildContext context, List referencesList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
            const SizedBox(height: 24),
            Text(
              'Share Quote',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ShareOption(
                    icon: Icons.link_rounded,
                    label: 'Link',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () async {
                      Navigator.pop(context);
                      final String link =
                          "https://daih27.github.io/psychphinder/#/${widget.fullEpisode[newId].id}";
                      await Clipboard.setData(ClipboardData(text: link));
                      _showToast("Copied link to clipboard!");
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ShareOption(
                    icon: Icons.text_fields_rounded,
                    label: 'Text',
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () async {
                      Navigator.pop(context);
                      await Clipboard.setData(
                          ClipboardData(text: widget.fullEpisode[newId].line));
                      _showToast("Copied text to clipboard!");
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ShareOption(
                    icon: Icons.image_rounded,
                    label: 'Image',
                    color: Theme.of(context).colorScheme.tertiary,
                    onTap: () {
                      Navigator.pop(context);
                      if (referencesList.isEmpty) {
                        context
                            .go('/${widget.fullEpisode[newId].id}/shareimage');
                      } else {
                        context.go(
                          '/s${widget.fullEpisode[newId].season}/e${widget.fullEpisode[newId].episode}/p${widget.fullEpisode[newId].sequenceInEpisode}/r${widget.referenceId}/shareimage',
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _ShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
