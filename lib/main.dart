import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'services/media_service.dart';

void main() {
  runApp(const VortexApp());
}

const Color purple = Color(0xFF9B5CFF);
const Color blue = Color(0xFF536DFF);
const Color pink = Color(0xFFFF4FA3);
const Color darkBackground = Color(0xFF090812);

class VortexApp extends StatefulWidget {
  const VortexApp({super.key});

  @override
  State<VortexApp> createState() => _VortexAppState();
}

class _VortexAppState extends State<VortexApp> {
  ThemeMode themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vortex Player',
      themeMode: themeMode,

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),

      home: MainScreen(
        isDark: themeMode == ThemeMode.dark,
        onThemeChanged: toggleTheme,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Discover',
    'Videos',
    'Music',
    'Playlists',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onThemeChanged: widget.onThemeChanged),
      const MediaPage(type: 'Videos'),
      const MediaPage(type: 'Music'),
      const PlaylistPage(),
      SettingsPage(
        isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.blur_on_rounded,
              color: purple,
              size: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'VORTEX',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: widget.onThemeChanged,
              icon: Icon(
                widget.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => selectedIndex = 4);
              },
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),

      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.movie_outlined),
                selectedIcon: Icon(Icons.movie),
                label: 'Videos',
              ),
              NavigationDestination(
                icon: Icon(Icons.music_note_outlined),
                selectedIcon: Icon(Icons.music_note),
                label: 'Music',
              ),
              NavigationDestination(
                icon: Icon(Icons.queue_music),
                label: 'Playlists',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HOME PAGE
// ==========================================

class HomePage extends StatelessWidget {
  final VoidCallback onThemeChanged;

  const HomePage({
    super.key,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 25),
      children: [

        const Text(
          'YOUR MEDIA UNIVERSE',
          style: TextStyle(
            color: purple,
            fontSize: 11,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Everything.\nIn one place.',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 22),

        const FeaturedCard(),

        const SizedBox(height: 30),

        const SectionHeader(
          title: 'Your Library',
          subtitle: 'EXPLORE YOUR COLLECTION',
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: LibraryCard(
                title: 'Videos',
                count: '0 Videos',
                icon: Icons.movie_creation_outlined,
                color: purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryCard(
                title: 'Music',
                count: '0 Tracks',
                icon: Icons.graphic_eq,
                color: pink,
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        const SectionHeader(
          title: 'Recently Played',
          subtitle: 'PICK UP WHERE YOU LEFT OFF',
        ),

        const SizedBox(height: 12),

        const EmptyState(
          icon: Icons.history_rounded,
          title: 'Nothing played yet',
          subtitle: 'Your recently played media will appear here.',
        ),

        const SizedBox(height: 30),

        const SectionHeader(
          title: 'Quick Access',
          subtitle: 'YOUR FAVORITES',
        ),

        const SizedBox(height: 15),

        const QuickAccessCard(
          icon: Icons.folder_open_rounded,
          title: 'Browse Files',
          subtitle: 'Explore your device storage',
        ),

        const SizedBox(height: 12),

        const QuickAccessCard(
          icon: Icons.favorite_rounded,
          title: 'Favorites',
          subtitle: 'Your favorite media collection',
        ),
      ],
    );
  }
}

// ==========================================
// FEATURED CARD
// ==========================================

class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF48208C),
            Color(0xFF17142F),
            Color(0xFF111020),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -35,
            child: Icon(
              Icons.blur_circular,
              size: 230,
              color: Colors.white.withOpacity(0.06),
            ),
          ),

          Positioned(
            right: 30,
            bottom: 20,
            child: Icon(
              Icons.graphic_eq,
              size: 110,
              color: purple.withOpacity(0.35),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: purple.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'VORTEX EXPERIENCE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                const Text(
                  'Your world.\nYour soundtrack.',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 15),

                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: pink,
                      size: 16,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'A new way to experience media',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SECTION HEADER
// ==========================================

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 2,
            color: purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// LIBRARY CARD
// ==========================================

class LibraryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const LibraryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// QUICK ACCESS
// ==========================================

class QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: purple, size: 25),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 15),
        ],
      ),
    );
  }
}

// ==========================================
// EMPTY STATE
// ==========================================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, size: 35, color: purple),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MINI PLAYER
// ==========================================

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 5, 12, 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF292044),
            Color(0xFF151323),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [purple, pink],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nothing playing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose your media',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white70,
            size: 29,
          ),
        ],
      ),
    );
  }
}

// ==========================================

// ==========================================
// PLAYLIST PAGE
// ==========================================

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Playlists',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your playlists will appear here.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Playlists Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first playlist to get started.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ==========================================
// MEDIA PAGE - REAL MEDIA LIBRARY
// ==========================================

class MediaPage extends StatefulWidget {
  final String type;

  const MediaPage({
    super.key,
    required this.type,
  });

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  final MediaService mediaService = MediaService();

  late Future<List<AssetEntity>> mediaFuture;

  final ScrollController _scrollController = ScrollController();

