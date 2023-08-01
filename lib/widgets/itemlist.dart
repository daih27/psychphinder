import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:psychphinder/classes/full_episode.dart';
import 'package:psychphinder/widgets/bottomsheet.dart';

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.lines,
    required this.data,
  });

  final List lines;
  final List data;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("favorites").listenable(),
      builder: (BuildContext context, dynamic box, Widget? child) {
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: lines.length,
          itemBuilder: (context, index) {
            final isFavorite = box.get(lines[index].id) != null;
            final hasReference = lines[index].reference.contains("s");
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Material(
                child: ListTile(
                  title: Text(lines[index].line),
                  subtitle: Text(
                    lines[index].season != 0
                        ? "Season ${lines[index].season}, Episode ${lines[index].episode}: ${lines[index].name}"
                        : lines[index].name,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFavorite)
                        const Icon(
                          Icons.favorite,
                          color: Colors.green,
                        ),
                      if (hasReference)
                        const Icon(
                          Icons.question_mark_rounded,
                          color: Colors.green,
                        ),
                    ],
                  ),
                  onTap: () {
                    EpisodeUtil.fullEpisode(data, lines[index]);
                    showModalBottomSheet(
                      context: context,
                      enableDrag: false,
                      builder: (BuildContext context) {
                        return BottomSheetEpisode(
                          indexLine: EpisodeUtil.index,
                          fullEpisode: EpisodeUtil.full,
                          referencesList: const [],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
