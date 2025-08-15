import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/widgets/itemlist.dart';
import 'database/database_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Future<List> convertFavorite(List favorites, DatabaseService databaseService) async {
    List newFavorites = [];
    for (var i = 0; i < favorites.length; i++) {
      if (favorites[i].runtimeType == Phrase) {
        final phrase = await databaseService.getPhraseById(favorites[i].id);
        if (phrase != null) {
          newFavorites.add(phrase);
        }
        Hive.box("favorites").delete(favorites[i].id);
        Hive.box("favorites").put(favorites[i].id, favorites[i].id);
      } else {
        final phrase = await databaseService.getPhraseById(favorites[i]);
        if (phrase != null) {
          newFavorites.add(phrase);
        }
      }
    }
    return newFavorites;
  }

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService>(context);
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box("favorites").listenable(),
              builder: (BuildContext context, dynamic box, Widget? child) {
                final favorites = box.values.toList();
                return FutureBuilder<List>(
                  future: convertFavorite(favorites, databaseService),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    
                    final favoritesList = snapshot.data ?? [];
                    return favoritesList.isNotEmpty
                        ? ItemList(lines: favoritesList)
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