  List<AssetEntity> _videos = [];

  bool _isLoadingMore = false;
  Object? _loadMoreError;

  bool get isVideo => widget.type == 'Videos';

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    loadMedia();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadMedia() {
    _videos.clear();
    _isLoadingMore = false;
    _loadMoreError = null;

    mediaFuture = _loadInitialMedia();
  }

  Future<List<AssetEntity>> _loadInitialMedia() async {
    if (isVideo) {
      final videos = await mediaService.getVideos();

      _videos = videos;

      return videos;
    }

    return mediaService.getAudios();
  }

  void _onScroll() {
    if (!isVideo || !_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 500) {
      _loadMoreVideos();
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore ||
        !mediaService.hasMoreVideos ||
        _loadMoreError != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newVideos = await mediaService.loadMoreVideos();

      if (!mounted) return;

      setState(() {
        _videos.addAll(newVideos);
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadMoreError = error;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> refreshMedia() async {
    setState(() {
      loadMedia();
    });

    await mediaFuture;
  }

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);

    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.type,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isVideo
                ? 'YOUR VIDEO COLLECTION'
                : 'YOUR MUSIC COLLECTION',
            style: const TextStyle(
              color: purple,
              letterSpacing: 3,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<AssetEntity>>(
              future: mediaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: purple,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: pink,
                          size: 45,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        ElevatedButton(
                          onPressed: refreshMedia,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final List<AssetEntity> media =
                    isVideo ? _videos : snapshot.data ?? [];

                if (media.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isVideo
                              ? Icons.video_library_outlined
                              : Icons.library_music_outlined,
                          size: 65,
                          color: purple,
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Your library is empty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'No media files were found.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 20),

                        OutlinedButton.icon(
                          onPressed: refreshMedia,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${media.length} ${isVideo ? 'Videos' : 'Tracks'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const Spacer(),

                        IconButton(
                          onPressed: refreshMedia,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: GridView.builder(
                        controller: isVideo
                            ? _scrollController
                            : null,

                        itemCount: media.length +
                            (isVideo &&
                                    (_isLoadingMore ||
                                        _loadMoreError != null)
                                ? 1
                                : 0),

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.85,
                        ),

                        itemBuilder: (context, index) {
                          if (index >= media.length) {
                            if (_loadMoreError != null) {
                              return Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _loadMoreError = null;
                                    });

                                    _loadMoreVideos();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              );
                            }

                            return const Center(
                              child: CircularProgressIndicator(
                                color: purple,
                              ),
                            );
                          }

                          final asset = media[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),

                            clipBehavior: Clip.antiAlias,

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (isVideo)
                                        FutureBuilder(
                                          future: asset.thumbnailData,
                                          builder: (context, thumb) {
                                            if (thumb.hasData &&
                                                thumb.data != null) {
                                              return Image.memory(
                                                thumb.data!,
                                                fit: BoxFit.cover,
                                              );
                                            }

                                            return const ColoredBox(
                                              color: Color(0xFF211936),
                                              child: Center(
                                                child: Icon(
                                                  Icons.movie,
                                                  size: 45,
                                                  color: purple,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        Container(
                                          decoration:
                                              const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF48208C),
                                                Color(0xFF17142F),
                                              ],
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.music_note,
                                              color: Colors.white,
                                              size: 55,
                                            ),
                                          ),
                                        ),

                                      if (isVideo)
                                        Positioned(
                                          right: 9,
                                          bottom: 9,
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              formatDuration(
                                                asset.duration,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    asset.title ?? 'Unknown Media',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}  }
}

// ==========================================
// SETTINGS PAGE
// ==========================================

class SettingsPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onThemeChanged;

  const SettingsPage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'CUSTOMIZE YOUR EXPERIENCE',
          style: TextStyle(
            color: purple,
            letterSpacing: 3,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 30),

        SettingsTile(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          subtitle: 'Change application theme',
          trailing: Switch(
            value: isDark,
            activeThumbColor: purple,
            onChanged: (_) => onThemeChanged(),
          ),
        ),

        const SettingsTile(
          icon: Icons.equalizer,
          title: 'Equalizer',
          subtitle: 'Audio enhancement settings',
        ),

        const SettingsTile(
          icon: Icons.subtitles_outlined,
          title: 'Subtitles',
          subtitle: 'Subtitle preferences',
        ),

        const SettingsTile(
          icon: Icons.play_circle_outline,
          title: 'Playback',
          subtitle: 'Playback preferences',
        ),

        const SettingsTile(
          icon: Icons.storage_outlined,
          title: 'Storage',
          subtitle: 'Media library management',
        ),

        const SizedBox(height: 30),

        const Center(
          child: Column(
            children: [
              Icon(
                Icons.blur_on_rounded,
                color: purple,
                size: 45,
              ),
              SizedBox(height: 10),
              Text(
                'VORTEX PLAYER',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Version 0.1.0',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SETTINGS TILE
// ==========================================

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: purple, size: 25),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),

          trailing ??
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
              ),
        ],
      ),
    );
  }
}
