import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psychphinder/classes/full_episode.dart';
import 'package:psychphinder/main.dart';
import 'package:psychphinder/references.dart';
import 'package:psychphinder/settings.dart';
import 'package:psychphinder/widgets/bottomsheet.dart';
import 'package:psychphinder/widgets/create_image.dart';

class ModalBottomSheetPage<T> extends Page<T> {
  final Widget child;

  const ModalBottomSheetPage({required this.child, super.key, super.name});

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      builder: (context) => child,
      isScrollControlled: true,
      useSafeArea: true,
      settings: this,
    );
  }
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const Home(),
      routes: [
        GoRoute(path: 'settings', builder: (_, __) => const SettingsPage()),
        GoRoute(
          path: 'references/season:season',
          builder: (context, state) {
            final season = state.pathParameters['season']!;
            return EpisodesRoute({}, season.toString());
          },
          routes: [
            GoRoute(
              path: 'episode:episode',
              builder: (context, state) {
                final episode = state.pathParameters['episode']!;
                return ReferencesRoute(
                  state.pathParameters['season']!,
                  episode,
                );
              },
              routes: [
                GoRoute(
                  path: ':idRef/:id',
                  pageBuilder: (context, state) {
                    final int phraseId = int.parse(state.pathParameters['id']!);
                    final String referenceId = state.pathParameters['idRef']!;

                    return customBottomSheet(context,
                        phraseId: phraseId, referenceId: referenceId);
                  },
                  routes: [
                    GoRoute(
                      path: 'shareimage',
                      builder: (context, state) {
                        return imageRoute(context, state, isShare: true);
                      },
                    ),
                    GoRoute(
                      path: 'wallpaper',
                      builder: (context, state) {
                        return imageRoute(context, state, isShare: false);
                      },
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 's:season/e:episode/p:sequence',
          pageBuilder: (context, state) {
            final int season = int.parse(state.pathParameters['season']!);
            final int episode = int.parse(state.pathParameters['episode']!);
            final int sequence = int.parse(state.pathParameters['sequence']!);

            return customBottomSheet(context,
                season: season, episode: episode, sequence: sequence);
          },
          routes: [
            GoRoute(
              path: 'r:referenceId',
              pageBuilder: (context, state) {
                final int season = int.parse(state.pathParameters['season']!);
                final int episode = int.parse(state.pathParameters['episode']!);
                final int sequence =
                    int.parse(state.pathParameters['sequence']!);
                final String referenceId = state.pathParameters['referenceId']!;

                return customBottomSheet(context,
                    season: season,
                    episode: episode,
                    sequence: sequence,
                    referenceId: referenceId);
              },
              routes: [
                GoRoute(
                  path: 'shareimage',
                  builder: (context, state) {
                    return imageRouteBySequence(context, state, isShare: true);
                  },
                ),
                GoRoute(
                  path: 'wallpaper',
                  builder: (context, state) {
                    return imageRouteBySequence(context, state, isShare: false);
                  },
                )
              ],
            ),
            GoRoute(
              path: 'shareimage',
              builder: (context, state) {
                return imageRouteBySequence(context, state, isShare: true);
              },
            ),
            GoRoute(
              path: 'wallpaper',
              builder: (context, state) {
                return imageRouteBySequence(context, state, isShare: false);
              },
            )
          ],
        ),
        GoRoute(
          path: ':id',
          pageBuilder: (context, state) {
            final int phraseId = int.parse(state.pathParameters['id']!);

            return customBottomSheet(context, phraseId: phraseId);
          },
          routes: [
            GoRoute(
              path: 'shareimage',
              builder: (context, state) {
                return imageRoute(context, state, isShare: true);
              },
            ),
            GoRoute(
              path: 'wallpaper',
              builder: (context, state) {
                return imageRoute(context, state, isShare: false);
              },
            )
          ],
        ),
      ],
    ),
  ],
);

Widget imageRoute(BuildContext context, GoRouterState state,
    {bool isShare = false}) {
  final int phraseId = int.parse(state.pathParameters['id']!);

  return FutureBuilder<void>(
    future: EpisodeUtil.loadEpisodeById(phraseId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (snapshot.hasError) {
        return Scaffold(
          body: Center(child: Text('Error loading episode: ${snapshot.error}')),
        );
      }

      return CreateImagePage(
          episode: EpisodeUtil.full, id: EpisodeUtil.index, isShare: isShare);
    },
  );
}

Page<dynamic> customBottomSheet(BuildContext context,
    {String referenceId = "",
    int? phraseId,
    int? season,
    int? episode,
    int? sequence}) {
  return ModalBottomSheetPage(
    child: SizedBox(
      height: 600,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          child: Scaffold(
            backgroundColor: Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withValues(alpha: 0.15),
            body: _buildBottomSheetBody(
                referenceId, phraseId, season, episode, sequence),
          ),
        ),
      ),
    ),
  );
}

Widget _buildBottomSheetBody(String referenceId, int? phraseId, int? season,
    int? episode, int? sequence) {
  if (phraseId == null && season == null) {
    return BottomSheetEpisode(
      indexLine: EpisodeUtil.index,
      fullEpisode: EpisodeUtil.full,
      referenceId: referenceId,
    );
  }

  Future<void> loadingFuture;
  int indexLine;

  if (phraseId != null) {
    loadingFuture = EpisodeUtil.loadEpisodeById(phraseId);
    indexLine = EpisodeUtil.index;
  } else {
    loadingFuture =
        EpisodeUtil.loadEpisodeBySequence(season!, episode!, sequence!);
    indexLine = sequence;
  }

  return FutureBuilder<void>(
    future: loadingFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error loading episode: ${snapshot.error}'));
      }

      return BottomSheetEpisode(
        indexLine: indexLine,
        fullEpisode: EpisodeUtil.full,
        referenceId: referenceId,
      );
    },
  );
}

Widget imageRouteBySequence(BuildContext context, GoRouterState state,
    {bool isShare = false}) {
  final int season = int.parse(state.pathParameters['season']!);
  final int episode = int.parse(state.pathParameters['episode']!);
  final int sequence = int.parse(state.pathParameters['sequence']!);

  return FutureBuilder<void>(
    future: EpisodeUtil.loadEpisodeBySequence(season, episode, sequence),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (snapshot.hasError) {
        return Scaffold(
          body: Center(child: Text('Error loading episode: ${snapshot.error}')),
        );
      }

      return CreateImagePage(
          episode: EpisodeUtil.full, id: EpisodeUtil.index, isShare: isShare);
    },
  );
}
