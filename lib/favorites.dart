import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/widgets/itemlist.dart';
import 'database/database_service.dart';
import 'package:psychphinder/utils/responsive.dart';

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
                              margin: ResponsiveUtils.getScreenPadding(context) * 2,
                              constraints: BoxConstraints(
                                maxWidth: ResponsiveUtils.isDesktop(context) ? 600 : double.infinity,
                              ),
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveUtils.isDesktop(context) ? 24 : 20),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(ResponsiveUtils.isDesktop(context) ? 24 : 20),
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
                                  padding: ResponsiveUtils.getCardPadding(context) * 1.5,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(ResponsiveUtils.isDesktop(context) ? 24 : 20),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(ResponsiveUtils.isDesktop(context) ? 24 : 20),
                                        ),
                                        child: Icon(
                                          Icons.favorite_outline_rounded,
                                          size: ResponsiveUtils.isDesktop(context) ? 56 : 48,
                                          color: Colors.red,
                                        ),
                                      ),
                                      SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 3),
                                      Text(
                                        "No favorites yet!",
                                        style: TextStyle(
                                          fontFamily: "PsychFont",
                                          fontWeight: FontWeight.bold,
                                          fontSize: ResponsiveUtils.getTitleFontSize(context) + 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 1.5),
                                      Text(
                                        "Search for quotes and tap the heart icon to save your favorites here.",
                                        style: TextStyle(
                                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
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
