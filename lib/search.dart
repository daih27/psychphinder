import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/database/database_service.dart';
import 'package:psychphinder/widgets/itemlist.dart';
import 'package:psychphinder/widgets/search/random_reference_widget.dart';
import 'package:psychphinder/widgets/search/did_you_know_widget.dart';
import 'package:psychphinder/widgets/search/update_notification_widget.dart';
import 'package:psychphinder/widgets/search/search_filters.dart';
import 'package:psychphinder/utils/update_checker.dart';
import 'dart:math';
import 'global/did_you_know.dart';
import 'package:psychphinder/utils/responsive.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  @override
  bool get wantKeepAlive => true;
  List searched = <Phrase>[];
  Map map = {};
  bool isLoading = false;
  bool isSearching = false;
  bool showUpdate = false;
  String input = "";
  late int randomIndex;
  late int randomIndexDYK;
  Random rng = Random();
  String selectedSeason = 'All';
  String selectedEpisode = 'All';
  final TextEditingController textEditingController = TextEditingController();
  final ExpansibleController expansionController = ExpansibleController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    randomIndex = rng.nextInt(2606);
    randomIndexDYK = rng.nextInt(DYK.didYouKnowOptions.length);
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    final shouldShow = await UpdateChecker.shouldShowUpdate();
    if (mounted) {
      setState(() {
        showUpdate = shouldShow;
      });
    }
  }

  Future<Map<String, dynamic>> _loadSeasonEpisodeData(
      DatabaseService databaseService) async {
    final seasonNums = await databaseService.getSeasons();
    List<String> seasons = [];
    Map<String, List<String>> episodesMap = {};

    for (var seasonNum in seasonNums) {
      String seasonStr = seasonNum == 999 ? 'Movies' : seasonNum.toString();
      if (!seasons.contains(seasonStr)) {
        seasons.add(seasonStr);
      }

      final episodes = await databaseService.getEpisodesForSeason(seasonNum);

      List<String> episodeList = [];
      for (var episode in episodes) {
        episodeList.add("${episode['episode']} - ${episode['name']}");
      }

      episodesMap[seasonStr] = episodeList;
    }

    seasons.sort((a, b) {
      if (a == 'Movies') return 1;
      if (b == 'Movies') return -1;
      return int.parse(a).compareTo(int.parse(b));
    });

    return {
      'seasons': seasons,
      'episodesMap': episodesMap,
    };
  }

  Widget randomReference() {
    return const RandomReferenceWidget();
  }

  Widget didYouKnow() {
    return DidYouKnowWidget(fact: DYK.didYouKnowOptions[randomIndexDYK]);
  }

  Widget showUpdateWidget() {
    return UpdateNotificationWidget(
      onShowWhatsNew: () {
        setState(() {
          showUpdate = false;
        });
        UpdateChecker.showWhatsNewDialog(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var databaseService = Provider.of<DatabaseService>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadSeasonEpisodeData(databaseService),
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
        final List<String> seasons = data['seasons'];
        final Map<String, List<String>> episodesMap = data['episodesMap'];

        final isLargeScreen = ResponsiveUtils.isLargeScreen(context);
        final isTablet = ResponsiveUtils.isTablet(context);

        return Scaffold(
          body: !isSearching
              ? CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          isLoading
                              ? const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : searched.isNotEmpty
                                  ? Expanded(
                                      child: ItemList(
                                          lines: searched, input: input))
                                  : isSearching
                                      ? const Expanded(
                                          child: Center(
                                            child: Text(
                                              "No results found.",
                                              style: TextStyle(
                                                fontFamily: "PsychFont",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : welcomeWidgets(),
                        ],
                      ),
                    ),
                  ],
                )
              : isLargeScreen
                  ? Row(
                      children: [
                        Container(
                          width: isTablet ? 280 : 320,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border(
                              right: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildCompactSearchBar(),
                              _buildCompactFilters(seasons, episodesMap),
                            ],
                          ),
                        ),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : searched.isNotEmpty
                                  ? ItemList(lines: searched, input: input)
                                  : const Center(
                                      child: Text(
                                        "No results found.",
                                        style: TextStyle(
                                          fontFamily: "PsychFont",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              ResponsiveUtils.getHorizontalPadding(context)),
                          child: _buildHeroSearchBarWithFilters(
                              seasons, episodesMap),
                        ),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : searched.isNotEmpty
                                  ? ItemList(lines: searched, input: input)
                                  : const Center(
                                      child: Text(
                                        "No results found.",
                                        style: TextStyle(
                                          fontFamily: "PsychFont",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                        )
                      ],
                    ),
        );
      },
    );
  }

  Expanded welcomeWidgets() {
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            if (showUpdate) ...[
              SizedBox(height: ResponsiveUtils.getVerticalPadding(context)),
              showUpdateWidget(),
            ],
            SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 2),
            if (isLargeScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: didYouKnow()),
                  SizedBox(
                      width: ResponsiveUtils.getHorizontalPadding(context)),
                  Expanded(child: randomReference()),
                ],
              )
            else
              Column(
                children: [
                  didYouKnow(),
                  SizedBox(
                      height: ResponsiveUtils.getVerticalPadding(context) * 2),
                  randomReference(),
                ],
              ),
            SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);
    final padding = ResponsiveUtils.getScreenPadding(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: padding.horizontal * 0.5,
        vertical: ResponsiveUtils.getVerticalPadding(context),
      ),
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 2),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              "🍍 Find your favorite Psych quotes",
              style: TextStyle(
                fontFamily: "PsychFont",
                fontWeight: FontWeight.bold,
                fontSize: isLargeScreen ? 32 : 24,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context)),
          Text(
            "Search through thousands of quotes from 8 seasons and 3 movies",
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 3),
          FutureBuilder<Map<String, dynamic>>(
            future: _loadSeasonEpisodeData(_databaseService),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildHeroSearchBar();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _buildHeroSearchBar();
              }
              final data = snapshot.data!;
              final List<String> seasons = data['seasons'];
              final Map<String, List<String>> episodesMap = data['episodesMap'];
              return _buildHeroSearchBarWithFilters(seasons, episodesMap);
            },
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 2),
          _buildSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildHeroSearchBar() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUtils.isDesktop(context) ? 600 : double.infinity,
      ),
      child: TextField(
        controller: textEditingController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
          fontWeight: FontWeight.w500,
        ),
        onSubmitted: (text) async {
          input = text;
          setState(() {
            isLoading = true;
            isSearching = true;
          });
          var databaseService =
              Provider.of<DatabaseService>(context, listen: false);
          searched = await databaseService.searchQuotes(
            text,
            season: selectedSeason == "All" ? null : selectedSeason,
            episode: selectedEpisode == "All" ? null : selectedEpisode,
          );
          setState(() {
            isLoading = false;
          });
        },
        cursorColor: Theme.of(context).colorScheme.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: 'Search for "pineapple", "psychic", or any quote...',
          hintStyle: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(ResponsiveUtils.isDesktop(context) ? 12 : 8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: ResponsiveUtils.getIconSize(context) + 4,
            ),
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
                      searched.clear();
                      isSearching = false;
                      input = "";
                    });
                  },
                )
              : Container(
                  margin: EdgeInsets.all(
                      ResponsiveUtils.isDesktop(context) ? 8 : 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                        ResponsiveUtils.isDesktop(context) ? 16 : 12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: ResponsiveUtils.getIconSize(context),
                    ),
                    onPressed: () async {
                      input = textEditingController.text;
                      setState(() {
                        isLoading = true;
                        isSearching = true;
                      });
                      var databaseService =
                          Provider.of<DatabaseService>(context, listen: false);
                      searched = await databaseService.searchQuotes(
                        textEditingController.text,
                        season: selectedSeason == "All" ? null : selectedSeason,
                        episode:
                            selectedEpisode == "All" ? null : selectedEpisode,
                      );
                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 28 : 24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 28 : 24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 28 : 24),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getHorizontalPadding(context) + 8,
            vertical: ResponsiveUtils.getVerticalPadding(context) + 8,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSearchBarWithFilters(
      List<String> seasons, Map<String, List<String>> episodesMap) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 700 : double.infinity,
      ),
      child: Column(
        children: [
          TextField(
            controller: textEditingController,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
              fontWeight: FontWeight.w500,
            ),
            onSubmitted: (text) async {
              input = text;
              setState(() {
                isLoading = true;
                isSearching = true;
              });
              var databaseService =
                  Provider.of<DatabaseService>(context, listen: false);
              searched = await databaseService.searchQuotes(
                text,
                season: selectedSeason == "All" ? null : selectedSeason,
                episode: selectedEpisode == "All" ? null : selectedEpisode,
              );
              setState(() {
                isLoading = false;
              });
            },
            cursorColor: Theme.of(context).colorScheme.primary,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              hintText: 'Search for "pineapple", "psychic", or any quote...',
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                fontSize: ResponsiveUtils.getBodyFontSize(context) + 1,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(isDesktop ? 12 : 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: ResponsiveUtils.getIconSize(context) + 4,
                ),
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
                          searched.clear();
                          isSearching = false;
                          input = "";
                        });
                      },
                    )
                  : Container(
                      margin: EdgeInsets.all(isDesktop ? 8 : 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(isDesktop ? 16 : 12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: ResponsiveUtils.getIconSize(context),
                        ),
                        onPressed: () async {
                          input = textEditingController.text;
                          setState(() {
                            isLoading = true;
                            isSearching = true;
                          });
                          var databaseService = Provider.of<DatabaseService>(
                              context,
                              listen: false);
                          searched = await databaseService.searchQuotes(
                            textEditingController.text,
                            season:
                                selectedSeason == "All" ? null : selectedSeason,
                            episode: selectedEpisode == "All"
                                ? null
                                : selectedEpisode,
                          );
                          setState(() {
                            isLoading = false;
                          });
                        },
                      ),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getHorizontalPadding(context) + 8,
                vertical: ResponsiveUtils.getVerticalPadding(context) + 8,
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 1.5),
          _buildHeroFilters(seasons, episodesMap),
        ],
      ),
    );
  }

  Widget _buildHeroFilters(
      List<String> seasons, Map<String, List<String>> episodesMap) {
    return SearchFilters(
      controller: expansionController,
      selectedSeason: selectedSeason,
      selectedEpisode: selectedEpisode,
      seasons: seasons,
      episodesMap: episodesMap,
      onSeasonChanged: (value) {
        setState(() {
          selectedSeason = value;
          selectedEpisode = "All";
        });
      },
      onEpisodeChanged: (value) {
        setState(() {
          selectedEpisode = value;
        });
      },
      onClearFilters: () {
        setState(() {
          selectedSeason = 'All';
          selectedEpisode = 'All';
        });
      },
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      "suck it",
      "c'mon son",
      "pluto",
      "company car",
      "boneless",
      "this is my partner"
    ];

    return Column(
      children: [
        Text(
          "Try searching for:",
          style: TextStyle(
            fontSize: ResponsiveUtils.getSmallFontSize(context) + 1,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getVerticalPadding(context)),
        Wrap(
          spacing: ResponsiveUtils.getHorizontalPadding(context) * 0.5,
          runSpacing: ResponsiveUtils.getVerticalPadding(context) * 0.5,
          children: suggestions
              .map((suggestion) => _buildSuggestionChip(suggestion))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        textEditingController.text = text;
        setState(() {
          input = text;
          isLoading = true;
          isSearching = true;
        });
        Provider.of<DatabaseService>(context, listen: false)
            .searchQuotes(
          text,
          season: selectedSeason == "All" ? null : selectedSeason,
          episode: selectedEpisode == "All" ? null : selectedEpisode,
        )
            .then((results) {
          setState(() {
            searched = results;
            isLoading = false;
          });
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: ResponsiveUtils.getVerticalPadding(context) * 0.5,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveUtils.getSmallFontSize(context),
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget searchOptions(
      List<String> seasons, Map<String, List<String>> episodesMap) {
    return SearchFilters(
      controller: expansionController,
      selectedSeason: selectedSeason,
      selectedEpisode: selectedEpisode,
      seasons: seasons,
      episodesMap: episodesMap,
      onSeasonChanged: (value) {
        setState(() {
          selectedSeason = value;
          selectedEpisode = "All";
        });
      },
      onEpisodeChanged: (value) {
        setState(() {
          selectedEpisode = value;
        });
      },
      onClearFilters: () {
        setState(() {
          selectedSeason = 'All';
          selectedEpisode = 'All';
        });
      },
    );
  }

  Widget _buildCompactSearchBar() {
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
          input = text;
          setState(() {
            isLoading = true;
            isSearching = true;
          });
          var databaseService =
              Provider.of<DatabaseService>(context, listen: false);
          searched = await databaseService.searchQuotes(
            text,
            season: selectedSeason == "All" ? null : selectedSeason,
            episode: selectedEpisode == "All" ? null : selectedEpisode,
          );
          setState(() {
            isLoading = false;
          });
        },
        cursorColor: Theme.of(context).colorScheme.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: 'Search for quotes...',
          hintStyle: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      searched.clear();
                      isSearching = false;
                      input = "";
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
                      input = textEditingController.text;
                      setState(() {
                        isLoading = true;
                        isSearching = true;
                      });
                      var databaseService =
                          Provider.of<DatabaseService>(context, listen: false);
                      searched = await databaseService.searchQuotes(
                        textEditingController.text,
                        season: selectedSeason == "All" ? null : selectedSeason,
                        episode:
                            selectedEpisode == "All" ? null : selectedEpisode,
                      );
                      setState(() {
                        isLoading = false;
                      });
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

  Widget _buildCompactFilters(
      List<String> seasons, Map<String, List<String>> episodesMap) {
    return SearchFilters(
      controller: expansionController,
      selectedSeason: selectedSeason,
      selectedEpisode: selectedEpisode,
      seasons: seasons,
      episodesMap: episodesMap,
      onSeasonChanged: (value) {
        setState(() {
          selectedSeason = value;
          selectedEpisode = "All";
        });
      },
      onEpisodeChanged: (value) {
        setState(() {
          selectedEpisode = value;
        });
      },
      onClearFilters: () {
        setState(() {
          selectedSeason = 'All';
          selectedEpisode = 'All';
        });
      },
    );
  }

  Widget searchBar(List<dynamic> data) {
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
          input = text;
          setState(() {
            isLoading = true;
            isSearching = true;
          });
          var databaseService =
              Provider.of<DatabaseService>(context, listen: false);
          searched = await databaseService.searchQuotes(
            text,
            season: selectedSeason == "All" ? null : selectedSeason,
            episode: selectedEpisode == "All" ? null : selectedEpisode,
          );
          setState(() {
            isLoading = false;
          });
        },
        cursorColor: Theme.of(context).colorScheme.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: 'Search for quotes...',
          hintStyle: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      searched.clear();
                      isSearching = false;
                      input = "";
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
                      input = textEditingController.text;
                      setState(() {
                        isLoading = true;
                        isSearching = true;
                      });
                      var databaseService =
                          Provider.of<DatabaseService>(context, listen: false);
                      searched = await databaseService.searchQuotes(
                        textEditingController.text,
                        season: selectedSeason == "All" ? null : selectedSeason,
                        episode:
                            selectedEpisode == "All" ? null : selectedEpisode,
                      );
                      setState(() {
                        isLoading = false;
                      });
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
}

