import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/main.dart';
import 'package:psychphinder/global/globals.dart';
import 'package:psychphinder/global/search_engine.dart';
import 'package:psychphinder/widgets/create_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BottomSheetEpisode extends StatefulWidget {
  const BottomSheetEpisode({
    super.key,
    required this.indexLine,
    required this.fullEpisode,
    required this.referencesList,
  });

  final int indexLine;
  final List fullEpisode;
  final List referencesList;

  @override
  State<BottomSheetEpisode> createState() => _BottomSheetEpisodeState();
}

class _BottomSheetEpisodeState extends State<BottomSheetEpisode> {
  int currentRef = 0;
  late int newId = widget.indexLine;
  List<String> referenceSearch(List referenceData, int index) {
    List<String> referenceSelected = [];
    for (var i = 0; i < referenceData.length; i++) {
      final id = referenceData[i].id.replaceAll('\r', '').trim();
      final idPhrase =
          widget.fullEpisode[index].reference.replaceAll('\r', '').trim();
      final splitted = idPhrase.split(',');
      for (var j = 0; j < splitted.length; j++) {
        if (id == splitted[j]) {
          referenceSelected.add(referenceData[i].reference);
        }
      }
    }
    return referenceSelected;
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

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final searchEngineProvider = Provider.of<SearchEngineProvider>(context);
    final List referenceData = csvData.referenceData;

    FlutterListViewController controller = FlutterListViewController();
    return ValueListenableBuilder(
      valueListenable: Hive.box("favorites").listenable(),
      builder: (BuildContext context, dynamic box, Widget? child) {
        final isFavorite = box.get(widget.fullEpisode[newId].id) != null;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.referencesList.length > 19
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
                widget.referencesList.length > 1
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
                                    int.parse(
                                        widget.referencesList[currentRef - 1]));
                                if (referenceId >= 3) {
                                  controller.sliverController
                                      .jumpToIndex(referenceId - 3);
                                } else {
                                  controller.sliverController
                                      .jumpToIndex(referenceId);
                                }
                                currentRef--;
                                newId = referenceId;
                                setState(() {
                                  currentRef;
                                  newId;
                                });
                              }
                            },
                          ),
                          Text(
                            "${currentRef + 1}/${widget.referencesList.length}",
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
                                    widget.referencesList.length - 1) {
                                  int referenceId = findIndex(
                                      widget.fullEpisode,
                                      int.parse(widget
                                          .referencesList[currentRef + 1]));
                                  if (referenceId >= 3) {
                                    controller.sliverController
                                        .jumpToIndex(referenceId - 3);
                                  } else {
                                    controller.sliverController
                                        .jumpToIndex(referenceId);
                                  }
                                  currentRef++;
                                  newId = referenceId;
                                  setState(() {
                                    currentRef;
                                    newId;
                                  });
                                }
                              })
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
            Expanded(
              child: FlutterListView(
                controller: controller,
                delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) {
                    bool isFavorite =
                        box.get(widget.fullEpisode[newId].id) != null;
                    bool hasReference =
                        widget.fullEpisode[newId].reference.contains("s");
                    if (newId == index) {
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
                                ? referenceButton(referenceData, index, context,
                                    true, searchEngineProvider)
                                : const SizedBox(),
                          ],
                        ),
                      );
                    } else {
                      hasReference =
                          widget.fullEpisode[index].reference.contains("s");
                      isFavorite =
                          box.get(widget.fullEpisode[index].id) != null;
                      return ListTile(
                        onTap: () {
                          newId = index;
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
                                ? const Icon(Icons.favorite_rounded,
                                    color: Colors.white)
                                : const SizedBox(),
                            hasReference
                                ? referenceButton(referenceData, index, context,
                                    false, searchEngineProvider)
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
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (!isFavorite) {
                      await box.put(widget.fullEpisode[newId].id,
                          widget.fullEpisode[newId]);
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
                        content: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                if (Platform.isAndroid) {
                                  final result = await Share.shareWithResult(
                                    widget.fullEpisode[newId].line,
                                  );
                                  if (result.status ==
                                      ShareResultStatus.success) {
                                    _showToast("Shared text!");
                                  }
                                } else {
                                  await Clipboard.setData(
                                    ClipboardData(
                                        text: widget.fullEpisode[newId].line),
                                  );
                                  _showToast("Copied to clipboard!");
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
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateImagePage(
                                      episode: widget.fullEpisode,
                                      id: newId,
                                    ),
                                  ),
                                ).then((value) => setState(() {
                                      SystemChrome.setEnabledSystemUIMode(
                                          SystemUiMode.manual,
                                          overlays: [
                                            SystemUiOverlay.top,
                                            SystemUiOverlay.bottom
                                          ]);
                                    }));
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

  IconButton referenceButton(
      List<dynamic> referenceData,
      int index,
      BuildContext context,
      bool isSelected,
      SearchEngineProvider searchEngineProvider) {
    return IconButton(
      onPressed: () {
        final selectedReference = referenceSearch(referenceData, index);
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
                                selectedReference[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final url = Uri.parse(
                                    '${searchEngineProvider.currentSearchEngine}${selectedReference[i].replaceAll("&", "%26")}');
                                launchUrl(
                                  url,
                                  mode: searchEngineProvider.openLinks
                                      ? LaunchMode.inAppWebView
                                      : LaunchMode.externalApplication,
                                );
                              },
                              icon:
                                  const Icon(Icons.search, color: Colors.white),
                            )
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
                          selectedReference.first,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final url = Uri.parse(
                              '${searchEngineProvider.currentSearchEngine}${selectedReference.first.replaceAll("&", "%26")}');
                          launchUrl(
                            url,
                            mode: searchEngineProvider.openLinks
                                ? LaunchMode.inAppWebView
                                : LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.search, color: Colors.white),
                      )
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
