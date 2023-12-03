import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'package:psychphinder/main.dart';
import 'package:psychphinder/global/globals.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
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
    List<Reference> selected = [];
    for (var i = 0; i < selectedReference.length; i++) {
      if (episodeReferenceId[i] == index) {
        selected.add(selectedReference[i]);
      }
    }
    return selected;
  }

  FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    FToast fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
  }

  _showToast(String text) {
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

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final searchEngineProvider = Provider.of<SearchEngineProvider>(context);
    final List referenceData = csvData.referenceData;
    final List referencesList =
        widget.referenceId != "" ? findReferences(referenceData) : [];
    _calculationFuture ??= calculateReferenceList(referenceData);
    FlutterListViewController controller = FlutterListViewController();
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
          referenceSelected = snapshot.data!['referenceSelected'];
          episodeReferenceId = snapshot.data!['episodeReferenceId'];
          episodeReferenceHasVideo = snapshot.data!['episodeReferenceHasVideo'];
          return ValueListenableBuilder(
            valueListenable: Hive.box("favorites").listenable(),
            builder: (BuildContext context, dynamic box, Widget? child) {
              final isFavorite = box.get(widget.fullEpisode[newId].id) != null;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        referencesList.length > 19
                            ? Expanded(flex: 1, child: Container())
                            : const SizedBox(width: 0),
                        Expanded(
                          flex: 8,
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  widget.fullEpisode[newId].name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'PsychFont',
                                    color: Colors.green,
                                  ),
                                ),
                                if (widget.fullEpisode[newId].season != 0)
                                  Text(
                                    "Season ${widget.fullEpisode[newId].season}, Episode ${widget.fullEpisode[newId].episode}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 15, fontFamily: 'PsychFont'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        referencesList.length > 1
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_circle_left,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      if (currentRef > 0) {
                                        int referenceId = findIndex(
                                            widget.fullEpisode,
                                            int.parse(referencesList[
                                                currentRef - 1]));
                                        if (referenceId >= 3) {
                                          controller.sliverController
                                              .animateToIndex(referenceId - 3,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.ease);
                                        } else {
                                          controller.sliverController
                                              .animateToIndex(referenceId,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.ease);
                                        }
                                        currentRef--;
                                        newId = referenceId;
                                        context.go(
                                          '/references/season${widget.fullEpisode[newId].season}/episode${widget.fullEpisode[newId].episode}/${widget.referenceId}/${widget.fullEpisode[newId].id}',
                                        );
                                        setState(
                                          () {
                                            currentRef;
                                            newId;
                                          },
                                        );
                                      }
                                    },
                                  ),
                                  Text(
                                    "${currentRef + 1}/${referencesList.length}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_circle_right,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      if (currentRef <
                                          referencesList.length - 1) {
                                        int referenceId = findIndex(
                                          widget.fullEpisode,
                                          int.parse(
                                              referencesList[currentRef + 1]),
                                        );
                                        if (referenceId >= 3) {
                                          controller.sliverController
                                              .animateToIndex(referenceId - 3,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.ease);
                                        } else {
                                          controller.sliverController
                                              .animateToIndex(referenceId,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.ease);
                                        }
                                        currentRef++;
                                        newId = referenceId;
                                        context.go(
                                          '/references/season${widget.fullEpisode[newId].season}/episode${widget.fullEpisode[newId].episode}/${widget.referenceId}/${widget.fullEpisode[newId].id}',
                                        );
                                        setState(() {
                                          currentRef;
                                          newId;
                                        });
                                      }
                                    },
                                  )
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FlutterListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controller,
                      delegate: FlutterListViewDelegate(
                        (BuildContext context, int index) {
                          bool isFavorite =
                              box.get(widget.fullEpisode[newId].id) != null;
                          bool hasReference =
                              widget.fullEpisode[newId].reference.contains("s");
                          if (newId == index) {
                            bool hasVideo = searchHasVideo(
                                findIndex2(index, episodeReferenceId),
                                episodeReferenceHasVideo);
                            return ListTile(
                              title: Text(
                                "${widget.fullEpisode[index].time[0] == '0' ? widget.fullEpisode[index].time.substring(2) : widget.fullEpisode[index].time}   ${widget.fullEpisode[index].line}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isFavorite
                                      ? const Icon(Icons.favorite_rounded,
                                          color: Colors.green)
                                      : const SizedBox(),
                                  hasReference
                                      ? Stack(children: [
                                          referenceButton(
                                            referenceData,
                                            context,
                                            true,
                                            searchEngineProvider,
                                            selectReference(
                                                index,
                                                referenceSelected,
                                                episodeReferenceId),
                                          ),
                                          hasVideo
                                              ? const Positioned(
                                                  right: 6,
                                                  bottom: 6,
                                                  child: Icon(
                                                      FontAwesomeIcons.youtube,
                                                      color: Colors.green,
                                                      size: 10),
                                                )
                                              : const SizedBox(),
                                        ])
                                      : const SizedBox(),
                                ],
                              ),
                            );
                          } else {
                            hasReference = widget.fullEpisode[index].reference
                                .contains("s");
                            isFavorite =
                                box.get(widget.fullEpisode[index].id) != null;
                            bool hasVideo = searchHasVideo(
                                findIndex2(index, episodeReferenceId),
                                episodeReferenceHasVideo);
                            return ListTile(
                              onTap: () {
                                newId = index;
                                if (referencesList.isEmpty) {
                                  context
                                      .go('/${widget.fullEpisode[newId].id}');
                                } else {
                                  context.go(
                                    '/references/season${widget.fullEpisode[newId].season}/episode${widget.fullEpisode[newId].episode}/${widget.referenceId}/${widget.fullEpisode[newId].id}',
                                  );
                                }
                                setState(() {
                                  newId;
                                });
                              },
                              title: Text(
                                "${widget.fullEpisode[index].time[0] == '0' ? widget.fullEpisode[index].time.substring(2) : widget.fullEpisode[index].time}   ${widget.fullEpisode[index].line}",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isFavorite
                                      ? const Icon(Icons.favorite_rounded)
                                      : const SizedBox(),
                                  hasReference
                                      ? Stack(children: [
                                          referenceButton(
                                            referenceData,
                                            context,
                                            false,
                                            searchEngineProvider,
                                            selectReference(
                                                index,
                                                referenceSelected,
                                                episodeReferenceId),
                                          ),
                                          hasVideo
                                              ? const Positioned(
                                                  right: 6,
                                                  bottom: 6,
                                                  child: Icon(
                                                      FontAwesomeIcons.youtube,
                                                      size: 10),
                                                )
                                              : const SizedBox(),
                                        ])
                                      : const SizedBox(),
                                ],
                              ),
                            );
                          }
                        },
                        childCount: widget.fullEpisode.length,
                        initIndex: widget.indexLine - 3,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image_rounded),
                        onPressed: () {
                          if (referencesList.isEmpty) {
                            context.go(
                                '/${widget.fullEpisode[newId].id}/wallpaper');
                          } else {
                            context.go(
                              '/references/season${widget.fullEpisode[newId].season}/episode${widget.fullEpisode[newId].episode}/${widget.referenceId}/${widget.fullEpisode[newId].id}/wallpaper',
                            );
                          }
                        },
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          if (!isFavorite) {
                            await box.put(widget.fullEpisode[newId].id,
                                widget.fullEpisode[newId].id);
                          } else {
                            await box.delete(widget.fullEpisode[newId].id);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.green,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                isFavorite
                                    ? 'Remove from favorites'
                                    : 'Add to favorites',
                                style: const TextStyle(
                                  color: Colors.white,
                                )),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.favorite,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              backgroundColor: Colors.green,
                              title: const Center(
                                child: Text(
                                  'Share',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'PsychFont',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final String link =
                                          "https://daih27.github.io/psychphinder/#/${widget.fullEpisode[newId].id}";
                                      if (!kIsWeb) {
                                        if (Platform.isAndroid) {
                                          final result =
                                              await Share.shareWithResult(
                                            link,
                                          );
                                          if (result.status ==
                                              ShareResultStatus.success) {
                                            _showToast("Shared link!");
                                          }
                                        } else {
                                          await Clipboard.setData(
                                            ClipboardData(text: link),
                                          );
                                          _showToast(
                                              "Copied link to clipboard!");
                                        }
                                      } else {
                                        await Clipboard.setData(
                                          ClipboardData(text: link),
                                        );
                                        _showToast("Copied link to clipboard!");
                                      }
                                    },
                                    child: const Text(
                                      "Link",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (!kIsWeb) {
                                        if (Platform.isAndroid) {
                                          final result =
                                              await Share.shareWithResult(
                                            widget.fullEpisode[newId].line,
                                          );
                                          if (result.status ==
                                              ShareResultStatus.success) {
                                            _showToast("Shared text!");
                                          }
                                        } else {
                                          await Clipboard.setData(
                                            ClipboardData(
                                                text: widget
                                                    .fullEpisode[newId].line),
                                          );
                                          _showToast(
                                              "Copied text to clipboard!");
                                        }
                                      } else {
                                        await Clipboard.setData(
                                          ClipboardData(
                                              text: widget
                                                  .fullEpisode[newId].line),
                                        );
                                        _showToast("Copied text to clipboard!");
                                      }
                                    },
                                    child: const Text(
                                      "Text",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (referencesList.isEmpty) {
                                        context.go(
                                            '/${widget.fullEpisode[newId].id}/shareimage');
                                      } else {
                                        context.go(
                                          '/references/season${widget.fullEpisode[newId].season}/episode${widget.fullEpisode[newId].episode}/${widget.referenceId}/${widget.fullEpisode[newId].id}/shareimage',
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "Image",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ],
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
    final idPhrase = fullEpisode[i].reference.replaceAll('\r', '').trim();
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
