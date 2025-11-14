import 'package:flutter/material.dart';
import 'package:psychphinder/utils/responsive.dart';

class SearchFilters extends StatelessWidget {
  final ExpansibleController controller;
  final String selectedSeason;
  final String selectedEpisode;
  final List<String> seasons;
  final Map<String, List<String>> episodesMap;
  final Function(String) onSeasonChanged;
  final Function(String) onEpisodeChanged;
  final VoidCallback onClearFilters;

  const SearchFilters({
    super.key,
    required this.controller,
    required this.selectedSeason,
    required this.selectedEpisode,
    required this.seasons,
    required this.episodesMap,
    required this.onSeasonChanged,
    required this.onEpisodeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionTile(
        controller: controller,
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        tilePadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: ResponsiveUtils.getVerticalPadding(context) * 0.8,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          ResponsiveUtils.getHorizontalPadding(context),
          0,
          ResponsiveUtils.getHorizontalPadding(context),
          ResponsiveUtils.getVerticalPadding(context),
        ),
        title: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Search filters",
              style: TextStyle(
                fontSize: ResponsiveUtils.getSmallFontSize(context) + 2,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (selectedSeason != 'All' || selectedEpisode != 'All')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getSmallFontSize(context) - 1,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        children: [
          StatefulBuilder(
            builder: (context, setFilterState) {
              return Column(
                children: [
                  if (isLargeScreen)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _FilterDropdown(
                            label: "Season",
                            value: selectedSeason,
                            items: ['All', ...seasons],
                            onChanged: (value) {
                              setFilterState(() {});
                              onSeasonChanged(value!);
                            },
                          ),
                        ),
                        SizedBox(
                            width:
                                ResponsiveUtils.getHorizontalPadding(context)),
                        Expanded(
                          flex: 2,
                          child: _FilterDropdown(
                            label: selectedSeason == "Movies"
                                ? "Movie"
                                : "Episode",
                            value: selectedEpisode,
                            items: _buildEpisodeItems(
                                selectedSeason, episodesMap),
                            onChanged: (value) {
                              setFilterState(() {});
                              onEpisodeChanged(value!);
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _FilterDropdown(
                          label: "Season",
                          value: selectedSeason,
                          items: ['All', ...seasons],
                          onChanged: (value) {
                            setFilterState(() {});
                            onSeasonChanged(value!);
                          },
                        ),
                        SizedBox(
                            height:
                                ResponsiveUtils.getVerticalPadding(context)),
                        _FilterDropdown(
                          label: selectedSeason == "Movies"
                              ? "Movie"
                              : "Episode",
                          value: selectedEpisode,
                          items:
                              _buildEpisodeItems(selectedSeason, episodesMap),
                          onChanged: (value) {
                            setFilterState(() {});
                            onEpisodeChanged(value!);
                          },
                        ),
                      ],
                    ),
                  if (selectedSeason != 'All' || selectedEpisode != 'All') ...[
                    SizedBox(
                        height: ResponsiveUtils.getVerticalPadding(context)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setFilterState(() {});
                          onClearFilters();
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          'Clear filters',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getSmallFontSize(context),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<String> _buildEpisodeItems(
      String season, Map<String, List<String>> episodesMap) {
    final episodeList = episodesMap[season] ?? [];
    return ['All', ...episodeList];
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getSmallFontSize(context),
            fontWeight: FontWeight.w500,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonFormField<String>(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getSmallFontSize(context),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
