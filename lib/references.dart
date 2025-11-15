import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:psychphinder/classes/reference_class.dart';
import 'package:psychphinder/widgets/references/reference_card.dart';
import 'package:psychphinder/utils/responsive.dart';
import 'package:psychphinder/global/search_history_provider.dart';

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
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && textEditingController.text.isEmpty) {
        _showHistoryOverlay();
      } else {
        _hideHistoryOverlay();
      }
    });

    textEditingController.addListener(() {
      if (_searchFocusNode.hasFocus && textEditingController.text.isEmpty) {
        _showHistoryOverlay();
      } else {
        _hideHistoryOverlay();
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _hideHistoryOverlay();
    super.dispose();
  }

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
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextField(
          controller: textEditingController,
          focusNode: _searchFocusNode,
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
    return ReferenceCard(reference: reference, index: index);
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

  void _showHistoryOverlay() {
    if (_overlayEntry != null || !mounted) return;

    final searchHistory =
        Provider.of<SearchHistoryProvider>(context, listen: false);
    final history = searchHistory.referenceHistory;

    if (history.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _layerLink.leaderSize?.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, _layerLink.leaderSize?.height ?? 0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Consumer<SearchHistoryProvider>(
                builder: (context, searchHistory, _) {
                  final history = searchHistory.referenceHistory;
                  if (history.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _hideHistoryOverlay();
                    });
                    return const SizedBox.shrink();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final query = history[index];
                      return Dismissible(
                        key: Key('reference_history_$query'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Theme.of(context).colorScheme.error,
                          child: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        onDismissed: (_) {
                          searchHistory.removeReferenceSearch(query);
                        },
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.history,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                            size: 20,
                          ),
                          title: Text(
                            query,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            textEditingController.text = query;
                            _hideHistoryOverlay();
                            final databaseService =
                                Provider.of<DatabaseService>(context,
                                    listen: false);
                            _performSearch(query, databaseService);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideHistoryOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _performSearch(
      String query, DatabaseService databaseService) async {
    if (query.trim().isEmpty) return;

    final searchHistory =
        Provider.of<SearchHistoryProvider>(context, listen: false);
    await searchHistory.addReferenceSearch(query);

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
}
