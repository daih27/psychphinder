import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/global/globals.dart';

class BottomSheetEpisode extends StatelessWidget {
  const BottomSheetEpisode({
    super.key,
    required this.indexLine,
    required this.fullEpisode,
    required this.phrase,
  });

  final int indexLine;
  final List fullEpisode;
  final Phrase phrase;

  List<String> referenceSearch(List referenceData) {
    List<String> referenceSelected = [];
    for (var i = 0; i < referenceData.length; i++) {
      final id = referenceData[i].id.replaceAll('\r', '').trim();
      final idPhrase = phrase.reference.replaceAll('\r', '').trim();
      final splitted = idPhrase.split(',');
      for (var j = 0; j < splitted.length; j++) {
        if (id == splitted[j]) {
          referenceSelected.add(referenceData[i].reference);
        }
      }
    }
    return referenceSelected;
  }

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final List referenceData = csvData.referenceData;
    return ValueListenableBuilder(
      valueListenable: Hive.box("favorites").listenable(),
      builder: (BuildContext context, dynamic box, Widget? child) {
        final isFavorite = box.get(phrase.id) != null;
        return Column(
          children: [
            Text(
              phrase.name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PsychFont'),
            ),
            if (phrase.season != 0)
              Text(
                "Season ${phrase.season}, Episode ${phrase.episode}",
                style: const TextStyle(
                    fontSize: 15,
                    // fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'PsychFont'),
              ),
            Expanded(
              child: FlutterListView(
                delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) {
                    final hasReference = phrase.reference.contains("s");
                    if (indexLine == index) {
                      return ListTile(
                        title: Text(
                          "${fullEpisode[index].time}   ${fullEpisode[index].line}",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        trailing: hasReference
                            ? IconButton(
                                onPressed: () {
                                  final selectedReference =
                                      referenceSearch(referenceData);
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                for (var i = 0;
                                                    i <
                                                        selectedReference
                                                            .length;
                                                    i++) ...[
                                                  Text(
                                                    selectedReference[i],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              ],
                                            )
                                          : Text(
                                              selectedReference.first,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.question_mark_rounded),
                                color: Colors.green,
                              )
                            : null,
                      );
                    } else {
                      return ListTile(
                        title: Text(
                          "${fullEpisode[index].time}   ${fullEpisode[index].line}",
                        ),
                      );
                    }
                  },
                  childCount: fullEpisode.length,
                  initIndex: indexLine - 3,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () async {
                  if (!isFavorite) {
                    await box.put(phrase.id, phrase);
                  } else {
                    await box.delete(phrase.id);
                  }
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                  Colors.green,
                )),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites'),
                    const Icon(
                      Icons.favorite,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
