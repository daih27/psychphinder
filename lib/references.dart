import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psychphinder/utils/responsive.dart';

class ReferencesPage extends StatefulWidget {
  const ReferencesPage({super.key});

  @override
  State<ReferencesPage> createState() => _ReferencesPageState();
}

class _ReferencesPageState extends State<ReferencesPage>
    with AutomaticKeepAliveClientMixin<ReferencesPage> {
  @override
  bool get wantKeepAlive => true;

  bool isSearching = false;
  bool isLoading = false;
  String searchInput = "";
  List<Reference> searchResults = <Reference>[];
  String selectedCategory = 'All';
  String selectedSeason = 'All';
  String selectedEpisode = 'All';
  final TextEditingController textEditingController = TextEditingController();
  final ExpansibleController expansionController = ExpansibleController();

  Future<List<int>> _getSeasonsWithReferences(
      DatabaseService databaseService) async {
    final allSeasons = await databaseService.getSeasons();
    final allReferences = await databaseService.getReferences();

    final hasMovieReferences = allReferences.any((ref) => ref.season == 999);

    return allSeasons.where((season) {
      if (season == 999) {
        return hasMovieReferences;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var databaseService = Provider.of<DatabaseService>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadSeasonAndCategoryData(databaseService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final data = snapshot.data!;
        final seasons = data['seasons'] as List<int>;
        final categories = data['categories'] as List<String>;
        final episodesMap = data['episodesMap'] as Map<String, List<String>>;

        return Scaffold(
          body: Column(
            children: [
              _buildSearchBar(databaseService),
              _buildSearchFilters(categories, seasons, episodesMap),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isSearching
                        ? searchResults.isNotEmpty
                            ? _buildSearchResults()
                            : const Center(
                                child: Text(
                                  "No references found.",
                                  style: TextStyle(
                                    fontFamily: "PsychFont",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                        : _buildSeasonGrid(seasons),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadSeasonAndCategoryData(
      DatabaseService databaseService) async {
    final allSeasons = await _getSeasonsWithReferences(databaseService);
    final categories = await databaseService.getReferenceCategories();

    Map<String, List<String>> episodesMap = {};
    for (var seasonNum in allSeasons) {
      String seasonStr = seasonNum == 999 ? 'Movies' : seasonNum.toString();
      final episodes = await databaseService.getEpisodesForSeason(seasonNum);
      List<String> episodeList = [];
      for (var episode in episodes) {
        episodeList.add("${episode['episode']} - ${episode['name']}");
      }
      episodesMap[seasonStr] = episodeList;
    }

    return {
      'seasons': allSeasons,
      'categories': categories,
      'episodesMap': episodesMap,
    };
  }

  Widget _buildSearchBar(DatabaseService databaseService) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 7),
      child: TextField(
          controller: textEditingController,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          onSubmitted: (text) async {
            await _performSearch(text, databaseService);
          },
          cursorColor: Theme.of(context).colorScheme.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            hintText: 'Search references...',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            suffixIcon: textEditingController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      textEditingController.clear();
                      setState(() {
                        searchResults.clear();
                        isSearching = false;
                        searchInput = "";
                      });
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () async {
                        await _performSearch(
                            textEditingController.text, databaseService);
                      },
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
    );
  }

  Widget _buildSearchFilters(List<String> categories, List<int> seasons,
      Map<String, List<String>> episodesMap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionTile(
        controller: expansionController,
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              "Search filters",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        children: [
          StatefulBuilder(
            builder: (context, setFilterState) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Category",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['All', ...categories].map((category) {
                            final isSelected = selectedCategory == category;
                            return FilterChip(
                              selected: isSelected,
                              label: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              checkmarkColor: Colors.white,
                              onSelected: (selected) {
                                setFilterState(() {
                                  selectedCategory = category;
                                });
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Season",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  border: InputBorder.none,
                                ),
                                value: selectedSeason,
                                items: [
                                  'All',
                                  ...seasons.map(
                                      (s) => s == 999 ? 'Movies' : s.toString())
                                ].map((season) {
                                  return DropdownMenuItem<String>(
                                    value: season,
                                    child: Text(
                                      season,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (season) {
                                  if (season != null) {
                                    setFilterState(() {
                                      selectedSeason = season;
                                      selectedEpisode = "All";
                                    });
                                    setState(() {
                                      selectedSeason = season;
                                      selectedEpisode = "All";
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedSeason == "Movies" ? "Movie" : "Episode",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  border: InputBorder.none,
                                ),
                                value: selectedEpisode,
                                items: _buildEpisodeItems(
                                    selectedSeason, episodesMap),
                                onChanged: (episode) {
                                  if (episode != null) {
                                    setFilterState(() {
                                      selectedEpisode = episode;
                                    });
                                    setState(() {
                                      selectedEpisode = episode;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildEpisodeItems(
      String season, Map<String, List<String>> episodesMap) {
    final episodeList = episodesMap[season] ?? [];
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: 'All',
        child: Text(
          'All',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    ];

    for (final episode in episodeList) {
      items.add(DropdownMenuItem<String>(
        value: episode,
        child: Text(
          episode,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ));
    }

    return items;
  }

  Widget _buildSearchResults() {
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);
    final padding = ResponsiveUtils.getScreenPadding(context);

    if (isLargeScreen) {
      final columns = ResponsiveUtils.getItemListColumns(context);
      return GridView.builder(
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: ResponsiveUtils.getHorizontalPadding(context),
          mainAxisSpacing: ResponsiveUtils.getVerticalPadding(context),
          mainAxisExtent: ResponsiveUtils.isDesktop(context) ? 200 : 180,
        ),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return _buildReferenceCard(searchResults[index], index);
        },
      );
    }

    return ListView.builder(
      padding: padding,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return _buildReferenceCard(searchResults[index], index);
      },
    );
  }

  Widget _buildReferenceCard(Reference reference, int index) {
    final titleText = reference.reference.split("(").first.trim();
    final subtitleText =
        reference.reference.split("(").last.replaceAll(')', '').trim();
    final hasVideo = reference.link.isNotEmpty;
    final referenceTypeInfo = _getReferenceTypeInfo(subtitleText);

    return FutureBuilder<int>(
      future: _getReferencesCount(reference),
      builder: (context, countSnapshot) {
        final referencesCount = countSnapshot.data ?? 1;

        return Card(
          elevation: ResponsiveUtils.getCardElevation(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 16 : 12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                  ResponsiveUtils.isDesktop(context) ? 16 : 12),
              onTap: () async {
                final databaseService =
                    Provider.of<DatabaseService>(context, listen: false);
                final goRouter = GoRouter.of(context);

                final episodePhrases = await databaseService.getEpisodePhrases(
                    reference.season, reference.episode);

                final phrasesWithReference = episodePhrases
                    .where((phrase) =>
                        phrase.reference?.split(',').contains(reference.id) ??
                        false)
                    .toList();

                if (!mounted) return;

                if (phrasesWithReference.isNotEmpty) {
                  phrasesWithReference.sort((a, b) =>
                      a.sequenceInEpisode.compareTo(b.sequenceInEpisode));
                  final targetPhrase = phrasesWithReference.first;

                  final route =
                      '/s${targetPhrase.season}/e${targetPhrase.episode}/p${targetPhrase.sequenceInEpisode}/r${reference.id}';
                  goRouter.push(route);
                }
              },
              child: Padding(
                padding: ResponsiveUtils.getCardPadding(context),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          ResponsiveUtils.isDesktop(context) ? 10 : 8),
                      decoration: BoxDecoration(
                        color:
                            referenceTypeInfo['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        referenceTypeInfo['icon'],
                        color: referenceTypeInfo['color'],
                        size: ResponsiveUtils.getIconSize(context),
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveUtils.getHorizontalPadding(context) *
                            0.75),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  titleText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveUtils.getBodyFontSize(
                                        context),
                                  ),
                                  maxLines:
                                      ResponsiveUtils.isLargeScreen(context)
                                          ? 2
                                          : 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        ResponsiveUtils.isDesktop(context)
                                            ? 8
                                            : 6,
                                    vertical: 2),
                                decoration: BoxDecoration(
                                  color: referenceTypeInfo['color'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  referenceTypeInfo['type'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getSmallFontSize(
                                            context) -
                                        2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  ResponsiveUtils.getVerticalPadding(context) *
                                      0.5),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subtitleText,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize:
                                            ResponsiveUtils.getSmallFontSize(
                                                context),
                                      ),
                                      maxLines:
                                          ResponsiveUtils.isLargeScreen(context)
                                              ? 2
                                              : 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                        height:
                                            ResponsiveUtils.getVerticalPadding(
                                                    context) *
                                                0.25),
                                    Text(
                                      reference.season == 999
                                          ? reference.name
                                          : "S${reference.season}E${reference.episode} • ${reference.name}",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize:
                                            ResponsiveUtils.getSmallFontSize(
                                                    context) -
                                                1,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (hasVideo)
                                Container(
                                  padding: EdgeInsets.all(
                                      ResponsiveUtils.isDesktop(context)
                                          ? 4
                                          : 3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: ResponsiveUtils.isDesktop(context)
                                        ? 14
                                        : 12,
                                  ),
                                ),
                              SizedBox(
                                  width: ResponsiveUtils.getHorizontalPadding(
                                          context) *
                                      0.5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        ResponsiveUtils.isDesktop(context)
                                            ? 10
                                            : 8,
                                    vertical: ResponsiveUtils.isDesktop(context)
                                        ? 6
                                        : 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  referencesCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtils.getSmallFontSize(
                                        context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }

  Widget _buildSeasonGrid(List<int> seasons) {
    final columns = ResponsiveUtils.getGridColumns(context);
    final padding = ResponsiveUtils.getScreenPadding(context);

    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: ResponsiveUtils.getHorizontalPadding(context),
        mainAxisSpacing: ResponsiveUtils.getVerticalPadding(context) + 8,
        mainAxisExtent: ResponsiveUtils.isDesktop(context)
            ? 140
            : ResponsiveUtils.isTablet(context)
                ? 130
                : 120,
      ),
      itemCount: seasons.length,
      itemBuilder: (context, index) {
        final seasonNum = seasons[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 20 : 16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  ResponsiveUtils.isDesktop(context) ? 20 : 16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                    ResponsiveUtils.isDesktop(context) ? 20 : 16),
                onTap: () {
                  context.go('/references/season$seasonNum');
                },
                child: Padding(
                  padding: ResponsiveUtils.getCardPadding(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        seasonNum == 999 ? 'Movies' : "Season $seasonNum",
                        style: TextStyle(
                          fontFamily: 'PsychFont',
                          fontWeight: FontWeight.bold,
                          fontSize:
                              ResponsiveUtils.getBodyFontSize(context) + 2,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (ResponsiveUtils.isDesktop(context))
                        SizedBox(
                            height:
                                ResponsiveUtils.getVerticalPadding(context)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _performSearch(
      String query, DatabaseService databaseService) async {
    searchInput = query;
    setState(() {
      isLoading = true;
      isSearching = true;
    });

    try {
      searchResults = await databaseService.searchReferences(
        query,
        category: selectedCategory == "All" ? null : selectedCategory,
        season: selectedSeason == "All" ? null : selectedSeason,
        episode: selectedEpisode == "All" ? null : selectedEpisode,
      );
    } catch (e) {
      searchResults = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<int> _getReferencesCount(Reference reference) async {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);
    final episodePhrases = await databaseService.getEpisodePhrases(
        reference.season, reference.episode);

    final phrasesWithReference = episodePhrases
        .where((phrase) =>
            phrase.reference?.split(',').contains(reference.id) ?? false)
        .toList();

    return phrasesWithReference.length;
  }

  Map<String, dynamic> _getReferenceTypeInfo(String referenceText) {
    final lowerText = referenceText.toLowerCase();

    if (lowerText.contains('movie') || lowerText.contains('film')) {
      return {'type': 'Movie', 'color': Colors.red, 'icon': Icons.movie};
    } else if (lowerText.contains('actor') || lowerText.contains('actress')) {
      return {'type': 'Actor', 'color': Colors.purple, 'icon': Icons.person};
    } else if (lowerText.contains('musician') ||
        lowerText.contains('singer') ||
        lowerText.contains('band')) {
      return {
        'type': 'Music',
        'color': Colors.orange,
        'icon': Icons.music_note
      };
    } else if (lowerText.contains('tv show') ||
        lowerText.contains('television')) {
      return {'type': 'TV Show', 'color': Colors.blue, 'icon': Icons.tv};
    } else if (lowerText.contains('book') ||
        lowerText.contains('novel') ||
        lowerText.contains('writer') ||
        lowerText.contains('author')) {
      return {'type': 'Literature', 'color': Colors.brown, 'icon': Icons.book};
    } else if (lowerText.contains('game') || lowerText.contains('sport')) {
      return {
        'type': 'Game/Sport',
        'color': Colors.green,
        'icon': Icons.sports
      };
    } else if (lowerText.contains('company') ||
        lowerText.contains('brand') ||
        lowerText.contains('store')) {
      return {'type': 'Brand', 'color': Colors.indigo, 'icon': Icons.business};
    } else if (lowerText.contains('song') || lowerText.contains('album')) {
      return {'type': 'Song', 'color': Colors.pink, 'icon': Icons.queue_music};
    } else if (lowerText.contains('character') ||
        lowerText.contains('fictional')) {
      return {'type': 'Character', 'color': Colors.teal, 'icon': Icons.face};
    } else {
      return {
        'type': 'Other',
        'color': Colors.grey,
        'icon': Icons.help_outline
      };
    }
  }
}

class EpisodesRoute extends StatelessWidget {
  final Map<String, List<String>> data;
  final String season;
  const EpisodesRoute(this.data, this.season, {super.key});

  String extractNumberBeforeHyphen(String input) {
    final pattern = RegExp(r'^\d{1,2}\s-\s');
    final match = pattern.firstMatch(input);
    if (match != null) {
      return match.group(0)!.replaceAll(' - ', '');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService>(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: databaseService.getEpisodesForSeason(int.parse(season)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final episodes = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const Text(
                  'Episodes',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.green,
                    fontFamily: 'PsychFont',
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Season $season",
                  style: const TextStyle(
                    fontFamily: 'PsychFont',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              final episodesKey = episode['name'];

              return FutureBuilder<int>(
                future: databaseService.getReferences().then((refs) {
                  Set<String> uniqueRefIds = refs
                      .where((ref) =>
                          ref.season == int.parse(season) &&
                          ref.episode == episode['episode'])
                      .map((ref) => ref.id)
                      .toSet();
                  return uniqueRefIds.length;
                }),
                builder: (context, refCountSnapshot) {
                  final referencesCount = refCountSnapshot.data ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            context.go(
                              '/references/season$season/episode${episode['episode']}',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    episode['episode'].toString(),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        episodesKey,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    referencesCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ReferencesRoute extends StatefulWidget {
  final String season;
  final String episodeNumber;
  const ReferencesRoute(this.season, this.episodeNumber, {super.key});

  @override
  State<ReferencesRoute> createState() => _ReferencesRouteState();
}

class _ReferencesRouteState extends State<ReferencesRoute>
    with AutomaticKeepAliveClientMixin<ReferencesRoute> {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> _getReferenceTypeInfo(String referenceText) {
    final lowerText = referenceText.toLowerCase();

    if (lowerText.contains('movie') || lowerText.contains('film')) {
      return {'type': 'Movie', 'color': Colors.red, 'icon': Icons.movie};
    } else if (lowerText.contains('actor') || lowerText.contains('actress')) {
      return {'type': 'Actor', 'color': Colors.purple, 'icon': Icons.person};
    } else if (lowerText.contains('musician') ||
        lowerText.contains('singer') ||
        lowerText.contains('band')) {
      return {
        'type': 'Music',
        'color': Colors.orange,
        'icon': Icons.music_note
      };
    } else if (lowerText.contains('tv show') ||
        lowerText.contains('television')) {
      return {'type': 'TV Show', 'color': Colors.blue, 'icon': Icons.tv};
    } else if (lowerText.contains('book') ||
        lowerText.contains('novel') ||
        lowerText.contains('writer') ||
        lowerText.contains('author')) {
      return {'type': 'Literature', 'color': Colors.brown, 'icon': Icons.book};
    } else if (lowerText.contains('game') || lowerText.contains('sport')) {
      return {
        'type': 'Game/Sport',
        'color': Colors.green,
        'icon': Icons.sports
      };
    } else if (lowerText.contains('company') ||
        lowerText.contains('brand') ||
        lowerText.contains('store')) {
      return {'type': 'Brand', 'color': Colors.indigo, 'icon': Icons.business};
    } else if (lowerText.contains('song') || lowerText.contains('album')) {
      return {'type': 'Song', 'color': Colors.pink, 'icon': Icons.queue_music};
    } else if (lowerText.contains('character') ||
        lowerText.contains('fictional')) {
      return {'type': 'Character', 'color': Colors.teal, 'icon': Icons.face};
    } else {
      return {
        'type': 'Other',
        'color': Colors.grey,
        'icon': Icons.help_outline
      };
    }
  }

  late final Future sortByInit;
  late bool sortByAlphabetical;
  late bool firstLoad;
  Future<Map<String, dynamic>>? _referencesDataFuture;

  @override
  void initState() {
    sortByInit = loadSort();
    firstLoad = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> loadSort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("sortRef") ?? true;
  }

  Future<void> saveSort(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("sortRef", value);
  }

  Future<Map<String, dynamic>> _loadReferencesData(
      DatabaseService databaseService) async {
    final sortInit = await loadSort();
    final allReferences = await databaseService.getReferences();

    Map<String, dynamic> uniqueReferences = {};
    for (var ref in allReferences) {
      if (ref.season == int.parse(widget.season) &&
          ref.episode == int.parse(widget.episodeNumber)) {
        uniqueReferences[ref.id] = ref;
      }
    }

    List references = uniqueReferences.values.toList();

    return {
      'sortInit': sortInit,
      'references': references,
    };
  }

  List referenceList(List referenceData) {
    List references = [];
    for (var i = 0; i < referenceData.length; i++) {
      if (referenceData[i].season == int.parse(widget.season) &&
          referenceData[i].episode == int.parse(widget.episodeNumber)) {
        references.add(referenceData[i]);
      }
    }
    return references;
  }

  Future<int> getFirstChronologicalOccurrence(
      String referenceId, DatabaseService databaseService) async {
    final episodePhrases = await databaseService.getEpisodePhrases(
        int.parse(widget.season), int.parse(widget.episodeNumber));

    final phrasesWithReference = episodePhrases
        .where((phrase) =>
            phrase.reference?.split(',').contains(referenceId) ?? false)
        .toList();

    if (phrasesWithReference.isEmpty) return 0;

    phrasesWithReference
        .sort((a, b) => a.sequenceInEpisode.compareTo(b.sequenceInEpisode));
    return phrasesWithReference.first.id;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var databaseService = Provider.of<DatabaseService>(context);
    _referencesDataFuture ??= _loadReferencesData(databaseService);

    return FutureBuilder<Map<String, dynamic>>(
      future: _referencesDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;
          final bool sortInit = data['sortInit'];
          final List references = data['references'];

          if (firstLoad) {
            sortByAlphabetical = sortInit;
            firstLoad = false;
          }
          sortByAlphabetical == true
              ? references.sort((a, b) => a.reference.compareTo(b.reference))
              : references.sort((a, b) => int.parse(a.idLine.split(',')[0])
                  .compareTo(int.parse(b.idLine.split(',')[0])));
          return PopScope(
            onPopInvokedWithResult: (bool didPop, Object? result) {
              saveSort(sortByAlphabetical);
              if (didPop) {
                return;
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    const Text(
                      'References',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.green,
                        fontFamily: 'PsychFont',
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      widget.season == "999"
                          ? "Movie"
                          : "Season ${widget.season}, Episode ${widget.episodeNumber}",
                      style: const TextStyle(
                        fontFamily: 'PsychFont',
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(Icons.sort_rounded),
                          onPressed: () {
                            setState(
                              () {
                                sortByAlphabetical == true
                                    ? sortByAlphabetical = false
                                    : sortByAlphabetical = true;
                              },
                            );
                          },
                        ),
                        Positioned(
                          right: 6,
                          bottom: 2,
                          child: sortByAlphabetical == true
                              ? const Icon(Icons.sort_by_alpha_rounded,
                                  size: 14)
                              : const Icon(Icons.schedule_rounded, size: 14),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              body: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: references.length,
                itemBuilder: (context, index) {
                  final String titleText =
                      references[index].reference.split("(").first.trim();
                  final String subtitleText = references[index]
                      .reference
                      .split("(")
                      .last
                      .replaceAll(')', '')
                      .trim();
                  final hasVideo = references[index].link != "";
                  final referenceTypeInfo = _getReferenceTypeInfo(subtitleText);

                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final firstPhraseId =
                                await getFirstChronologicalOccurrence(
                                    references[index].id, databaseService);
                            if (!context.mounted) return;

                            final episodePhrases =
                                await databaseService.getEpisodePhrases(
                                    int.parse(widget.season),
                                    int.parse(widget.episodeNumber));
                            if (!context.mounted) return;

                            final targetPhrase = episodePhrases.firstWhere(
                                (phrase) => phrase.id == firstPhraseId);

                            final route =
                                '/s${targetPhrase.season}/e${targetPhrase.episode}/p${targetPhrase.sequenceInEpisode}/r${references[index].id}';
                            context.push(route);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: referenceTypeInfo['color']
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    referenceTypeInfo['icon'],
                                    color: referenceTypeInfo['color'],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              titleText,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: referenceTypeInfo['color'],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              referenceTypeInfo['type'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subtitleText,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (hasVideo)
                                            Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
