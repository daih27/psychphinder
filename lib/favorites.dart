import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/widgets/itemlist.dart';
import 'global/globals.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List convertFavorite(List favorites, List data) {
    List newFavorites = [];
    for (var i = 0; i < favorites.length; i++) {
      if (favorites[i].runtimeType == Phrase) {
        newFavorites.add(data[favorites[i].id]);
        Hive.box("favorites").delete(favorites[i].id);
        Hive.box("favorites").put(favorites[i].id, favorites[i].id);
      } else {
        newFavorites.add(data[favorites[i]]);
      }
    }
    return newFavorites;
  }

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final List data = csvData.data;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box("favorites").listenable(),
              builder: (BuildContext context, dynamic box, Widget? child) {
                final favorites = box.values.toList();
                final favoritesList = convertFavorite(favorites, data);
                return favoritesList.isNotEmpty
                    ? ItemList(lines: favoritesList, data: data)
                    : const Center(
                        child: Text(
                          "You have no favorites yet.\nTry adding some!",
                          style: TextStyle(
                            fontFamily: "PsychFont",
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
