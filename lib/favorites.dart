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
  Future<List> convertFavorite(
      List favorites, DatabaseService databaseService) async {
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
                        : Center(
                            child: Container(
                              margin: const EdgeInsets.all(32),
                              child: Card(
                                elevation: 6,
                                shadowColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).colorScheme.surface,
                                        Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: 0.9),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.favorite_outline_rounded,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        "No favorites yet!",
                                        style: TextStyle(
                                          fontFamily: "PsychFont",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Search for quotes and tap the heart icon to save your favorites here.",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.8),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            onTap: () {},
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.search_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Start searching",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
